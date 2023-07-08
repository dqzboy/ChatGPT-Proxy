#!/usr/bin/env bash
#===============================================================================
#
#          FILE: chatgpt-proxy.sh
#
#         USAGE: ./chatgpt-proxy.sh
#
#   DESCRIPTION: 使用AccessToken访问ChatGPT，绕过CF验证;支持CentOS与Ubuntu
#
#  ORGANIZATION: DingQz dqzboy.com
#===============================================================================
SETCOLOR_SKYBLUE="echo -en \\E[1;36m"
SETCOLOR_SUCCESS="echo -en \\E[0;32m"
SETCOLOR_NORMAL="echo  -en \\E[0;39m"
SETCOLOR_RED="echo  -en \\E[0;31m"
SETCOLOR_YELLOW="echo -en \\E[1;33m"
GREEN="\033[1;32m"
RESET="\033[0m"

echo
cat << EOF

         ██████╗██╗  ██╗ █████╗ ████████╗ ██████╗ ██████╗ ████████╗    ██████╗ ██████╗  ██████╗ ██╗  ██╗██╗   ██╗
        ██╔════╝██║  ██║██╔══██╗╚══██╔══╝██╔════╝ ██╔══██╗╚══██╔══╝    ██╔══██╗██╔══██╗██╔═══██╗╚██╗██╔╝╚██╗ ██╔╝
        ██║     ███████║███████║   ██║   ██║  ███╗██████╔╝   ██║       ██████╔╝██████╔╝██║   ██║ ╚███╔╝  ╚████╔╝ 
        ██║     ██╔══██║██╔══██║   ██║   ██║   ██║██╔═══╝    ██║       ██╔═══╝ ██╔══██╗██║   ██║ ██╔██╗   ╚██╔╝  
        ╚██████╗██║  ██║██║  ██║   ██║   ╚██████╔╝██║        ██║       ██║     ██║  ██║╚██████╔╝██╔╝ ██╗   ██║   
         ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝    ╚═════╝ ╚═╝        ╚═╝       ╚═╝     ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝   ╚═╝   
                                                                                                         
EOF

SUCCESS() {
  ${SETCOLOR_SUCCESS} && echo "------------------------------------< $1 >-------------------------------------"  && ${SETCOLOR_NORMAL}
}

SUCCESS1() {
  ${SETCOLOR_SUCCESS} && echo "$1"  && ${SETCOLOR_NORMAL}
}

ERROR() {
  ${SETCOLOR_RED} && echo "$1"  && ${SETCOLOR_NORMAL}
}

INFO() {
  ${SETCOLOR_SKYBLUE} && echo "------------------------------------ $1 -------------------------------------"  && ${SETCOLOR_NORMAL}
}

INFO1() {
  ${SETCOLOR_SKYBLUE} && echo "$1"  && ${SETCOLOR_NORMAL}
}

WARN() {
  ${SETCOLOR_YELLOW} && echo "$1"  && ${SETCOLOR_NORMAL}
}

DOCKER_DIR="/data/go-chatgpt-api"
mkdir -p $DOCKER_DIR

MAX_ATTEMPTS=3
attempt=0
success=false


function CHECK_CPU() {
# 判断当前操作系统是否为 ARM 或 AMD 架构
if [[ "$(uname -m)" == "arm"* ]]; then
    WARN "This script is not supported on ARM architecture. Exiting..."
    exit 1
elif [[ "$(uname -m)" == "x86_64" ]]; then
    INFO "This script is running on AMD architecture."
else
    WARN "This script may not be fully compatible with the current architecture: $(uname -m)"
fi
}


