---
title: "Set物件"
date: 2017-03-28T19:09:37+08:00
categories: [es6]
draft: true
---

<!--more-->

一般程式語言我們常常用到Set來幫我們紀錄集合中是否具有重複的元素, 而javascript也提供了Set API。

## 常用的方法

* `add(value)`: 加入元素到集合內
* `delete(value)`: 從集合內刪除元素
* `clear()`: 清除集合內所有元素
* `has(value)`: 檢查集合內是否已經存在該元素


## 應用場景

### session機制: 檢查用戶是否登入中

```javascript
const sessionSet = new Set();

sessionSet.add('john');
sessionSet.add('mark');

const checkLogin = (user) => sessionSet.has(user);

checkLogin('wang'); // false
checkLogin('mark'); // true
```

### 去除陣列中重複值

#### 傳統作法

```javascript
function has(arr, num) {
    let exists = false;
    for (let i = 0; i < arr.length; i++) {
        const compare = arr[i];
        if (compare === num) {
            exists = true;
            break;
        }
    }
    return exists;
}
const arr = [1,2,2,3,3,3];
let cleanedArr = [];
for (let i = 0; i < arr.length; a++) {
    const num = arr[i];
    if (!has(arr, num)) {
        cleanedArr = cleanedArr.concat(num);
    }
}
```

#### es6作法

```javascript
const arr = [1,2,2,3,3,3];
const cleanedArr = [...new Set(arr)];// [1, 2, 3]
```