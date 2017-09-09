---
categories: web
title: REST API design
date: 2017-07-28 09:26:40
tags:
---

# REST API design

## 避免API設計缺陷
簡介一個缺陷的API，想像一下當我們存取商品種類清單時，以往可能以這樣的方式向後端請求`GET /categories`，那麼存取某個商品種類的方式可能會是這樣`GET /getProductListFromCategory?category_id=id`，檢查商品是否屬於某個類別`GET /productInCategories?values=id_1,id_2,...id_n`，當我們需要更改產品說明時我們必須將整個產品資訊發送回去`POST /product`並夾帶大量的資訊於body.再假設一個情境是需要發送特定的mail給特定的人並存取這樣的API`POST /email-customer`需要夾帶他們的email與message。

如果我們不能從上面的例子中找出API設計的缺陷，那麼代表我們花太多時間在設計相同的API上了，以下列出幾個有問題的設計：

* 每個方都都有自己的命名約定例如：`camelCase`, `hyphen-delimited`, `underscore_separated`。
* 參數的注入沒有明確的目的，可能透過`query string`或是`post body`，這些也可能透過`cookie`技術就能達到。
* 不清楚什麼時機點使用HTTP verb, 從例子中來看只有使用到`GET`、`POST`。
* API設計不一致，良好的API設計不僅文件清晰並提供一致性的API介面以及設計者能夠輕鬆建立。

## Endpoints, HTTP verbs, and versioning
當我們常常使用到公共API時可能會感覺到明顯的差異，哪些API簡潔易懂哪些用起來非常不方便，好的API甚至不需要太詳細的文件描述就能知道API的意圖舉例來說Facebook的Graph REST API就非常容易使用`http://facebook.com/me`，不僅將您帶到個人資訊甚至進行了身份驗證動作，相比之下糟糕的API設計導致混亂原因是： 不明確的命名、文件描述不明確...等，因此我們必須逐步的來避免這樣的狀況發生。

### 管理你的Endpoints
首先我們必須為所有API端點定義一個前綴,例如我們有一個子網域`api.example.com`，我們可以加上`api.example.com/api`這樣的前綴來識別API與前端頁面路由的差異，並提供以下幾個原則：

* 使用lowercase, hyphenated endpoints 像是 `/api/verification-tokens`。
* 資源的描述應明確分離不可混雜，例如`users`、`products`分屬不同屬性的兩個資源。
* 儘量以複數型式來表達資源：`/api/users`而不是`/api/user`這樣使我們的API更具語意性及彈性。

### HTTP動詞及CRUD一致性
首先我們要取得產品清單應該以這樣的方式進行存取`GET /api/products`, 接下來我們可能需要取得個別商品資訊`GET /api/product/:id`, 但是基於上述的guidline我們應儘量使用複數的型式來表示, 因此存取資源應為`GET /api/products/:id`, 這兩種方式很明確的知道我們是以讀取的角度去進行，因此使用的HTTP 動詞應為`GET`請求。

那麼關於刪除某個商品呢？以往我們可能以這樣的方式去進行設計`POST /removeProduct?id=:id`, 但是根據REST的設計我們應該改為`DELETE /api/products/:id`。

新增商品的部份傳統我們可能以這樣的方式去進行`POST /createProduct`並夾帶資訊於body內，根據REST的設計應該使用`PUT /api/products`修改的部份應該使用`PATCH /api/products/:id`, 這邊我們可能會困惑為什麼不是使用`POST /api/products`來新增商品?主要涉及後端API與資料庫之間可能需要create或update。

以下列出HTTP動詞及Endpoints的相關範例

| 動詞     | Endpoint              | 描述                           |
|--------|-----------------------|------------------------------|
| GET    | /products             | 取得產品清單                       |
| GET    | /products/:id         | 取得某個產品                       |
| GET    | /products/:id/parts   | 獲取某個產品中的零件                   |
| PUT    | /products/:id/parts   | 新增一個產品的零件                    |
| DELETE | /products/:id         | 刪除一個產品                       |
| PUT    | /products             | 新增一個新產品                      |
| HEAD   | /products/:id         | 檢查產品是否存在可能回傳狀態碼為`200`or`404` |
| PATCH  | /products/:id         | 編輯某個已經存在的產品                  |
| POST   | /authentication/login | 大多數其他API方法應該使用POST請求         |


## Requests, responses, and status codes

### Request
目前JSON格式被廣泛用於前後端溝通的共同語言，當然有其他格式可以使用，這就取決於需求，但跟著大眾的需求相對的相關library也會比較多, 意味著前後端在解析時相對較容易。

### Response
溝通語言必須與request相同舉例來說若request的格式為json，那麼response也必須為json，並且必須包裝回應的格式, 如下,我們以data來做為包裝

```json
{
   "data": { }
}
```

另外當發生錯誤的回應也是一個重要的設計, 它能夠暴露出錯誤代碼、錯誤原因讓使用API的人可以清楚的明白所發送的請求發生哪些錯誤

```json
{
   "error": {
      "code": "bf-404",
      "message": "Product not found.",
      "context": {
         "id": "baeb-b00f"
      }
   }
}
```

### [HTTP status code](https://zh.wikipedia.org/wiki/HTTP%E7%8A%B6%E6%80%81%E7%A0%81)

## Paging, caching, and throttling
### Response Paging
假設我們需要讀取一個產品清單, 而產品可能有上千種, 那麼這樣的Request所回應的Response勢必傳輸大量資料, 對前後端都是不好的, 此時我們就可以運用分頁機制, 假設一次的Request只回傳10筆, 當要繼續取得, 就可以使用Link header的方式, 假設我們第一次存取`GET /api/products`, Response的header便可以夾帶這樣的資訊

```sh
Link: <http://example.com/api/products/?p=2>; rel="next",
      <http://example.com/api/products/?p=54>; rel="last"
```

rel主要描述本頁與其他頁面之間的關係

### Response Caching
設定`Cache-Control`header為`private`可以繞過中介(例如像nginx這樣的代理), 最終只允許客戶端緩存，若設置為`public`則允許中介層緩存。
然而`Expires`header主要告知瀏覽器緩存的有效期限。

在API Response中定義`Expires`headers是比較困難的, 那麼假設今天客戶端的電腦時間被調整了之後, 將造成`Expires`失效, 因為若時間調整的比`Expires`大, 那麼瀏覽器就會認定所有的Cache都是過期的, 因此將重複發送Request便失去了緩存的意義。

因此採用了條件請求的方式, 使用`Last-Modified`header回應請求, 並設置`max-age`header, 讓browser於一段時間後失效, 運作情境如下
>1. 向後端發送request。
>2. response中告知`Last-Modified`時間，並將`max-age`設為一年。
>3. 假設半年後發送請求時, 因為`max-age`尚未失效因此未向server端發送請求。
>4. 假設一年後發送請求時, 因為`max-age`已失效, 因此會向server端進行一次request, 但是請求時會根據`Last-Modified`的紀錄重新夾帶`If-Modified-Since`header。
>5. 此時server端會根據`If-Modified-Since`去比對檔案更新時間, 那麼當檔案確實更新了將會發送新的檔案並重新夾帶header資訊如步驟2
>6. 假設檔案尚未更新那個將回應`304 Not Modified`， 而client端也將重快取資源中存取。