text="检测服务器是否能够访问chat.openai.com"
width=75
padding=$((($width - ${#text}) / 2))

function CHECK_OPENAI() {
SUCCESS "提示"
printf "%*s\033[31m%s\033[0m%*s\n" $padding "" "$text" $padding ""
SUCCESS "END"

url="chat.openai.com"

# 检测是否能够访问chat.openai.com
echo "Testing connection to ${url}..."
if ping -c 3 ${url} &> /dev/null; then
  echo "Connection successful!"
  URL="OK"
else
  echo "Could not connect to ${url}."
  INFO "强制安装"
  read -e -p "$(echo -e ${GREEN}"Do you want to force install dependencies? (y/n)："${RESET})" force_install
fi
}


function CHECK_OS() {
if [ -f /etc/os-release ]; then
    . /etc/os-release
else
    echo "无法确定发行版"
    exit 1
fi


# 根据发行版选择存储库类型
case "$ID" in
    "centos")
        repo_type="centos"
        ;;
    "debian")
        repo_type="debian"
        ;;
    "rhel")
        repo_type="rhel"
        ;;
    "ubuntu")
        repo_type="ubuntu"
        ;;
    "opencloudos")
        repo_type="centos"
        ;;
    "rocky")
        repo_type="centos"
        ;;
    *)
        WARN "此脚本暂不支持您的系统: $ID"
        exit 1
        ;;
esac

echo "------------------------------------------"
echo "系统发行版: $NAME"
echo "系统版本: $VERSION"
echo "系统ID: $ID"
echo "系统ID Like: $ID_LIKE"
echo "------------------------------------------"
}

function CHECKFIRE() {
SUCCESS "Firewall && SELinux detection."

# Check if firewall is enabled
systemctl stop firewalld &> /dev/null
systemctl disable firewalld &> /dev/null
systemctl stop iptables &> /dev/null
systemctl disable iptables &> /dev/null
ufw disable &> /dev/null
INFO "Firewall has been disabled."

# Check if SELinux is enforcing
if [[ "$repo_type" == "centos" || "$repo_type" == "rhel" ]]; then
    if sestatus | grep "SELinux status" | grep -q "enabled"; then
        WARN "SELinux is enabled. Disabling SELinux..."
        setenforce 0
        sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
        INFO "SELinux is already disabled."
    else
        INFO "SELinux is already disabled."
    fi
fi
}

function INSTALL_PACKAGE(){
PACKAGES="lsof jq wget postfix yum-utils"

# 检查命令是否存在
if command -v yum >/dev/null 2>&1; then
    SUCCESS "安装系统必要组件"
    yum -y install $PACKAGES &>/dev/null
    systemctl restart postfix &>/dev/null
elif command -v apt-get >/dev/null 2>&1; then
    SUCCESS "安装系统必要组件"
    apt-get install -y $PACKAGES &>/dev/null
    systemctl restart postfix &>/dev/null
else
    WARN "无法确定可用的包管理器"
    exit 1
fi
}

