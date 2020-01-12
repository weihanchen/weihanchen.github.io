---
title: "Nodejs Cluster"
date: 2020-01-12T17:09:37+08:00
categories: [nodejs]
draft: true
---


<!--more-->


# cluster

由於Javascript本身設計就適合於單線程的應用, 但一般後端應用程式都會支援多個服務來處理client的請求, nodejs中也提供了`cluster`模組來達成此功能。

原理: `cluster`中會建立一個主程序(master)及N個子程序(worker), 並由master統一監聽客戶端的請求, 也就是說對外只有一個`port`, 並根據資源狀況分配請求給`worker`。

## 如何實做?

根據系統的cpu數量建立N個worker來進行處理。

    // server.js
    const cluster = require('cluster');
    const cpuNums = require('os').cpus().length;
    const http = require('http');
    if (cluster.isMaster) {
        console.info(`cpu: ${cpuNums}`);
        for (var i = 0; i < cpuNums; i++) {
            cluster.fork();
        }
    } else {
        http.createServer(function(req, res) {
            res.end(`response from worker ${process.pid}`);
        }).listen(5555);
        console.log(`Worker ${process.pid} started`);
    }

建立測試腳本

    for ((i = 1; i <= 8; i++)); do
        curl http://127.0.0.1:5555
        echo ""
    done

輸出如下, 可以看到response來自不同的worker:

    response from worker 7872
    response from worker 7878
    response from worker 7886
    response from worker 7893
    response from worker 7853
    response from worker 7860
    response from worker 7855
    response from worker 7866

## master、worker如何通訊?

master透過`cluster.fork()`來建立worker。

`cluster.fork()`內部是藉由`child_process.fork()`來建立。

## 如何將請求分發到多個worker

每個worker建立時都會於master上註冊並建立IPC通道, 而客戶端請求到達時, master會負責將請求分配給worker。

這裡可能會有疑問是這些請求是如何被分配的?採取什麼策略?

預設的分配策略是輪詢的方式, 當請求到達時, master會輪詢一遍worker列表, 看誰有空閒就將請求分配給該worker進行處理。

另外也支援`無分配策略`但這種方式可能會造成搶食現象的競爭問題。

可以透過環境變數`NODE_CLUSTER_SCHED_POLICY`設定, 也可以在`cluster.setupMaster(options)`時傳入。

## process之間的通訊

由於各個process無法共享資源, 但可以藉由IPC通訊方式讓master與worker之間進行通信, 基本用法如下:

    // worker 發送訊息
    process.send('讀取訊息');
    
    // master 接收消息 -> 處理 -> 回應
    cluster.on('online', function (worker) {
         // worker建立時，開始監聽message事件
         cluster.workers[id].on('message', function(data) {
              // 處理來自worker發送的資料
              // 回傳給worker
              cluster.workers[id].send('result')
         });
    });