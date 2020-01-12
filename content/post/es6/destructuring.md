---
title: "解構賦值 Destructuring Assignment"
date: 2020-01-12T18:09:37+08:00
categories: [es6]
draft: true
---

<!--more-->

ES6的解構賦值是一種非常便利的語法糖果, 可以想像成分解一個物品再套入到新的集合, 取值的部分不需要多餘的轉換, 讓程式碼更加簡潔。

## 概念
* 主要從object、array這類的集合提取值再指定到新的變數。
* 原本只能藉由迴圈來取值, 且要藉由index條件來中止, 使用起來較不便利。

```javascript
const [ code, body ] = [200, { "message": "ok"}]

console.log(code); // 200
console.log(body); 
// {
//     "message": "ok"
// }

// 物件的解構賦值
const { user, password } = { "user": "john", "password": "123" };

console.log(user); // john
console.log(password);// 123
```

## 應用

### swap功能, 交換兩個變數時

原本我們需要這樣

```javascript
let a = 1;
let b = 2;
let tmp = a;
a = b;
b = tmp;
```

用es6可以這樣

```javascript
let a = 1;
let b = 2;
[a, b] = [b, a];
```

### 設計一個function接收多個參數值時

```javascript
const sum = (...params) => {
    console.log(params); // [1,2,3,4.......more];
    return params.reduce((r, p) => r + p, 0);
}
```