function INSTALL_DOCKER() {
# 定义存储库文件名
repo_file="docker-ce.repo"
# 下载存储库文件
url="https://download.docker.com/linux/$repo_type"

if [ "$repo_type" = "centos" ] || [ "$repo_type" = "rhel" ]; then
    if ! command -v docker &> /dev/null;then
      while [ $attempt -lt $MAX_ATTEMPTS ]; do
        attempt=$((attempt + 1))
        ERROR "docker 未安装，正在进行安装..."
        yum-config-manager --add-repo $url/$repo_file &>/dev/null
        yum -y install docker-ce &>/dev/null
        # 检查命令的返回值
        if [ $? -eq 0 ]; then
            success=true
            break
        fi
        echo "docker安装失败，正在尝试重新下载 (尝试次数: $attempt)"
      done

      if $success; then
         SUCCESS1 ">>> $(docker --version)"
         systemctl restart docker | grep -E "ERROR|ELIFECYCLE|WARN"
         systemctl enable docker &>/dev/null
      else
         ERROR "docker安装失败，请尝试手动安装"
         exit 1
      fi
    else 
      INFO1 "docker 已安装..."
      SUCCESS1 ">>> $(docker --version)"
      systemctl restart docker | grep -E "ERROR|ELIFECYCLE|WARN"
    fi
elif [ "$repo_type" == "ubuntu" ]; then
    if ! command -v docker &> /dev/null;then
      while [ $attempt -lt $MAX_ATTEMPTS ]; do
        attempt=$((attempt + 1))
        ERROR "docker 未安装，正在进行安装..."
        curl -fsSL $url/gpg | sudo apt-key add - &>/dev/null
        add-apt-repository "deb [arch=amd64] $url $(lsb_release -cs) stable" <<< $'\n' &>/dev/null
        apt-get -y install docker-ce docker-ce-cli containerd.io &>/dev/null
        # 检查命令的返回值
        if [ $? -eq 0 ]; then
            success=true
            break
        fi
        echo "docker安装失败，正在尝试重新下载 (尝试次数: $attempt)"
      done

      if $success; then
         SUCCESS1 ">>> $(docker --version)"
         systemctl restart docker | grep -E "ERROR|ELIFECYCLE|WARN"
         systemctl enable docker &>/dev/null
      else
         ERROR "docker安装失败，请尝试手动安装"
         exit 1
      fi
    else
      INFO1 "docker 已安装..."  
      SUCCESS1 ">>> $(docker --version)"
      systemctl restart docker | grep -E "ERROR|ELIFECYCLE|WARN"
    fi
elif [ "$repo_type" == "debian" ]; then
    if ! command -v docker &> /dev/null;then
      while [ $attempt -lt $MAX_ATTEMPTS ]; do
        attempt=$((attempt + 1))

        ERROR "docker 未安装，正在进行安装..."
        curl -fsSL $url/gpg | sudo apt-key add - &>/dev/null
        add-apt-repository "deb [arch=amd64] $url $(lsb_release -cs) stable" <<< $'\n' &>/dev/null
        apt-get -y install docker-ce docker-ce-cli containerd.io &>/dev/null
	# 检查命令的返回值
        if [ $? -eq 0 ]; then
            success=true
            break
        fi
        echo "docker安装失败，正在尝试重新下载 (尝试次数: $attempt)"
      done

      if $success; then
         SUCCESS1 ">>> $(docker --version)"
         systemctl restart docker | grep -E "ERROR|ELIFECYCLE|WARN"
         systemctl enable docker &>/dev/null
      else
         ERROR "docker安装失败，请尝试手动安装"
         exit 1
      fi
    else
      INFO1 "docker 已安装..."  
      SUCCESS1 ">>> $(docker --version)"
      systemctl restart docker | grep -E "ERROR|ELIFECYCLE|WARN"
    fi
else
    ERROR "Unsupported operating system."
    exit 1
fi
}

function INSTALL_COMPOSE() {
TAG=`curl -s https://api.github.com/repos/docker/compose/releases/latest | jq -r '.tag_name'`

if ! command -v docker-compose &> /dev/null;then
ERROR "docker-compose 未安装，正在进行安装..."
while [ $attempt -lt $MAX_ATTEMPTS ]; do
    attempt=$((attempt + 1))

    wget -q "https://github.com/docker/compose/releases/download/$TAG/docker-compose-$(uname -s)-$(uname -m)" -O /usr/bin/docker-compose
    # 检查命令的返回值
    if [ $? -eq 0 ]; then
        success=true
        chmod +x /usr/bin/docker-compose
        break
    fi

    echo "docker-compose 下载失败，正在尝试重新下载 (尝试次数: $attempt)"
done

if $success; then
    chmod +x /usr/bin/docker-compose
    SUCCESS1 ">>> $(docker-compose --version)"
else
    ERROR "docker-compose 下载失败，请尝试手动安装docker-compose"
    exit 1
fi
else
   INFO1 "docker-compose 已安装..."
   chmod +x /usr/bin/docker-compose
   SUCCESS1 ">>> $(docker-compose --version)" 
fi
}

function MODIFY_PORT() {
read -e -p "$(echo -e ${GREEN}"是否修改容器映射端口号？(y/n): "${RESET})" answer

if [ "$answer" == "y" ]; then
  while true; do
    read -e -p "请输入新的端口号: " port
    # 检查输入的端口是否可用
    if lsof -i:$port >/dev/null 2>&1; then
      WARN "该端口已被占用，请重新输入！"
    else
      break
    fi
  done
  sed -i "s/- 8080:/- $port:/" ${DOCKER_DIR}/docker-compose.yml
fi
}

