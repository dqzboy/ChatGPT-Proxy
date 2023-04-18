## 一、为啥需要自建反代
OpenAI提供了两种访问方式，一种是直接在ChatGPT网页端使用的Access Token方式，这种方式可以免费使用GPT-3.5模型，只需要登录即可使用。但缺点是不稳定，且无法扩展。另一种是使用API，注册用户可以获得5美元的赠送额度，但使用完之后就需要付费。这种方式相对更稳定，但缺点是赠送额度较少且存在限流，目前是3条/分钟。

因此，对于那些希望免费使用OpenAI GPT-3.5模型的用户来说，选择Access Token方式是比较好的选择。但是需要解决的问题是不稳定以及可能IP被封禁的问题。为了解决这些问题，我们可以自建反向代理服务来提高稳定性，并保护我们的IP地址不被OpenAI封禁。也有一些公共的反向代理服务可以选择使用，但是很不稳定，因为它们是免费共享的。所以自建反向代理服务是一个不错的选择

## 二、所需环境组件安装
### 1、环境说明
- 一台VPS，规格最低配 1C1G(项目作者文档里作了说明)
- 可以访问到openai地址;或者国内服务器实现科学上网也可以，可以参考这篇文章[国内服务器实现科学上网](https://www.dqzboy.com/13754.html)
- 部署docker和docker-compose
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
mkdir /data/docker
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

## 1、创建工作目录
```shell
mkdir -p /data/go-chatgpt-api && cd $_
```
## 2、创建部署清单
- 同时使用ChatGPT和API 模式
  - 如果你的VPS IP没有被Ban就使用这个模式
```shell
vim docker-compose.yml

services:
  go-chatgpt-api:
    container_name: go-chatgpt-api
    image: linweiyuan/go-chatgpt-api
    ports:
      - 8080:8080  # 容器端口映射到宿主机8080端口；宿主机监听端口可按需改为其它端口
    environment:
      - GIN_MODE=release
      - CHATGPT_PROXY_SERVER=http://chatgpt-proxy-server:9515
#      - NETWORK_PROXY_SERVER=http://host:port     # NETWORK_PROXY_SERVER：科学上网地址
#      - NETWORK_PROXY_SERVER=socks5://host:port
    depends_on:
      - chatgpt-proxy-server
    restart: unless-stopped

  chatgpt-proxy-server:
    container_name: chatgpt-proxy-server
    image: linweiyuan/chatgpt-proxy-server
    restart: unless-stopped
```

- 基于Cloudflare WARP模式
  - 解决IP被Ban，提示Access denied之类的报错
  - Cloudflare WARP官网文档：https://developers.cloudflare.com/warp-client/get-started/linux
```shell
vim docker-compose.yml

services:
  go-chatgpt-api:
    container_name: go-chatgpt-api
image: linweiyuan/go-chatgpt-api
    ports:
      - 8080:8080  # 容器端口映射到宿主机8080端口；宿主机监听端口可按需改为其它端口
    environment:
      - GIN_MODE=release
      - CHATGPT_PROXY_SERVER=http://chatgpt-proxy-server:9515
      - NETWORK_PROXY_SERVER=socks5://chatgpt-proxy-server-warp:65535
    depends_on:
      - chatgpt-proxy-server
      - chatgpt-proxy-server-warp
    restart: unless-stopped

  chatgpt-proxy-server:
    container_name: chatgpt-proxy-server
    image: linweiyuan/chatgpt-proxy-server
    restart: unless-stopped

  chatgpt-proxy-server-warp:
    container_name: chatgpt-proxy-server-warp
    image: linweiyuan/chatgpt-proxy-server-warp
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
```shell
# 查看容器日志是否运行正常
docker logs -f chatgpt-proxy-server
docker logs -f go-chatgpt-api
```
![image](https://user-images.githubusercontent.com/42825450/232587635-027df223-723d-4191-a02b-0a1eb66f5414.png)
![image](https://user-images.githubusercontent.com/42825450/232587649-04f9f1ca-bea9-4778-afc7-1d6c94118464.png)

## 四、项目使用自建反代
> 现在我们可以找一个项目，使用access token模式，并使用我们自建的代理地址进行访问；自建IP的访问地址为http://<vps-ip>:8080/conversation；如果项目与反代服务同在一台VPS上，则反代地址直接http://127.0.0.1:8080/conversation
- access token获取：https://chat.openai.com/api/auth/session
![image](https://user-images.githubusercontent.com/42825450/232587811-056556cf-f861-44ca-ad0d-ed2cc819a950.png)

- 现在我们访问chatgpt-web，查看是否可以正常使用
![image](https://user-images.githubusercontent.com/42825450/232588137-51b1bfa3-9cca-4141-8fd1-4c97004b2b7e.png)

- 同样日志返回结果正常
![image](https://user-images.githubusercontent.com/42825450/232587904-23285b15-2133-4a35-abc0-0c6ad41f1dec.png)


## ChatGPT WEB项目一键部署脚本
[chatgpt-web一键部署脚本](https://github.com/dqzboy/ShellProject/tree/main/ChatGPT)

