## 概要
* Rails7(MVC) × MySQL8の環境テンプレート

## プロジェクト作成手順

```
// ファイル作成→編集
$ touch Dockerfile Gemfile entrypoint.sh docker-compose.yml 

// rails new(オプション忘れずに)
$ docker-compose run web rails new . --force --no-deps --skip-test --database=mysql 

```

## bare cloneからの立ち上げ手順
```
// リポジトリのベアクローンを作成
git clone --bare git@kooojidevman:kooojidevman/rails7-mysql8-template.git

// 新しいリポジトリをミラーpush
cd rails7-template.git
git push --mirror git@kooojidevman:kooojidevman/{リポジトリ名}.git


// 新しいリポジトリをclone
git clone git@kooojidevman:kooojidevman/{リポジトリ名}.git

// database.ymlの設定(developmentとtest)
database: データベース名
host: db 
root: root
password: パスワード

// DB作成
docker-compose run --rm web rails db:create

// イメージの起動
docker-compose up

// 接続
http://localhost:3001
```


## pry-byebug Dockerでの操作方法

```
// コンテナにアタッチし、その後binding.pryを仕込んで処理を止める
docker attach {リポジトリ名}_web_1

// 以下の手順でコンテナアタッチを抜ける
continue入力 →フォアグランドに戻る →「control」+ p → q
```

## タイムゾーン設定

```
// application.rbに以下追加
config.time_zone = 'Tokyo'

// config/initializers/time_formats.rbを作成し以下記述。
// view側でto_sの引数にキーを指定しフォーマットを変換する。
Time::DATE_FORMATS[:datetime_jp] = '%Y年%m月%d日 %H時%M分'

```

## Tailwind CSSの導入
```
// Gemfileに以下追加
gem 'tailwindcss-rails', '~> 2.6'

// Dockerログイン
dc exec web bash  

// コマンド入力
bundle exec rails tailwindcss:install

// Dockerfile反映
```

- tailwindをビルドする際のコマンド
```
rails tailwindcss:build
```

### rubocop設定
```

// Gemfileのdevelopmentに以下追加
gem 'rubocop', require: false # 追加
gem 'rubocop-performance', require: false # 追加
gem 'rubocop-rails', require: false # 追加
gem 'rubocop-rspec' # 追加

// bundle install

// .rubocop.ymlを作成し調べながらお好みの設定をしていく

// rubocopの動作確認
dc exec web bundle exec rubocop 

```

### Rails自動生成ファイルの設定

```ruby

# 以下追加
config.generators do |g| # ここから追記
      g.assets false          # CSS, JavaScriptファイルを自動生成しない
      g.helper     false      # helperファイルを自動生成しない
end
```

## RSpecの導入

* Gemfileに以下追加
```
group :development, :test do
  gem 'rspec-rails'
  gem 'factory_bot_rails'
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem 'capybara'
end
```

* コマンド実行

```
// インストール
dc exec web bundle
dc exec web bundle exec rails g rspec:install

// 動作確認
dc exec web bundle exec rspec

// (やる必要あれば) /test 削除
rm -r test/
```

- `spec/rails_helper.rb`に下記追加
```ruby
RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods # 最下段に追記
end
```

- `config/application.rb`に追記
```ruby
config.generators do |g|
  g.assets false
  g.helper     false
  g.test_framework :rspec, # ここから5行を追記
    fixtures: false, # テストDBにレコードを作るfixtureの作成をスキップ(FactoryBotを使用するため)
    view_specs: false, # ビューファイル用のスペックを作成しない
    helper_specs: false, # ヘルパーファイル用のスペックを作成しない
    routing_specs: false # routes.rb用のスペックファイル作成しない
end
```

- .rspec ファイルの最下段に、以下の 1 行を追加
```
--format documentation # 出力結果をドキュメント風に見やすくする
```

- テスト起動の高速化のためにGemfileのdevelopmentに以下追加しinstall
```
group :development do
  ...
  gem 'spring-commands-rspec' # 追記
end
```