function CONFIG() {
mkdir -p ${DOCKER_DIR}
read -e -p "$(echo -e ${GREEN}"请输入使用的模式（api/warp）："${RESET})" mode
if [ "$mode" == "api" ]; then
cat > ${DOCKER_DIR}/docker-compose.yml <<\EOF
version: "3" 
services:
  go-chatgpt-api:
    container_name: go-chatgpt-api
    image: linweiyuan/go-chatgpt-api
    ports:
      - 8080:8080         # 容器端口映射到宿主机8080端口；宿主机监听端口可按需改为其它端口
    #network_mode: host   # 可选，将容器加入主机网络模式，即与主机共享网络命名空间；上面的端口映射将失效；clash TUN模式下使用此方法
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
    environment:
      - TZ=Asia/Shanghai
      - GO_CHATGPT_API_PROXY=    # GO_CHATGPT_API_PROXY=：可配置科学上网代理地址，例如：http://clash_vpsIP:7890；注释掉或者留空则不启用
      #http://host:port          # GO_CHATGPT_API_PROXY=：科学上网代理地址，例如：http://clash_vpsIP:7890
      #socks5://host:port        # GO_CHATGPT_API_PROXY=：科学上网代理地址，例如：socks5://clash_vpsIP:7890
      - GO_CHATGPT_API_PANDORA=
      - GO_CHATGPT_API_ARKOSE_TOKEN_URL=
      - GO_CHATGPT_API_OPENAI_EMAIL=
      - GO_CHATGPT_API_OPENAI_PASSWORD=
    restart: unless-stopped
EOF
elif [ "$mode" == "warp" ]; then
cat > ${DOCKER_DIR}/docker-compose.yml <<\EOF
version: "3"
services:
  go-chatgpt-api:
    container_name: go-chatgpt-api
    image: linweiyuan/go-chatgpt-api
    ports:
      - 8080:8080         # 容器端口映射到宿主机8080端口；宿主机监听端口可按需改为其它端口
    #network_mode: host   # 可选，将容器加入主机网络模式，即与主机共享网络命名空间；上面的端口映射将失效；clash TUN模式下使用此方法
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
EOF
else
  ERROR "Invalid or missing parameter"
  exit 1
fi

# 提示用户是否需要修改配置
read -e -p "$(echo -e ${GREEN}"Do you want to add a proxy address? (y/n)："${RESET})" modify_config
case $modify_config in
  [Yy]* )
    # 获取用户输入的URL及其类型
    read -e -p "Enter the URL (e.g. host:port): " url
    while true; do
      read -e -p "Is this a http or socks5 proxy? (http/socks5)：" type
      case $type in
          [Hh][Tt]* ) url_type="http"; break;;
          [Ss][Oo]* ) url_type="socks5"; break;;
          * ) echo "Please answer http or socks5.";;
      esac
    done
    
    # 根据类型更新docker-compose.yml文件
    if [ "$mode" == "api" ]; then
       if [ "$url_type" == "http" ]; then
	  sed -i '/- GO_CHATGPT_API_PROXY=/d' ${DOCKER_DIR}/docker-compose.yml
          sed -i "s|#http://host:port|- GO_CHATGPT_API_PROXY=http://${url}|g" ${DOCKER_DIR}/docker-compose.yml
       elif [ "$url_type" == "socks5" ]; then
	  sed -i '/- GO_CHATGPT_API_PROXY=/d' ${DOCKER_DIR}/docker-compose.yml
          sed -i "s|#socks5://host:port|- GO_CHATGPT_API_PROXY=socks5://${url}|g" ${DOCKER_DIR}/docker-compose.yml
       fi
    elif [ "$mode" == "warp" ]; then
       if [ "$url_type" == "http" ]; then
          sed -i "s|- GO_CHATGPT_API_PROXY=socks5://chatgpt-proxy-server-warp:65535|- GO_CHATGPT_API_PROXY=http://${url}|g" ${DOCKER_DIR}/docker-compose.yml
       elif [ "$url_type" == "socks5" ]; then
          sed -i "s|- GO_CHATGPT_API_PROXY=socks5://chatgpt-proxy-server-warp:65535|- GO_CHATGPT_API_PROXY=socks5://${url}|g" ${DOCKER_DIR}/docker-compose.yml
       fi
    else
       echo "Do not modify！"
    fi
    echo "Updated docker-compose.yml with ${url_type} proxy server at ${url}."
    ;;
  [Nn]* )
    WARN "Skipping configuration modification."
    ;;
  * )
    ERROR "Invalid input. Skipping configuration modification."
    ;;
