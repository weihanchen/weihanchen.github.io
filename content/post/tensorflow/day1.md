---
title: "Day1"
date: 2018-04-20T17:04:26+08:00
categories: [tensorflow]
draft: true
---

Start with Tensorflow Day1

<!--more-->

## Tensorflow 版本
選擇其中一種進行安裝
* CPU support only: 如果系統未俱備NVIDIA® GPU則必須安裝此版本。
* GPU Support: 效能較高但安裝較為複雜，以下安裝先略過GPU的部份。



## 決定如何安裝Tensorflow
* [Virtualenv](https://www.tensorflow.org/install/install_linux#InstallingVirtualenv)
* ["native" pip](https://www.tensorflow.org/install/install_linux#InstallingNativePip)
* [Docker](https://www.tensorflow.org/install/install_linux#InstallingDocker)
* [Anaconda](https://www.tensorflow.org/install/install_linux#InstallingAnaconda)

### 這裡將採取Docker安裝方式
* [安裝Docker](https://docs.docker.com/install/)
* [建立docker group](https://docs.docker.com/install/linux/linux-postinstall/)
* [如果需要安裝GPU版本請先安裝nvidia-docker](https://github.com/NVIDIA/nvidia-docker)
* 下載[Tensorflow image](https://hub.docker.com/r/tensorflow/tensorflow/tags/)
```bash
docker pull tensorflow/tensorflow
```

### Run with docker container

```sh
docker run -it -p 8888:8888 tensorflow/tensorflow
```

運行後出現以下畫面
![run container](/images/tensorflow/run_container.png)

接著我們根據console output中的網址，複製並貼上至browser
```sh
to login with a token:
        http://localhost:8888/?token=35cee0e9084dda314162294a2509cb37c6ddea7e02540827
```


### 測試簡單的Tensorflow程式
1. New Python Project
![New Python Project](/images/tensorflow/new_project.png)

2. Paste Code
![Python Edit](/images/tensorflow/python_edit.png)

3. Code
```python
import tensorflow as tf # 引入tensorflow套件並簡寫為tf   
matrix1 = tf.constant([1, 2, 3, 4, 5, 6, 7, 8, 9 ], shape=[3, 3]) #宣告 3 * 3 的矩陣 e.g [[1, 2, 3] ,[4, 5, 6], [7, 8, 9]]
matrix2 = tf.constant([1, 2, 3, 4, 5, 6, 7, 8, 9 ], shape=[3, 3]) #宣告 3 * 3 的矩陣 e.g [[1, 2, 3] ,[4, 5, 6], [7, 8, 9]]
product = matrix1 * matrix2  #建立運算圖
# 啟動運算
sess = tf.Session() 
result = sess.run(product)    
print (result)
```

4. Result
![Python Result](/images/tensorflow/python_result.png)