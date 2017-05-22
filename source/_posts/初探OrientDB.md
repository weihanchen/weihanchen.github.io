---
categories: orientdb
title: 初探OrientDB
date: 2017-05-22 11:43:35
tags: 
---


## 關鍵要素
- DATA_ENTITY - Document、Vertex(圖表模式下又稱為node,又可以解釋為資料的容器)。
- RELATIONSHOP - edge(連接兩個node之間的關係)。
- DATA_ATTRIBUTE - properties(資料屬性)。

## 名詞解釋
- Documents
   - 包含資料屬性
   - 具有獨特的id
   - 可以連結到其他文本
   - 可以包含sub-documents
- Properties
   - 具有資料型態(Boolean、Integer)
   - 可以被indexed
- Vertex
   - 類似於document
   - 具備連結關係: `incoming edges`、`outgoing edges`
   - 也被稱為`Nodes`
   - 可以想像為圖的圓圈
   
```json
{
   @rid: 20:23
   name: "wendy",
   in: [#13:2, #13:45],
   out: [#12:10, #14:33]
}
```

- Edge
   - 紀錄`Vertex`之間的關係
   - 雙向
- Class
   - 資料的類型
   - 例如`Person`、`SuperHero`

```json
{
   superclass: "Person",
   clusters: [15],
   defaultCluster: 15,
   properties: [
      {
         name: "steven",
         type: "LONG",
         readyonly: false
      }
   ]
}
```

- Cluster
   - 多個`Person`類別歸在某個`Cluster`
   - 儲存、擴展、封存
   - 查詢最佳化(Map/Reduce Query)

## 開始進入OrientDB，並實作人與公司之間的案例
假設已經將[OrientDB](https://orientdb.com/docs/2.1/Tutorial-Installation.html)安裝完成後進入下面步驟,分別示範`Person`、`Company`、`WorksAt`之間的關係。

### 網頁UI編輯模式
進入`localhost:2480`，依據主機ip與啟動port號不同自行修改。

### 創建db
![Create db](create_db.gif)

### 創建class
其中`WorkAt`繼承自`edge`用來連結`Company`及`Person`
Command
```sql
create class Person extends V
create class Company extends V
create class WorkAt extends E
```

### 創建property
Command
```sql
create property Person.firstName string
create property Person.lastName string
create property Company.name string
```

### 新增sample data
Command
```sql
insert into Person (firstName, lastName) values ("Gary", "White"), ("Join", "Steven"), ("Lin", "Tom")
insert into Company set name = "ABC"
insert into Company set name = "XYZ"
```

### 查詢class
```sql
select from V
```

### 創建edge
```sql
create edge WorkAt from #12:0 to #13:0
```

### 進到graph頁面查看關係圖
```sql
select from V
```
![Graph Relation](graph_relation.png)

### 直接藉由UI建立關聯
![Create Relation](create_relation.gif)

### 由UI產生新的vertex
![Create Node](create_node.gif)

## Console模式

### 啟動
```sh
cd orientdb/bin
./server.sh
# open new tab
./console.sh
```

### 建立db
```sh
create database remote:localhost/Demo root hello plocal
# plocal is storage type
```

### 停止連接
```sh
disconnect
```

### 連接
```sh
connect remote:localhost/databases/Demo root hello
```

### 其餘commands類似於Web UI操作

## 參考資料
- [udemy-orientdb](https://www.udemy.com/orientdb-getting-started)