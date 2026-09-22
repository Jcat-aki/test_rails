# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MigrationLockRetry do
  before do
    described_class.instance_variable_set(:@config, nil)
    described_class.enabled = false
    allow(described_class).to receive(:sleep)
  end

  def swallow_error
    yield
  rescue StandardError
    nil
  end

  def build_flaky_block(error, times_to_fail)
    lambda do
      attempts << 1
      attempts.size <= times_to_fail ? raise(error) : 'ok'
    end
  end

  describe '.retry_on_lock_wait_timeout' do
    subject(:call_with_retry) { described_class.retry_on_lock_wait_timeout(&block) }

    let(:attempts) { [] }

    context 'ブロックが成功する場合' do
      let(:block) { -> { 'ok' } }

      it '結果をそのまま返す' do
        expect(call_with_retry).to eq('ok')
      end
    end

    context 'ロック待ちタイムアウトが発生する場合' do
      let(:block) { build_flaky_block(ActiveRecord::LockWaitTimeout.new('Lock wait timeout exceeded'), 2) }

      it '成功するまでリトライする' do
        expect(call_with_retry).to eq('ok')
      end

      it '成功するまでの試行回数を記録する' do
        swallow_error { call_with_retry }
        expect(attempts.size).to eq(3)
      end
    end

    context 'デッドロックが発生する場合' do
      let(:block) { build_flaky_block(ActiveRecord::Deadlocked.new('Deadlock found'), 1) }

      it '成功するまでリトライする' do
        expect(call_with_retry).to eq('ok')
      end
    end

    context 'メッセージに Lock wait timeout exceeded を含む StatementInvalid の場合' do
      let(:block) do
        build_flaky_block(ActiveRecord::StatementInvalid.new('Mysql2::Error: Lock wait timeout exceeded'), 1)
      end

      it '成功するまでリトライする' do
        expect(call_with_retry).to eq('ok')
      end
    end

    context '最大リトライ回数を超える場合' do
      before { described_class.configure { |config| config[:attempts] = 3 } }

      let(:block) { build_flaky_block(ActiveRecord::LockWaitTimeout.new('Lock wait timeout exceeded'), 100) }

      it '例外を再送出する' do
        expect { call_with_retry }.to raise_error(ActiveRecord::LockWaitTimeout)
      end

      it '設定した回数まで試行する' do
        swallow_error { call_with_retry }
        expect(attempts.size).to eq(3)
      end
    end

    context 'ロック待ちと関係ないエラーの場合' do
      let(:block) { build_flaky_block(ActiveRecord::RecordNotUnique.new('Duplicate entry'), 100) }

      it 'リトライせずに再送出する' do
        expect { call_with_retry }.to raise_error(ActiveRecord::RecordNotUnique)
      end

      it '1回しか試行しない' do
        swallow_error { call_with_retry }
        expect(attempts.size).to eq(1)
      end
    end
  end

  describe '.around_migration' do
    let(:connection) { instance_double(ActiveRecord::ConnectionAdapters::AbstractAdapter) }

    before do
      allow(connection).to receive(:select_value).with('SELECT @@SESSION.lock_wait_timeout').and_return('50')
      allow(connection).to receive(:execute)
    end

    it 'ブロック実行中は enabled? が true になる' do
      described_class.around_migration(connection) do
        expect(described_class.enabled?).to be(true)
      end
    end

    it '実行後に enabled? が false に戻る' do
      described_class.around_migration(connection) {}
      expect(described_class.enabled?).to be(false)
    end

    it 'lock_wait_timeout を短く設定する' do
      described_class.around_migration(connection) {}
      expected_sql = "SET SESSION lock_wait_timeout = #{described_class.config[:lock_wait_timeout]}"
      expect(connection).to have_received(:execute).with(expected_sql)
    end

    it '実行後に元の lock_wait_timeout へ戻す' do
      described_class.around_migration(connection) {}
      expect(connection).to have_received(:execute).with('SET SESSION lock_wait_timeout = 50')
    end

    it 'ブロックが例外を送出した場合は再送出する' do
      expect { described_class.around_migration(connection) { raise 'boom' } }.to raise_error('boom')
    end

    it 'ブロックが例外を送出しても enabled フラグを元に戻す' do
      swallow_error { described_class.around_migration(connection) { raise 'boom' } }
      expect(described_class.enabled?).to be(false)
    end
  end
end
