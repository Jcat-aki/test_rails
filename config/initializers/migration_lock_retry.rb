# frozen_string_literal: true

# 行ロックが原因で migration の DDL が "Lock wait timeout exceeded" になっても
# 自動でリトライして成功させるための設定。詳細は lib/migration_lock_retry.rb を参照。
#
# デフォルト設定を変更したい場合はここで上書きする:
# MigrationLockRetry.configure do |config|
#   config[:attempts] = 8
#   config[:lock_wait_timeout] = 3
# end

ActiveSupport.on_load(:active_record) do
  ActiveRecord::Migration.prepend(MigrationLockRetry::MigrationPatch)
end

ActiveSupport.on_load(:active_record_mysql2adapter) do
  prepend(MigrationLockRetry::ExecutePatch)
end