esac
MODIFY_PORT

}

function Progress() {
spin='-\|/'
count=0
endtime=$((SECONDS+10))

while [ $SECONDS -lt $endtime ];
do
    spin_index=$(($count % 4))
    printf "\r[%c] " "${spin:$spin_index:1}"
    sleep 0.1
    count=$((count + 1))
done
}


function CHRCK_CONTAINER() {
# 检查 go-chatgpt-api 容器状态
status_go_chatgpt_api=$(docker container inspect -f '{{.State.Running}}' go-chatgpt-api 2>/dev/null)

# 判断容器状态并打印提示
if [[ "$status_go_chatgpt_api" == "true" ]]; then
    SUCCESS "CHECK"
    Progress
    SUCCESS1 ">>>>> Docker containers are up and running."
else
    SUCCESS "CHECK"
    Progress
    ERROR ">>>>> The following containers are not up"
    if [[ "$status_go_chatgpt_api" != "true" ]]; then
        WARN ">>> go-chatgpt-api"
    fi
fi
}

function INSTALL_PROXY() {
# 确认是否强制安装
if [[ "$force_install" = "y" ]]; then
    # 强制安装代码
    WARN "开始强制安装..."
    INSTALL_DOCKER
    INSTALL_COMPOSE
    cd ${DOCKER_DIR} && docker-compose down &>/dev/null
    CONFIG
    cd ${DOCKER_DIR} && docker-compose pull && docker-compose up -d && CHRCK_CONTAINER
elif [[ "$URL" = "OK" ]];then
    # 强制安装代码
    WARN "开始安装..."
    INSTALL_DOCKER
    INSTALL_COMPOSE
    cd ${DOCKER_DIR} && docker-compose down &>/dev/null
    CONFIG
    cd ${DOCKER_DIR} && docker-compose pull && docker-compose up -d && CHRCK_CONTAINER
else
    ERROR "已取消安装."
    exit 0
fi
}

function DEL_IMG_NONE() {
# 删除go-chatgpt-api所有处于 "none" 状态的镜像
if [ -n "$(docker images -q --filter "dangling=true" --filter "reference=linweiyuan/go-chatgpt-api")" ]; then
    docker rmi $(docker images -q --filter "dangling=true" --filter "reference=linweiyuan/go-chatgpt-api") &>/dev/null
fi
}

function ADD_IMAGESUP() {
SUCCESS "Crontab"
read -e -p "$(echo -e ${GREEN}"是否加入定时更新镜像？(y/n): "${RESET})" cron

if [[ "$cron" == "y" ]]; then
mkdir -p /opt/script/go-chatgpt-api
cat > /opt/script/go-chatgpt-api/AutoImageUp.sh << \EOF
#!/usr/bin/env bash
IMAGE_GOCHAT="linweiyuan/go-chatgpt-api"
CURRENT_VERSION=$(docker image inspect $IMAGE_GOCHAT --format='{{index .RepoDigests 0}}' | grep -o 'sha256:[^"]*')
LATEST_VERSION=$(curl -s --max-time 60 "https://registry.hub.docker.com/v2/repositories/$IMAGE_GOCHAT/tags/latest" | jq -r '.digest')

if [[ -n $CURRENT_VERSION && -n $LATEST_VERSION ]]; then
  if [ "$CURRENT_VERSION" != "$LATEST_VERSION" ]; then
    echo "go-chatgpt-api 镜像已更新，进行容器重启等操作..."
    docker pull "$IMAGE_GOCHAT"
    cd /data/go-chatgpt-api && docker-compose down && docker-compose up -d
    docker rmi $(docker images -q --filter "dangling=true" --filter "reference=$IMAGE_GOCHAT") &>/dev/null
  else
    echo "go-chatgpt-api 镜像无需更新"
  fi
else
  echo "获取Images ID失败请稍后再试！"
fi
EOF
chmod +x /opt/script/go-chatgpt-api/AutoImageUp.sh
    read -e -p "$(echo -e ${GREEN}"请输入分钟（0-59）: "${RESET})" minute
    read -e -p "$(echo -e ${GREEN}"请输入小时（0-23）: "${RESET})" hour
    read -e -p "$(echo -e ${GREEN}"请输入日期（1-31）: "${RESET})" day
    read -e -p "$(echo -e ${GREEN}"请输入月份（1-12）: "${RESET})" month
    read -e -p "$(echo -e ${GREEN}"请输入星期几（0-7，其中0和7都表示星期日）: "${RESET})" weekday

    schedule="$minute $hour $day $month $weekday"

    # 获取当前用户的crontab内容
    existing_crontab=$(crontab -l 2>/dev/null)

    # 要添加的定时任务
    new_cron="$schedule /opt/script/go-chatgpt-api/AutoImageUp.sh"

    # 判断crontab中是否存在相同的定时任务
    if echo "$existing_crontab" | grep -qF "$new_cron"; then
        WARN "已存在相同的定时任务！"
    else
        # 添加定时任务到crontab
        (crontab -l ; echo "$new_cron") | crontab -
        SUCCESS1 "已成功添加定时任务！"
    fi

    # 提示用户的定时任务执行时间
    INFO1 "您的定时任务已设置为在 $schedule 时间内执行！"

elif [[ "$cron" == "n" ]]; then
    # 取消定时任务
    WARN "已取消定时更新镜像任务！"
else
    ERROR "选项错误！请重新运行脚本并选择正确的选项。"
fi
}


