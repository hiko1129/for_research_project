## Description
* main.rbを実行することで特定の会社の商品レビューを取得することができる。  
* 検索するワードとGS1事業者コードをconfig/search.ymlに記述することで、
Yahoo Shoppingからレビューを取得する。  
* 特定の事業者が提供している商品のレビューのみを取得する。  
* とりあえずレビューを取得してreviews.dbに保存することはできる状態。
* 事前にYahoo JapanでアプリケーションIDを取得する必要がある。  

## Usage
* bundle install
* export APPLICATION_ID='YOUR_YAHOO_SHOPPING_APPLICATION_ID'をbash_profileなどに記述
* config/search.ymlに検索ワードとGS1事業者コードを記述
* main.rbを実行
* assets/reviews.dbを閲覧