- コマンド実行
```
dc exec web bundle exec spring binstub rspec

// 確認
ls bin/
```

- `config/environments/test.rb`に修正
```ruby
config.cache_classes = false # trueからfalseに変更
```

## 認証(ログイン)関連の設定

- DeviseインストールしUserテーブル作成

```
// Gemfileに追加しインストール
gem "bcrypt", "~> 3.1.7" <- コメント外す
gem 'devise'

// devise の初期設定に必要なファイル生成
bundle exec rails g devise:install


// deviseのUserモデル作成
bundle exec rails g devise User

// nameカラム追加(その他カラムも任意で追加して良い)
bundle exec rails g migration AddNameToUser name:string

// マイグレーション実行
bundle exec rails db:migrate && bundle exec rails db:migrate RAILS_ENV=test
```


- Gemfileのbcryptをインストール後、以下実行しユーザーモデル作成

```
rails g model user name:string password_digest:string
```

- マイグレーション後、コントローラ(sessions, home, users)作成

```
rails g controller sessions create destroy --skip-template-engine
rails g controller home index
rails g controller users new create me  // meはマイページ表示のためのアクション
```

- Deviseモデルにおけるストロングパラメータを`app/controllers/application_controller.rb`にて設定する

```ruby
class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
  end
end

```

- deviseのviewファイル作成
```
bundle exec rails g devise:views
```

- viewは主に以下を修正
  - app/views/devise/registrations/new.html.erb (ユーザー登録ページ)
  - app/views/devise/sessions/new.html.erb (ログインページ)
  - app/views/devise/shared/_error_messages.html.erb (エラーメッセージのパーシャル)



## Seedデータ作成

* db/seeds.rb作成

```ruby:db/seeds.rb
if Rails.env == 'developent'
  (1..50).each do |i|
    Board.create(name: "ユーザー#{i}", title: "タイトル#{i}", body: "本文#{i}")
  end
end
```

* rails db:seedを実行

## 日本語化設定

- config/application.rbに以下追加

```ruby
config.i18n.default_locale = :ja
```

* Gemfileに以下追加しインストール

```
gem 'rails-i18n'
```

* ja.ymlを作り日本語を定義する

```yaml
// 例

ja:
  activerecord:
    errors:
      models:
        user:
          attributes:
            email:
              taken: "は既に使用されています。"
              blank: "が入力されていません。"
              invalid: "は有効でありません。"
            nickname:
              blank: "が入力されていません。"
              too_long: "は%{count}文字以下に設定して下さい。"
            password:
              blank: "が入力されていません。"
              too_short: "は%{count}文字以上に設定して下さい。"
              too_long: "は%{count}文字以下に設定して下さい。"
              invalid: "は有効でありません。"
            password_confirmation:
              confirmation: "が一致していません。"
    attributes:
      user:
        nickname: "ニックネーム"
        email: "メールアドレス"
        password: "パスワード"
        password_confirmation: "確認用パスワード"
    models:
      user: "ユーザー"
  errors:
    messages:
      not_saved: "エラーが発生したため%{resource}は保存されませんでした。"

  devise:
    failure:
      invalid: "%{authentication_keys}またはパスワードが違います。"
    registrations:
      user:
        signed_up: ユーザー登録に成功しました。
    sessions:
      new:
        sign_in: ログイン
      signed_in: ログインしました。
      user:
        signed_out: ログアウトしました。
```

## テーブルの構造がわかるようにモデルに記述したい

* Gemfileのdevelopmentに以下追加しインストール

```
gem 'annotate'
```

* 以下実行

```
// 既存のモデルにスキーマ情報(アノテーション)書き出し
docker-compose exec web bundle exec annotate --models

// マイグレーション時に自動でモデルにスキーマ情報を書き込む設定
docker-compose exec web rails g annotate:install
```





* ジェネレータの使い方

```
// モデル
rails g rspec:model User

// コントローラ
rails g rspec:controller User
```
