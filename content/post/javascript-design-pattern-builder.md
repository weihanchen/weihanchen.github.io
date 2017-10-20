---
title: "Javascript Design Pattern Builder"
date: 2017-03-28T17:09:37+08:00
categories: [javascript]
draft: true
---

Builder模式主要在同樣的建構過程中創建不同的表示，也就是說不必事先定義方法內容，透過建造者模式在適當時機進行建造，在javascript語言中則使用callback方式完成，主要目的是職責分離。

```javascript
function counter(name,timeEnd, callback) { //定義一個counter方法，目的當timeEnd到指定的數值時進行builder所創建的工作
    var timespan = 1000;
    var myTimer = setInterval(timer, timespan);
    function timer() {
         timeEnd -= timespan
         var output = (timeEnd / timespan) + '...';
         console.log(name + '剩下：' + output + '秒');
         if (timeEnd <= 0) {
              callback();
              clearInterval(myTimer);
         }
    }
   
}
function doWork() {
    console.log('doWork');
}
function doEat(){
     console.log('doEat');
}
//A、B分別使用兩個計時器，3秒後吃飯，10秒後工作
counter('A',3000, doEat);
counter('B',10000, doWork);
```