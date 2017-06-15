---
title: OrientDB-http
date: 2017-06-14 10:10:01
tags:
---

OrientDB除了提供相關的程式語言client library之外，向支援一般的http request，以下將記錄相關的使用方式。

## Authentication and security
OrientDB中的認證機制皆採用[Basic access authentication](https://en.wikipedia.org/wiki/Basic_access_authentication)的認證機制，發送之前以`user:password`的字串並以[Base64](https://zh.wikipedia.org/wiki/Base64)算法編碼，server端接收後解碼得到正確的帳號密碼進行驗證，這種方式適合於內部溝通使用，因此OrientDB並不適合直接對外溝通，首先測試是否與資料庫連接正常：

```sh
curl -i --header "Authorization: Basic ${your user:password}" http://localhost:2480/connect/test
```
回傳的status code如果為`401`代表驗證錯誤，正常應回應`204`。

## Create database
```sh
 curl -X POST -H "Content-Type: application/json" -H "Authorization: Basic ${your user:password}" http://localhost:2480/database/test/plocal
```
response status code `409`代表資料庫已存在

## Create class
由於我們需要創建繼承的class因此採用[Command API](http://orientdb.com/docs/2.2.x/OrientDB-REST.html#command)
```sh
curl -X POST -H "Content-Type: application/json" -H "Authorization: Basic ${your user:password}" -d '{"command": "create class Person extends V"}' http://localhost:2480/command/test/sql

curl -X POST -H "Content-Type: application/json" -H "Authorization: Basic ${your user:password}" -d '{"command": "create class Company extends V"}' http://localhost:2480/command/test/sql

curl -X POST -H "Content-Type: application/json" -H "Authorization: Basic ${your user:password}" -d '{"command": "create class WorkAt extends E"}' http://localhost:2480/command/test/sql
```

## Batch commands
建立關聯的方式可以採用Batch commands的方式進行
```sh
 curl -X POST -H "Content-Type: application/json" -H "Authorization: Basic cm9vdDpvcmllbnRkYg==" -d 
 '{
      "transaction": true,
      "operations": [
          {
            "type": "script",
            "language": "sql",
            "script": [
               "let person = UPDATE Person SET firstName=\"Lin\", lastName=\"Wolk\", uid=1 UPSERT RETURN AFTER @rid WHERE uid=1",
               "let company = UPDATE Company SET name=\"ABC\", cid=1 UPSERT  RETURN AFTER @rid WHERE cid=1",
               "CREATE EDGE WorkAt FROM $person TO $company"
            ]
         }
      ]
  }' 
  http://localhost:2480/batch/test

```