function ADD_EM_ALERT() {
SUCCESS "Email alerts"
read -e -p "$(echo -e ${GREEN}"是否添加401|403|429检测和告警功能？(y/n): "${RESET})" alert

if [[ "$alert" == "y" ]]; then
mkdir -p /opt/script/go-chatgpt-api
cat > /opt/script/go-chatgpt-api/EmailAlert.sh << \EOF
#!/usr/bin/env bash
email_address="email@com"

prev_timestamp=""
is_alert=false

while true; do
  current_timestamp=$(docker logs go-chatgpt-api | grep -E "401|403|429" | awk '!/INFO\[0000\] (GO_CHATGPT_API_PROXY|Service go-chatgpt-api is ready)/ { match($0, /[0-9]{4}\/[0-9]{2}\/[0-9]{2} - [0-9]{2}:[0-9]{2}:[0-9]{2}/); if (RSTART > 0) print substr($0, RSTART, RLENGTH) }' | tail -n1)

  if [ -z "$prev_timestamp" ]; then
    prev_timestamp="$current_timestamp"
  else
    if [ "$current_timestamp" != "$prev_timestamp" ]; then
      echo "Warning: 401|403|429 error at $prev_timestamp" | mail -s "Warning: 401|403|429 error detected in container log" $email_address
      is_alert=true
    fi
    prev_timestamp="$current_timestamp"
  fi

  sleep 5
done
EOF
chmod +x /opt/script/go-chatgpt-api/EmailAlert.sh
    read -e -p "$(echo -e ${GREEN}"请输入接收告警邮箱: "${RESET})" email
    read -e -p "$(echo -e ${GREEN}"请输入401|403|429错误检测频率,默认5s: "${RESET})" alert_interval

    sed -i "s#email@com#$email#g" /opt/script/go-chatgpt-api/EmailAlert.sh
    sed -i "s#sleep 5#sleep $alert_interval#g" /opt/script/go-chatgpt-api/EmailAlert.sh
    if pgrep -f "/opt/script/go-chatgpt-api/EmailAlert.sh" >/dev/null; then
       pkill -f "/opt/script/go-chatgpt-api/EmailAlert.sh"
    fi
    nohup /opt/script/go-chatgpt-api/EmailAlert.sh > /dev/null 2>&1 &
    # 提示用户的定时任务执行时间
    INFO1 "已设置告警消息接收邮箱为 $email 检查频率为 $alert_interval！"
elif [[ "$alert" == "n" ]]; then
    # 取消定时任务
    WARN "已取消401|403|429错误检测告警功能！"
else
    ERROR "选项错误！请重新运行脚本并选择正确的选项。"
fi
}

main() {
  CHECK_CPU
  CHECK_OPENAI
  CHECK_OS
  CHECKFIRE
  INSTALL_PACKAGE
  INSTALL_PROXY
  DEL_IMG_NONE
  ADD_IMAGESUP
  ADD_EM_ALERT
}
main
