---
title: "Javascript Design Pattern Factory"
date: 2017-03-29T17:09:37+08:00
categories: [nodejs]
draft: true
---

<!--more-->

工廠模式就是負責來生產東西的，裡面當然包含著生產流程及各產品的生產方法，而該工廠則根據訂單生產不同類型的產品

#### 以下範例以生產巧克力為例，假設該工廠根據訂單生產出不同類型的巧克力棒、巧克力磚...等
- 客人是接洽工廠的人
- 客人只想看到成品不管生產過程
- 工廠接單後內部決定如何生產

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