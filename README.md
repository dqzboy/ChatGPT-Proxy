<div align="center">
<br>
  <p align="center">
  <img src="https://user-images.githubusercontent.com/42825450/233398049-0456e5f8-c36e-42fa-a933-2fb640bdf714.png" width="150px" height="150px">
  </p>

[![Typing SVG](https://readme-typing-svg.herokuapp.com?font=Handlee&center=true&vCenter=true&width=500&height=60&lines=This+is+chat+gpt+proxy+service.)](https://git.io/typing-svg)

<img src="https://camo.githubusercontent.com/82291b0fe831bfc6781e07fc5090cbd0a8b912bb8b8d4fec0696c881834f81ac/68747470733a2f2f70726f626f742e6d656469612f394575424971676170492e676966"
width="1800"  height="3">

</div>


## 一、为啥需要自建反代
OpenAI提供了两种访问方式，一种是直接在ChatGPT网页端使用的Access Token方式，这种方式可以免费使用GPT-3.5模型，只需要登录即可使用。但缺点是不稳定，且无法扩展。另一种是使用API，注册用户可以获得5美元的赠送额度，但使用完之后就需要付费。这种方式相对更稳定，但缺点是赠送额度较少且存在限流，目前是3条/分钟。

因此，对于那些希望免费使用OpenAI GPT-3.5模型的用户来说，选择Access Token方式是比较好的选择。但是需要解决的问题是不稳定以及可能IP被封禁的问题。为了解决这些问题，我们可以自建反向代理服务来提高稳定性，并保护我们的IP地址不被OpenAI封禁。也有一些公共的反向代理服务可以选择使用，但是很不稳定，因为它们是免费共享的。所以自建反向代理服务是一个不错的选择

> 如果部署或者配置过程出现问题或不懂的地方，请先搜索历史[issue](https://github.com/dqzboy/ChatGPT-Proxy/issues)或者加[TG交流群](https://t.me/+ghs_XDp1vwxkMGU9)

## 二、所需环境组件安装
> **如果自己安装觉得麻烦，可以使用我提供的一键部署脚本！滑动至底部有脚本安装命令。** 脚本目前已实现基础环境安装、所需组件依赖部署、镜像版本自动更新、403|401|429检测邮箱告警等功能！
### 1、环境说明
- 一台VPS，规格最低配 1C1G；**注意**：warp不支持arm架构的机器
- VPS可以正常访问 [chatgpt](https://chat.openai.com)；或者国内服务器实现科学上网也可以
  - 参考这篇文章[国内服务器实现科学上网](https://www.dqzboy.com/13754.html)
  - 目前个人使用的机场：[机场1按量不限时，解锁ChatGPT](https://mojie.me/#/register?code=CG6h8Irm) \ [机场2按周期，解锁ChatGPT](https://teacat.cloud/#/register?code=ps4sZcDa) 
- 部署docker和docker-compose

> 特别说明：目前这个项目，经过多个版本迭代之后比较稳定；目前可以一个服务多人共用

### 2、部署docker
- 设置一个yum源，下面两个都可用
```shell
# 中央仓库
yum-config-manager --add-repo http://download.docker.com/linux/centos/docker-ce.repo

# 阿里仓库
yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo

# 安装docker
yum -y install docker-ce

# 启动并设置开机自启
systemctl start docker
systemctl enable docker
systemctl status docker
```

### 3、部署docker-compose
```shell
（1）定义Docker-Compose版本变量
export composeVer=v2.16.0

（2）下载最新版本的 docker-compose 到 /usr/bin 目录下
curl -L https://github.com/docker/compose/releases/download/${composeVer}/docker-compose-`uname -s`-`uname -m` -o /usr/bin/docker-compose

（3）给 docker-compose 授权
chmod +x /usr/bin/docker-compose

（4）检查docker-compose安装情况
docker-compose -v
```

## 三、部署ChatGPT反代
- 这里使用的chatGPT反代项目：[linweiyuan/go-chatgpt-api](https://github.com/linweiyuan/go-chatgpt-api)
- 目前已经支持多次对话
## 1、创建工作目录
```shell
mkdir -p /data/go-chatgpt-api && cd $_
```
## 2、创建部署清单
> GPT-4 相关模型目前需要验证 arkose_token，如果配置 GO_CHATGPT_API_ARKOSE_TOKEN_URL 则使用在线服务获取 arkose_token ，不设置或者留空则由程序内部自己生成
### 服务器直连或通过代理可正常访问ChatGPT
  - 如果你的VPS IP稳定，或者你使用的科学上网地址稳定，那就首选这种方式
```shell
vim docker-compose.yml

version: "3" 
services:
  go-chatgpt-api:
    container_name: go-chatgpt-api
    image: linweiyuan/go-chatgpt-api
    ports:
      - 8080:8080         # 容器端口映射到宿主机8080端口；宿主机监听端口可按需改为其它端口
    #network_mode: host   # 可选，将容器加入主机网络模式，即与主机共享网络命名空间；上面的端口映射将失效
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
    environment:
      - TZ=Asia/Shanghai
      - GO_CHATGPT_API_PROXY=   # GO_CHATGPT_API_PROXY=：可配置科学上网代理地址，例如：http://clash_vpsIP:7890；注释掉或者留空则不启用
      - GO_CHATGPT_API_PANDORA=
      - GO_CHATGPT_API_ARKOSE_TOKEN_URL=
      - GO_CHATGPT_API_OPENAI_EMAIL=
      - GO_CHATGPT_API_OPENAI_PASSWORD=
    restart: unless-stopped
```

### 基于Cloudflare WARP模式
  - 解决IP被Ban，提示Access denied之类的报错
  - 如果使用此模式还是提示Access denied，大概率是你机器IP不干净或者用的国内服务器导致验证码过不去
  - Cloudflare WARP官网文档：https://developers.cloudflare.com/warp-client/get-started/linux
```shell
vim docker-compose.yml

version: "3"
services:
  go-chatgpt-api:
    container_name: go-chatgpt-api
    image: linweiyuan/go-chatgpt-api
    ports:
      - 8080:8080         # 容器端口映射到宿主机8080端口；宿主机监听端口可按需改为其它端口
    #network_mode: host   # 可选，将容器加入主机网络模式，即与主机共享网络命名空间；上面的端口映射将失效
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
    environment:
      - TZ=Asia/Shanghai
      - GO_CHATGPT_API_PROXY=socks5://chatgpt-proxy-server-warp:65535
      - GO_CHATGPT_API_PANDORA=
      - GO_CHATGPT_API_ARKOSE_TOKEN_URL=
      - GO_CHATGPT_API_OPENAI_EMAIL=
      - GO_CHATGPT_API_OPENAI_PASSWORD=
    depends_on:
      - chatgpt-proxy-server-warp
    restart: unless-stopped

  chatgpt-proxy-server-warp:
    container_name: chatgpt-proxy-server-warp
    image: linweiyuan/chatgpt-proxy-server-warp
    environment:
      - LOG_LEVEL=OFF
    restart: unless-stopped
```

### 3、运行容器服务
```shell
docker-compose up -d

# 检查运行的容器；确保容器状态为UP
docker ps

# 检测容器映射到宿主机的监听端口是否监听
ss -tnlp|grep 8080
```

### 4、检查是否正常
- go-chatgpt-api需要初始化启动需要耐心等待
```shell
# 查看容器日志是否运行正常
docker logs -f go-chatgpt-api
```

- 出现下图中 `Service go-chatgpt-api is ready.` 则表示服务可正常使用了

<img src="https://github.com/dqzboy/ChatGPT-Proxy/assets/42825450/081886e0-72e8-44b5-954f-e122efcedfcb" width="800px">

### 5、容器镜像更新
```shell
# 停止
docker-compose down

# 拉取新镜像
docker-compose pull

# 启动
docker-compose up -d
```

## 四、项目接入自建反代
### 接口更新
- 原接口： http://go-chatgpt-api:8080/chatgpt/conversation
- 更新后： http://go-chatgpt-api:8080/chatgpt/backend-api/conversation

### 项目：[Chanzhaoyu/chatgpt-web](https://github.com/Chanzhaoyu/chatgpt-web) | [Kerwin1202/chatgpt-web](https://github.com/Kerwin1202/chatgpt-web)
#### **ChatGPTUnofficialProxyAPI(accessToken)**
- 现在我们可以找一个项目，使用access token模式，并使用我们自建的代理地址进行访问；
  - 自建IP的访问地址为http://vps-ip:8080/chatgpt/backend-api/conversation
  - 如果前端项目是直接跑的并且与反代服务同在一台VPS上，则反代地址可写成：http://127.0.0.1:8080/chatgpt/backend-api/conversation
  - 如果你前端项目是容器启的并且与反代服务同在一台VPS上，则反代地址可写成：http://go-chatgpt-api:8080/chatgpt/backend-api/conversation

- access token获取：https://chat.openai.com/api/auth/session
```shell
API_REVERSE_PROXY=http://127.0.0.1:8080/chatgpt/backend-api/conversation
```

- 现在我们访问chatgpt-web，查看是否可以正常使用
<img src="https://user-images.githubusercontent.com/42825450/236637545-5b121bf1-79c4-4985-87cb-b64bd23ba453.gif" width="800px">

- 同样日志返回请求结果正常
<img src="https://user-images.githubusercontent.com/42825450/236637560-ae2baf1f-69ed-423e-b4d8-4700aedee3e4.png" width="800px">

#### **ChatGPTAPI(APIKEY)**
- 使用ChatGPTAPI模式，并使用我们自建的代理地址进行访问；
  - 自建IP的访问地址为http://vps-ip:8080/platform  
  - 如果前端项目是直接跑的并且与反代服务同在一台VPS上，则反代地址可写成：http://127.0.0.1:8080/platform
  - 如果你前端项目是容器启的并且与反代服务同在一台VPS上，则反代地址可写成：http://go-chatgpt-api:8080/platform
```shell
OPENAI_API_BASE_URL=http://127.0.0.1:8080/platform
```
<img src="https://github.com/dqzboy/ChatGPT-Proxy/assets/42825450/aa93dd61-ab4d-4e56-9677-d86d8287eab9" width="800px">

### 项目：[chatgpt-mirai-qq-bot](https://github.com/lss233/chatgpt-mirai-qq-bot)
```shell
browserless_endpoint = "http(s)://你的服务/chatgpt/backend-api/"
```
### 项目：[moeakwak/chatgpt-web-share](https://github.com/moeakwak/chatgpt-web-share)
```shell
CHATGPT_BASE_URL = "http(s)://你的服务/chatgpt/backend-api/"
```
### 项目：[Yidadaa/ChatGPT-Next-Web](https://github.com/Yidadaa/ChatGPT-Next-Web)
- 接口：http://go-chatgpt-api:8080/imitate/v1/chat/completions  利用 accessToken 模拟 apiKey，实现伪免费使用 API ，从而支持仅支持 apiKey 调用的第三方客户端项目
```shell
http://go-chatgpt-api:8080/imitate
```
<img src="https://github.com/dqzboy/ChatGPT-Proxy/assets/42825450/d834ea2f-a56e-45bf-a540-57f88afbefcd" width="800px">


## 五、总结
> 目前部署发现，只要确保节点稳定或者国内服务器配置的代理地址稳定，那么就可以正常使用


 ## 六、问题总结
 ### 1、ERRO[00xx] Access denied
 - 问题描述：按照步骤部署起来了，但是查看go-chatgpt-api日志提示ERRO[0015] Access denied
 - 问题原因：大概率你的VPS IP不干净或者使用的国内服务器；如果使用的代理，那么进入到容器查看下IP是啥或者更换个代理节点
 ```shell
docker exec chatgpt-proxy-server curl -x socks5://代理 ipinfo.io
 ```
 
 ### 2、Failed to handle captcha: timeout
 - 问题原因：这个错误就是处理不了验证码
 - 解决方法：重启 api 恢复正常；先 down 再 up，不能 restart
 
 ### 3、pthread_create: Operation not permitted (1)
 - 问题原因：是由于 Docker 容器的安全限制导致的，container内的root只是外部的一个普通用户权限，所以会出现这个问题
 - 问题解决：`docker-compose.yml` 添加参数 `privileged: true`
 
 ### 4、ChatGPT error 404: {"errorMessage":"[object Object]"}
 - 问题原因：如果你更新到了新版本，那么接口需要进行更改
 - 解决方法：
 ```shell
 http://127.0.0.1:8080/chatgpt/backend-api/conversation
 ```
 
 ### 5、Connection refused
 - 问题原因：accesstoken过期或者账号被封禁
 - 问题解决：重启获取新的accesstoken，或者注册新账号

 ### 6、ChatGPTUnofficialProxyAPI.sendMessage: conversationId and parentMessageId must both be set or both be undefined
 - 问题原因：有可能你是api和token同时使用，并且在同一个会话
 - 问题解决：切换新的会话；或者把会话清除掉

 ### 7、ERRO[0000] Looks like you have bean blocked
 - 问题原因：字面意思，你的VPS或者节点IP被openai封锁了，无法访问；ping通不代表就可以正常访问
 - 问题解决：（1）更换IP；（2）使用warp

## ChatGPT-Porxy一键部署脚本
- **说明**：目前脚本适用于CentOS 7\8\9、RHEL-8\9、Ubuntu、debian以及opencloudos系统；运行脚本需要确保网络环境稳定。

```shell
# CentOS
yum -y install wget
# Ubuntu
apt -y install wget

bash -c "$(wget -q -O- https://raw.githubusercontent.com/dqzboy/ChatGPT-Proxy/main/install/chatgpt-proxy.sh)"
```
<img src="https://github.com/dqzboy/ChatGPT-Proxy/assets/42825450/78b7bc85-24a5-41f4-8a1b-8b3338c51570" width="800px">


## ChatGPT WEB项目一键部署脚本
[chatgpt-web一键部署脚本](https://github.com/dqzboy/chatgpt-web)

## 推荐
更多学习教程请关注 [浅时光博客](https://www.dqzboy.com/)
