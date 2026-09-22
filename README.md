# test_rails

社会人サークル・草チームなどの「幹事業務」を支援する Rails アプリです。
チーム作成、メンバー管理、イベント（練習・試合）の出欠確認、タスク（当番）の割り当て、参加費の集金管理をひとつのアプリで完結できます。

## 主な機能

- **チーム管理**：ユーザーがチームを作成し、オーナーとして管理する
- **メンバー管理**：チームメンバーの登録・編集・非アクティブ化（`TeamMember`）
- **イベント／出欠管理**：練習・試合などのイベントを作成すると、アクティブなメンバー全員の出欠（`Attendance`）が自動で作成される。メンバーはログイン不要の公開URL（`public_token`）から出欠を回答できる
- **タスク管理**：チーム／イベントに紐づくタスク（当番など）を作成し、メンバーに割り当てる
- **参加費管理**：イベントに参加費を設定しておくと、メンバーが「参加」に回答したタイミングで自動的に `Payment`（未払い）が作成される。幹事は入金確認後に支払い済みへ更新する
- **認可**：チーム配下（メンバー／イベント／支払いなど）へのアクセスは `TeamPolicy` により、そのチームのオーナーのみに制限される
- **ERD 表示**：管理画面（`/admin/documentations/erd`）から Mermaid 形式の ER 図を確認できる

## 技術スタック

- Ruby 3.3.0 / Rails 7.1
- MySQL（`mysql2`）
- Hotwire（Turbo / Stimulus）+ Tailwind CSS
- 認証：`bcrypt`（自前のセッション認証）
- テスト：RSpec + Capybara + Selenium

## セットアップ

### 必要なもの

- Ruby 3.3.0（`.ruby-version` 参照）
- MySQL（ローカル起動、もしくは `DB_HOST` で接続先を指定）

### 手順

```bash
# 依存関係のインストール
bundle install

# データベースの作成・マイグレーション
bin/rails db:create db:migrate

# （任意）サンプルデータの投入
bin/rails db:seed

# サーバー起動
bin/rails server
```

`http://localhost:3000` にアクセスすると `/signup` からユーザー登録できます。

### DB接続先の変更

`config/database.yml` はデフォルトで `localhost` の MySQL（`root` / パスワードなし）に接続します。Docker 等で別ホストに接続する場合は環境変数 `DB_HOST` を指定してください。

```bash
DB_HOST=127.0.0.1 bin/rails server
```

## テスト

```bash
bundle exec rspec
```

## Lint

```bash
bundle exec rubocop
bundle exec erblint --lint-all
```

## その他

- `/admin/documentations/erd` から ER 図（Mermaid）を閲覧できます。ER 図は `db:migrate` / `db:schema:load` 実行時（development環境）に自動生成されます（`lib/tasks/mermaid_erb.rake`）
- モデルのスキーマ情報コメントは `annotate` gem により自動生成されています
