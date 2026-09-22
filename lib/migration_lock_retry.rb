# frozen_string_literal: true

# 他のトランザクションが対象テーブルの行をロックしている状態で DDL (ALTER TABLE など) を
# 実行すると、MySQL はメタデータロック待ちになり "Lock wait timeout exceeded" で失敗する。
#
# migration の実行中だけ以下を有効にすることで、この失敗を吸収する。
#   1. セッションの lock_wait_timeout を短く設定し、ロック待ちで長時間他のクエリを
#      詰まらせたままにしない
#   2. ロック待ちタイムアウトが発生したら、指数バックオフ + ジッタで自動リトライする
#
# MySQL の DDL は 1 ステートメント単位で atomic に成功/失敗するため、
# ステートメント単位でリトライしても二重適用にはならない。
#
# ActiveRecord::Migration と mysql2 アダプタへのフックは
# config/initializers/migration_lock_retry.rb で行っており、全ての migration に
# 自動的に適用される。
module MigrationLockRetry
  LOCK_WAIT_TIMEOUT_MESSAGE = /Lock wait timeout exceeded/i

  class << self
    def enabled?
      !!Thread.current[:migration_lock_retry_enabled]
    end

    def enabled=(value)
      Thread.current[:migration_lock_retry_enabled] = value
    end

    def config
      @config ||= {
        attempts: 5,
        lock_wait_timeout: 2, # 秒。DDL がこの秒数ロック待ちしたら諦めてリトライする
        base_delay: 0.5,      # 秒。リトライ間隔の基準値（指数バックオフ）
        max_delay: 10         # 秒。リトライ間隔の上限
      }
    end

    def configure
      yield config
    end

    # migration 実行中だけ lock_wait_timeout を短くし、リトライを有効化する
    def around_migration(connection)
      original_timeout = fetch_lock_wait_timeout(connection)
      set_lock_wait_timeout(connection, config[:lock_wait_timeout])
      self.enabled = true
      yield
    ensure
      self.enabled = false
      set_lock_wait_timeout(connection, original_timeout) if original_timeout
    end

    # ロック待ちタイムアウト（またはデッドロック）が発生したらリトライする
    def retry_on_lock_wait_timeout
      attempt = 0

      begin
        attempt += 1
        yield
      rescue ActiveRecord::StatementInvalid => e
        raise unless should_retry?(e, attempt)

        wait_before_retry(e, attempt)
        retry
      end
    end

    private

    def should_retry?(error, attempt)
      retryable_error?(error) && attempt < config[:attempts]
    end

    def wait_before_retry(error, attempt)
      delay = next_delay(attempt)
      log_retry(error, attempt, delay)
      sleep(delay)
    end

    def retryable_error?(error)
      error.is_a?(ActiveRecord::LockWaitTimeout) ||
        error.is_a?(ActiveRecord::Deadlocked) ||
        LOCK_WAIT_TIMEOUT_MESSAGE.match?(error.message.to_s)
    end

    def next_delay(attempt)
      delay = [config[:base_delay] * (2**(attempt - 1)), config[:max_delay]].min
      delay + (rand * delay * 0.25) # jitter
    end

    def fetch_lock_wait_timeout(connection)
      connection.select_value('SELECT @@SESSION.lock_wait_timeout')
    rescue StandardError
      nil
    end

    def set_lock_wait_timeout(connection, seconds)
      connection.execute("SET SESSION lock_wait_timeout = #{seconds.to_i}")
    rescue StandardError => e
      Rails.logger&.warn("[MigrationLockRetry] lock_wait_timeout の設定に失敗しました: #{e.message}")
    end

    def log_retry(error, attempt, delay)
      Rails.logger&.warn(
        '[MigrationLockRetry] ロック待ちタイムアウトを検知しました' \
        "(#{attempt}/#{config[:attempts]}回目)。#{delay.round(2)}秒後にリトライします: #{error.message}"
      )
    end
  end

  # ActiveRecord::Migration にリトライ機能を組み込むためのフック。
  # migration 本体 (change/up/down) の実行を、lock_wait_timeout を短くした状態で包む。
  module MigrationPatch
    def exec_migration(conn, direction)
      MigrationLockRetry.around_migration(conn) { super }
    end
  end

  # mysql2 アダプタの execute にリトライ機能を組み込むためのフック。
  # add_column / add_index などの DDL ヘルパーは内部的にすべて execute を呼び出すため、
  # ここを 1 箇所フックするだけで add_column, add_index, change_column, add_reference,
  # add_foreign_key, create_table 等をまとめてカバーできる。
  #
  # 注意: update_all のような AR のデータ操作系メソッドはこのフックを経由しないため
  # 対象外。必要であれば migration 内で明示的に
  # `MigrationLockRetry.retry_on_lock_wait_timeout { ... }` を呼ぶこと。
  module ExecutePatch
    def execute(...)
      return super unless MigrationLockRetry.enabled?

      MigrationLockRetry.retry_on_lock_wait_timeout { super }
    end
  end
end
