---
title: "Export、Import 模組"
date: 2020-01-12T20:09:37+08:00
categories: [es6]
draft: true
---

撰寫中...

<!--more-->

ES6的模組概念主要是將一個大程序拆成小組件, 需要時再取相關組件來拼裝, 如此一來可以降低系統之間的複雜度, 而一個組件就相當於一個檔案, 每個檔案要對外輸出的類別、方法及引入的方式就是藉由以下兩種方式：
* export: 做為模組對外輸出, 放於檔案最後。
* import: 做為引入其他模組的功能, 放於檔案最前面。

## 基本的輸出
* 物件、類別、方法、常數...都可以輸出。
* 也可以用別名來隱藏內部細節。

```javascript
const str = "test";
class Person {
    private name;
    constructor() {} 
}

export { Person, str as strTest }
```

## 輸入
* 使用大括號`{}`引入相關的類別、方法...
* 使用萬用字元`*`引入所有類別、方法...到某個變數。

```javascript
import { Person, strTest } from './person';

import * as p from './person';

console.log(p.Person);
console.log(p.strTest);
```

## 關於`export default`的輸入與輸出
* 主要是作為一個js檔案的唯一輸出口。
* 輸入時可以指定任意名稱。
* 可以隱藏內部的細節。
* 輸入與輸出都不必加上`{}`了。
* 一個模組(檔案)只能有一個輸出。

```javascript
// 檔名: export.js
class Person {
    private name;
    constructor() {}
}

export default Person;

// 輸入時
import P from './export';
```