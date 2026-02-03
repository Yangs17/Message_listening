# Message listening

#### 介绍
主要用于各类消息的中转发送，方便终端远程控制服务器数据收发跟处理
当前已完成 本地收发TG bot 信息 
后续可以扩展mqtt  what's app 飞书等

#### 程序文件说明

<img width="635" height="193" alt="image" src="https://github.com/user-attachments/assets/bb243d74-cab1-40ee-9c35-09a7f445e592" />


#### 安装教程

直接docker部署即可，v2ray-linux-64.zip因为下载比较慢，
我这边是直接下载下来安装，用来解析vmess，如果网络环境好的可以自行更改外部Dockerfile文件

另外根目录下必须放一个logs空文件夹

<img width="509" height="272" alt="image" src="https://github.com/user-attachments/assets/c62d91e7-a95e-473e-818d-1c501b74b87b" />


#### 使用说明

首先需要注册一个TG机器人，可自行搜索。

tg_bot 中 Dockerfile  main.py           

1.这里两个文件的两个端口需要一致
2.主要是对v2ray的镜像进行暴露，用于镜像间的数据收发
3.TG机器人的逻辑处理详见main.py，可自行修改，可接脚本或大模型等
4.当前有用例Hello 回复Hi ,以及回复订阅信息
5.其他所有配置信息均在.env 文件中，需要自行更改

后续扩展可以用HTTP / HTTPS / MQTT 对接 tg_bot上main.c做转发，实现任一终端发送数据到TG上


实现效果
1.可在TG上实现机器人自动对话触发远程服务器，
2.远程服务器可随时发送内容到TG上，实现对话框控制
<img width="408" height="408" alt="image" src="https://github.com/user-attachments/assets/cffd92f8-6878-4e8e-9fab-0fc70c6ee195" />


#### 参与贡献

1.  Fork 本仓库
2.  新建 Feat_xxx 分支
3.  提交代码
4.  新建 Pull Request





