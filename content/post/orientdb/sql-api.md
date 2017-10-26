---
title: "OrientDB-SQL-API"
date: 2017-04-05T17:09:37+08:00
categories: [orientdb]
draft: true
---

<!--more-->
## Commands

### Basic
```sql
CREATE class <className> [extends <super-class>] [cluster <clusterId>]
ALTER class <className> <attributeName> <attributeName>
DROP class <className>
TRUNCATE class <className>
```

### 刪除class中所有資料
```sql
DELETE vertex Person
```

### extends
>1. 建立`Lead`繼承至`V`
```sql
create class Lead extends V
```
>2. 為`V`建立一個`property`
```sql
create property V.createAt date
```
>3. 查看`Lead`是否具有父類別的`property`
> Command模式
```sh
info class Lead
```
> UI模式
![Lead Info UI](/images/orientdb-sql-api/lead_info_ui.gif)


### alter class
#### 建立尚未繼承的class `Person`
```sql
create class Person
```
![Create Class](/images/orientdb-sql-api/create_class.gif)
#### 修改`Person`繼承至`V`
```sql
alter class Person superclass V
```
![Alter Superclass](/images/orientdb-sql-api/alter_superclasss.gif)

### abstract
#### 建立抽象類別
```sql
create class Vehicle extends V abstract
```

#### 新增一筆資料至抽象類別將發生錯誤
```sql
insert into Vehicle set name = "My Car"
```
![Insert Abstract Error](/images/orientdb-sql-api/insert_abstract_error.png)

#### 再建立一個類別`Car`繼承自抽象類別`Vehicle`
```sql
create class Car extends Vehicle
```
![Extends Abstract](/images/orientdb-sql-api/extends_abstract.png)

#### 新增一筆資料至`Car`類別
```sql
insert into Car set name="Toyota"
```

#### 替`Person`類別建立一個`property`
```sql
create property Person.name string
```

#### 修改`Person`中`name`的property為必填
```sql
alter property Person.name mandatory true
```

#### 嘗試新增一筆`property`為`age`的紀錄將發生錯誤, 因為`name`設定為必填
```sql
insert into Person set age = 10
```
![Insert Mandatory Error](/images/orientdb-sql-api/insert_mandatory_error.png)

#### 重新新增一筆包含`name`的資料
```sql
insert into Person content {"name": "Charlie", "age": 10}
```

### Cluster
- 一個class可以對應至多個cluster
- 查詢時可以指定某個cluster進行查詢

#### 創建Cluster
```sql
create cluster USA
create cluster Europe
```

#### 修改Cluster壓縮類型
```sql
alter cluster Europe compression gzip
```

#### 將`Person`加入`USA`及`Europe` cluster
```sql
alter class Person addcluster USA
alter class Person addcluster Europe
```

#### 對某個`cluster`進行查詢
```sql
select from cluster:Europe
```

### sql functions

* `out`: 獲得從當前記錄為頂點開始向外的相鄰頂點，應取得company的id
```sql
select out(WorkAt) as companyId from Person
```

* `in`: 獲得從當前記錄為頂點開始向內的相鄰頂點
```sql
select in(WorkAt) as personId from Company
```

* `both`: 獲得從當前記錄為頂點開始向內向外的相鄰頂點
```sql
select both() from Person
```

* `outE`: 獲得從當前記錄為頂點開始向外的相鄰邊，應取得WorkAt的id
```sql
select outE() from Person
```

* `inE`: 獲得從當前記錄為頂點開始向內的相鄰邊
```sql
select inE() from Person
```

* `bothE`: 獲得從當前記錄為頂點開始向內向外的相鄰邊
```sql
select bothE() from Person
```

* `outV`: 查詢從當前記錄為某個邊由外向內的頂點
```sql
select outV() from WorkAt
-- Person - WorkAt -> Company 結果為person id
```

* `inV`: 查詢
```sql
select inV() from WorkAt
-- Person - WorkAt -> Company 結果為company id
```