---
title: "Nodejs worker threads"
date: 2020-01-12T15:09:37+08:00
categories: [nodejs]
draft: true
---

<!--more-->

# 試玩 nodejs-worker-threads

早期的 nodejs 為了具有多線程的能力而引入了 cluster 模組, 但這種創建線程的方式會犧牲共享內存, 且數據通信必須透過 json 來傳輸, 因此具有一定的侷限性及性能問題。

而後發展了`worker-threads`這個模組之後, 具備共享內存的功能, 使其更輕量。

nodejs 在`v10.5.0`時引入了新的模組`worker_threads`, 但當時還處於實驗階段, 因此執行程式時需加入參數`--experimental-worker`才能正確引入該模組, 不過以下實驗採用`v12.7.0`, 已經不需要額外參數`--experimental-worker`來開啟模組開關了。

## 架構

以下的架構圖中, 將從 main.js 中分派可並行的工作給 worker.js 去進行執行, 而 worker.js 在 nodejs 背後的機制相當於 multi threads。

             | ->  worker.js
    main.js -| ->  worker.js
             | ->  worker.js

## main 與 worker 之間的資料傳遞

1. 傳遞數據的方式: `worker.postMessage(value)`。
2. 接收對方傳遞數據的方式: `worker.on('message', callbackFn)`。

main.js:

    const worker = new Worker('./worker.js');
    
    // 傳遞資料給worker
    worker.postMessage('send to worker');
    // 監聽: 接收worker回報的資料
    worker.on('message', msg => {
        console.info(msg);
    });

worker.js

    import { parentPort } from 'worker_threads';
    parentPort.on('message', value => {
        console.info(value);
        parentPort.postMessage('report to master');
    });

## 實驗

以下範例將實驗相同的運算之下使用單線程與多線程所耗費的時間比較。

題目: 我們會設計有 N 個 worker, 每個 worker 執行 X 次的累加, 每次的累加數字為 Y。

1. 參數配置:

    // 假設8個worker
    const workerNum: number = 8;
    // 每個worker都做10億次的累加
    const perWorkerAccSize: number = 1000000000;
    // 每次的累加數字8
    const perAccNum: number = 8;

2. 首先我們設計一個累加的函數, 可帶入數字及累加的次數。

    const accumulate = (num: number, size: number): number => {
        let result: number = 0;
        for (let i = 0; i < size; i++) {
            result += num;
        }
        return result;
    };

3. 接著我們撰寫單線程的程式:

    (() => {
        console.info('start accmulate with single...');
        const size = workerNum * perWorkerAccSize;
        console.info(`do ${size} number to accumulate`);
        const start = new Date().getTime();
        const sum = accumulate(perAccNum, size);
        const end = new Date().getTime();
        console.info(`sum: ${sum}, time: ${end - start}`);
    })();

4. 設計分派的程式:

    /**
     * 分派工作
     * @param workerNum 工人數量
     * @param accNum 每次加總的數字
     * @param size 加總的次數
     */
    const accWithWorker = async (workerNum: number, accNum: number, size: number): Promise<number> =>
        new Promise((resolve, reject) => {
            // 紀錄工作做完的次數
            let doingCount = 0;
            // 總共做完的工作數量
            const doneCount = workerNum;
            // 加總的最終數量
            let sum = 0;
            while (--workerNum >= 0) {
                console.info(`worker ${workerNum}, do ${size} number to accumulate`);
                const worker = new Worker('./dist/worker.js');
                // 傳遞加總的數字及次數給worker
                worker.postMessage({
                    accNum,
                    size
                });
                // 監聽: worker回報的加總結果
                worker.on('message', num => {
                    sum += num;
                    if (++doingCount === doneCount) {
                        resolve(sum);
                    }
                });
            }
        });

5. 接著最後我們設計每個worker進行加總的工作。

    import { parentPort } from 'worker_threads';
    parentPort.on('message', (value) => {
        const { accNum, size} = value;
        parentPort.postMessage(accumulate(accNum, size));
    });
    
    const accumulate = (num: number, size: number): number => {
        let result: number = 0;
        for (let i = 0; i < size; i++) {
            result += num;
        }
        return result;
    };

## 運行結果

可以發現到我們開8個worker進行處理, 時間節省了1/3。

    start accmulate with single...
    do 8000000000 number to accumulate
    sum: 64000000000, time: 9224
    start accmulate with 8 worker...
    worker 7, do 1000000000 number to accumulate
    worker 6, do 1000000000 number to accumulate
    worker 5, do 1000000000 number to accumulate
    worker 4, do 1000000000 number to accumulate
    worker 3, do 1000000000 number to accumulate
    worker 2, do 1000000000 number to accumulate
    worker 1, do 1000000000 number to accumulate
    worker 0, do 1000000000 number to accumulate
    sum: 64000000000, time: 2464