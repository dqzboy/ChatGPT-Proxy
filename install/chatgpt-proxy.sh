#!/usr/bin/env bash
#===============================================================================
#
#          FILE: chatgpt-proxy.sh
#
#         USAGE: ./chatgpt-proxy.sh
#
#   DESCRIPTION: 使用AccessToken访问ChatGPT，绕过CF验证;支持CentOS与Ubuntu
#
#  ORGANIZATION: Ding QinZheng dqzboy.com
#===============================================================================
SETCOLOR_SKYBLUE="echo -en \\E[1;36m"
SETCOLOR_SUCCESS="echo -en \\E[0;32m"
SETCOLOR_NORMAL="echo  -en \\E[0;39m"
SETCOLOR_RED="echo  -en \\E[0;31m"
SETCOLOR_YELLOW="echo -en \\E[1;33m"
GREEN="\033[1;32m"
RESET="\033[0m"
PURPLE="\033[35m"

echo
cat << EOF

         ██████╗██╗  ██╗ █████╗ ████████╗ ██████╗ ██████╗ ████████╗    ██████╗ ██████╗  ██████╗ ██╗  ██╗██╗   ██╗
        ██╔════╝██║  ██║██╔══██╗╚══██╔══╝██╔════╝ ██╔══██╗╚══██╔══╝    ██╔══██╗██╔══██╗██╔═══██╗╚██╗██╔╝╚██╗ ██╔╝
        ██║     ███████║███████║   ██║   ██║  ███╗██████╔╝   ██║       ██████╔╝██████╔╝██║   ██║ ╚███╔╝  ╚████╔╝ 
        ██║     ██╔══██║██╔══██║   ██║   ██║   ██║██╔═══╝    ██║       ██╔═══╝ ██╔══██╗██║   ██║ ██╔██╗   ╚██╔╝  
        ╚██████╗██║  ██║██║  ██║   ██║   ╚██████╔╝██║        ██║       ██║     ██║  ██║╚██████╔╝██╔╝ ██╗   ██║   
         ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝    ╚═════╝ ╚═╝        ╚═╝       ╚═╝     ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝   ╚═╝   
                                                                                                         
EOF

echo "----------------------------------------------------------------------------------------------------------"
echo
echo -e "\033[32m机场推荐\033[0m(\033[34m按量不限时，解锁ChatGPT\033[0m)：\033[34;4mhttps://mojie.me/#/register?code=CG6h8Irm\033[0m"
echo
echo "----------------------------------------------------------------------------------------------------------"
echo

TGCODE() {
    SUCCESS " TG Group "
    echo "█████████████████████████████████"
    echo "████ ▄▄▄▄▄ ██▀▀▄▄▀ ███ ▄▄▄▄▄ ████"
    echo "████ █   █ █▀███ ▀▄█▀█ █   █ ████"
    echo "████ █▄▄▄█ █▄▄█▀▀▄▄█▄█ █▄▄▄█ ████"
    echo "████▄▄▄▄▄▄▄█▄█ ▀▄█ ▀▄█▄▄▄▄▄▄▄████"
    echo "████▄ ▀▀▀ ▄ ▀ █▄▀▄ ▀▄███  ▀▀█████"
    echo "████▄██▄  ▄█ ▀▄█▀▄█▄▄▄█▀█ █▄ ████"
    echo "████▀▄ ▀▄▄▄▄▀▄█▄▄▀█ ▀█▄▀███▀▄████"
    echo "████ █ █▀ ▄█▄ ▄ ▄█ ▄█ ▀ ▄ ▀▄ ████"
    echo "████▄█▄█▄▄▄▄▀ █▄▀ ▄▄ ▄▄▄ █▄██████"
    echo "████ ▄▄▄▄▄ █ ▄▄▄▀█▀▀ █▄█ ██▀▄████"
    echo "████ █   █ ██ ▄█▄▄  ▄  ▄▄█▄  ████"
    echo "████ █▄▄▄█ █▀▀█ ▄▄ █ ▀▀▀▀▄▄█ ████"
    echo "████▄▄▄▄▄▄▄█▄█▄█▄▄▄▄▄█▄██▄██▄████"
    echo "█████████████████████████████████"

    echo
    echo "扫描上方二维码加入项目交流群"
}

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

MAX_ATTEMPTS=3
attempt=0
success=false

# 获取本机网卡和对应IP
INTERFACE=$(ip -o -4 route show to default | awk '{print $5}')
IP_ADDR=$(ip -o -4 addr show dev "$INTERFACE" | awk '{split($4, a, "/"); print a[1]}')

function Progress() {
set +x
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

function CHECK_CPU() {
if [[ "$(uname -m)" == "arm"* || "$(uname -m)" == "aarch64" ]]; then
    WARN "WARNING: 当前服务器 CPU 架构为 $(uname -m)，warp 不支持该架构。请注意！"
    echo
elif [[ "$(uname -m)" == "x86_64" ]]; then
    INFO1 "当前服务器 CPU 架构为 $(uname -m)，warp 支持该架构。"
    echo
else
    WARN "WARNING: 此脚本可能与当前 CPU 架构不完全兼容: $(uname -m)"
    echo
fi
}


text="检测服务器是否能够访问 chat.openai.com"
width=75
padding=$((($width - ${#text}) / 2))

function CHECK_OPENAI() {
SUCCESS "提示"
printf "%*s\033[31m%s\033[0m%*s\n" $padding "" "$text" $padding ""
SUCCESS "END "

url="chat.openai.com"
timeout=60  # 设置超时时间为60秒

# 检测是否能够访问chat.openai.com
echo "Testing connection to ${url}..."
if curl --output /dev/null --silent --head --fail --max-time ${timeout} ${url}; then
  echo "Connection successful!"
  echo """╭──────────────────────────────────────────────────────╮
│                                                      │
│  提示：此处测试结果仅代表你的服务器可以访问OPENAI    │
│       是否可以使用OPENAI接口还需要部署完成之后测试!  │
│                                                      │
╰──────────────────────────────────────────────────────╯"""
  URL="OK"
else
  echo "Could not connect to ${url}."
  INFO "强制安装"
  read -e -p "$(echo -e ${GREEN}"是否要强制执行安装？(y/n)："${RESET})" force_install
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
        WARN "此脚本目前不支持您的系统: $ID"
        exit 1
        ;;
esac

echo "--------------------------------------------------------"
echo "System release:: $NAME"
echo "System version: $VERSION"
echo "System ID: $ID"
echo "System ID Like: $ID_LIKE"
echo "--------------------------------------------------------"
}

function CHECK_PACKAGE_MANAGER() {
    if command -v dnf &> /dev/null; then
        package_manager="dnf"
    elif command -v yum &> /dev/null; then
        package_manager="yum"
    elif command -v apt-get &> /dev/null; then
        package_manager="apt-get"
    elif command -v apt &> /dev/null; then
        package_manager="apt"
    else
        ERROR "Unsupported package manager."
        exit 1
    fi
}

function CHECK_PKG_MANAGER() {
    if command -v rpm &> /dev/null; then
        pkg_manager="rpm"
    elif command -v dpkg &> /dev/null; then
        pkg_manager="dpkg"
    elif command -v apt &> /dev/null; then
        pkg_manager="apt"
    else
        ERROR "Unable to determine the package management system."
        exit 1
    fi
}

function CHECKFIRE() {
SUCCESS "检查防火墙和SELINUX"

# Check if firewall is enabled
systemctl stop firewalld &> /dev/null
systemctl disable firewalld &> /dev/null
systemctl stop iptables &> /dev/null
systemctl disable iptables &> /dev/null
ufw disable &> /dev/null
INFO1 "Firewall has been disabled."

# Check if SELinux is enforcing
if [[ "$repo_type" == "centos" || "$repo_type" == "rhel" ]]; then
    if sestatus | grep "SELinux status" | grep -q "enabled"; then
        WARN "SELinux is enabled. Disabling SELinux..."
        setenforce 0
        sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
        INFO1 "SELinux is already disabled."
    else
        INFO1 "SELinux is already disabled."
    fi
fi
}

function INSTALL_PACKAGE(){
# 每个软件包的安装超时时间（秒）
TIMEOUT=300
PACKAGES_APT=(
    lsof jq wget tar postfix mailutils
)
PACKAGES_YUM=(
    epel-release lsof jq wget tar postfix yum-utils mailx s-nail
)

if [ "$package_manager" = "dnf" ] || [ "$package_manager" = "yum" ]; then
    SUCCESS "安装必要的系统组件"
    for package in "${PACKAGES_YUM[@]}"; do
        if $pkg_manager -q "$package" &>/dev/null; then
            echo "已经安装 $package ..."
        else
            echo "正在安装 $package ..."

            # 记录开始时间
            start_time=$(date +%s)

            # 安装软件包并等待完成
            $package_manager -y install "$package" --skip-broken > /dev/null 2>&1 &
            install_pid=$!

            # 检查安装是否超时
            while [[ $(($(date +%s) - $start_time)) -lt $TIMEOUT ]] && kill -0 $install_pid &>/dev/null; do
                sleep 1
            done

            # 如果安装仍在运行，提示用户
            if kill -0 $install_pid &>/dev/null; then
                ERROR "$package 的安装时间超过 $TIMEOUT 秒。是否继续？ (y/n)"
                read -r continue_install
                if [ "$continue_install" != "y" ]; then
                    ERROR "$package 的安装超时。退出脚本。"
                    exit 1
                else
                    # 直接跳过等待，继续下一个软件包的安装
                    continue
                fi
            fi

            # 检查安装结果
            wait $install_pid
            if [ $? -ne 0 ]; then
                ERROR "$package 安装失败。请检查系统安装源，然后再次运行此脚本！请尝试手动执行安装：$package_manager -y install $package"
                exit 1
            fi
        fi
    done
    # 检查 /etc/postfix/main.cf 文件是否存在
    if [ -f "/etc/postfix/main.cf" ]; then
        # 检查是否已经存在正确的配置
        if ! grep -q "^inet_interfaces = all" "/etc/postfix/main.cf"; then
            # 将 inet_interfaces 设置为 all
            sed -i 's/^inet_interfaces =.*/inet_interfaces = all/' /etc/postfix/main.cf
            systemctl restart postfix &>/dev/null
        fi
    else
        echo "文件 /etc/postfix/main.cf 不存在"
    fi
elif [ "$package_manager" = "apt-get" ];then
    SUCCESS "安装必要的系统组件"
    dpkg --configure -a &>/dev/null
    $package_manager update &>/dev/null
    for package in "${PACKAGES_APT[@]}"; do
        if $pkg_manager -s "$package" &>/dev/null; then
            echo "$package Already installed, skip..."
        else
            echo "Installing $package ..."
            $package_manager install -y $package > /dev/null 2>&1
            if [ $? -ne 0 ]; then
                ERROR "安装 $package 失败,请检查系统安装源之后再次运行此脚本！请尝试手动执行安装：$package_manager -y install $package"
                exit 1
            fi
        fi
    done
    # 检查 /etc/postfix/main.cf 文件是否存在
    if [ -f "/etc/postfix/main.cf" ]; then
        # 检查是否已经存在正确的配置
        if ! grep -q "^inet_interfaces = all" "/etc/postfix/main.cf"; then
            # 将 inet_interfaces 设置为 all
            sed -i 's/^inet_interfaces =.*/inet_interfaces = all/' /etc/postfix/main.cf
            systemctl restart postfix &>/dev/null
        fi
    else
	echo "文件 /etc/postfix/main.cf 不存在"
    fi
else
    WARN "Unable to determine the package management system."
    exit 1
fi
}

function INSTALL_DOCKER() {
# 获取当前系统的CPU架构
cpu_arch=$(uname -m)

# 根据不同的CPU架构定义下载的Docker包的URL
case $cpu_arch in
  "arm")
    docker_ver=$(curl -s https://download.docker.com/linux/static/stable/armel/ | grep -o 'docker-[0-9.]*.tgz' | sort -V | tail -n 1)
    url="https://download.docker.com/linux/static/stable/armel/$docker_ver"
    ;;
  "aarch64")
    docker_ver=$(curl -s https://download.docker.com/linux/static/stable/aarch64/ | grep -o 'docker-[0-9.]*.tgz' | sort -V | tail -n 1)
    url="https://download.docker.com/linux/static/stable/aarch64/$docker_ver"
    ;;
  "x86_64")
    docker_ver=$(curl -s https://download.docker.com/linux/static/stable/x86_64/ | grep -o 'docker-[0-9.]*.tgz' | sort -V | tail -n 1)
    url="https://download.docker.com/linux/static/stable/x86_64/$docker_ver"
    ;;
  *)
    ERROR "不支持的CPU架构: $cpu_arch"
    exit 1
    ;;
esac

# 定义要保存和解压的路径
save_path="$PWD"

if ! command -v docker &> /dev/null; then
  while [ $attempt -lt $MAX_ATTEMPTS ]; do
    attempt=$((attempt + 1))
    ERROR "docker 未安装，正在进行安装..."
    wget -P "$save_path" "$url" &>/dev/null
    # 检查命令的返回值
    if [ $? -eq 0 ]; then
        success=true
        break
    fi
    ERROR "docker安装失败，正在尝试重新下载 (尝试次数: $attempt)"
  done

  if $success; then
     tar -xzf $save_path/$docker_ver
     \cp $save_path/docker/* /usr/bin/
     rm -rf $save_path/$docker_ver $save_path/docker
     SUCCESS1 ">>> $(docker --version)"
     
     cat > /etc/systemd/system/docker.service <<EOF
[Unit]
Description=Docker Application Container Engine
Documentation=https://docs.docker.com
After=network-online.target firewalld.service
Wants=network-online.target
[Service]
Type=notify
ExecStart=/usr/bin/dockerd
ExecReload=/bin/kill -s HUP 
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity
TimeoutStartSec=0
Delegate=yes
KillMode=process
Restart=on-failure
StartLimitBurst=3
StartLimitInterval=60s
[Install]
WantedBy=multi-user.target
EOF
     systemctl daemon-reload
     systemctl restart docker | grep -E "ERROR|ELIFECYCLE|WARN"
     systemctl enable docker &>/dev/null
  else
     ERROR "docker安装失败，请尝试手动安装"
     exit 1
  fi
else 
  INFO1 "已经安装 docker ..."
  SUCCESS1 ">>> $(docker --version)"
  systemctl restart docker | grep -E "ERROR|ELIFECYCLE|WARN"
fi
}

function INSTALL_COMPOSE() {
    TAG=`curl -s https://api.github.com/repos/docker/compose/releases/latest | jq -r '.tag_name'`
    MAX_ATTEMPTS=5
    attempt=0
    success=false
    chmod +x /usr/local/bin/docker-compose &>/dev/null
    if ! command -v docker-compose &> /dev/null || [ -z "$(docker-compose --version)" ]; then
        ERROR "docker-compose 未安装或安装不完整，正在进行安装..."
        read -e -p "$(echo -e ${GREEN}"当前服务器在国内还是国外? (国内输1;国外回车)："${RESET})" location       
        while [ $attempt -lt $MAX_ATTEMPTS ]; do
            attempt=$((attempt + 1))

            if [ "$location" == "1" ]; then
                wget --continue -q "https://mirrors.goproxyauth.com/https://github.com/docker/compose/releases/download/$TAG/docker-compose-$(uname -s)-$(uname -m)" -O /usr/local/bin/docker-compose
            else
                wget --continue -q "https://github.com/docker/compose/releases/download/$TAG/docker-compose-$(uname -s)-$(uname -m)" -O /usr/local/bin/docker-compose
            fi

            # 检查命令的返回值
            if [ $? -eq 0 ]; then
                # 在下载完成后再次检查是否可以执行 docker-compose --version
                version_check=$(docker-compose --version)
                if [ -n "$version_check" ]; then
                    success=true
                    chmod +x /usr/local/bin/docker-compose
                    break
                else
                    ERROR "docker-compose 下载的文件不完整，正在尝试重新下载 (尝试次数: $attempt)"
                    rm -f /usr/local/bin/docker-compose
                fi
            fi

            ERROR "docker-compose 下载失败，正在尝试重新下载 (尝试次数: $attempt)"
        done

        if $success; then
            SUCCESS1 ">>> $(docker-compose --version)"
        else
            ERROR "docker-compose 下载失败，请尝试手动安装docker-compose"
            exit 1
        fi
    else
        INFO1 "已经安装 docker-compose ..."
        chmod +x /usr/local/bin/docker-compose
        SUCCESS1 ">>> $(docker-compose --version)" 
    fi

}

# --------------------------------------------------  go-chatgpt-api  --------------------------------------------------
function GO_MODIFY_PORT() {
DOCKER_DIR="/data/go-chatgpt-api"
mkdir -p $DOCKER_DIR

read -e -p "$(echo -e ${GREEN}"是否修改容器映射端口号？(y/n): "${RESET})" answer

if [ "$answer" == "y" ]; then
    while true; do
        read -e -p "请输入新的端口号(1-65535): " port
        # 校验用户输入的端口是否为纯数字且在范围内
        if ! [[ "$port" =~ ^[0-9]+$ ]] || ((port < 1)) || ((port > 65535)); then
            ERROR "端口必须是1到65535之间的纯数字且不可为空。"
        elif lsof -i:$port >/dev/null 2>&1; then
            WARN "该端口已被占用，请重新输入！"
        else
            sed -i "s/- 8080:/- $port:/" ${DOCKER_DIR}/docker-compose.yml
            break
        fi
    done
    sed -i "s/- 8080:/- $port:/" ${DOCKER_DIR}/docker-compose.yml
fi
}

function GO_CONFIG() {
DOCKER_DIR="/data/go-chatgpt-api"
mkdir -p ${DOCKER_DIR}
MAX_ATTEMPTS=3
attempt=0
echo "--------------------------------------------------------"
while [ $attempt -lt $MAX_ATTEMPTS ]; do
  read -e -p "$(echo -e ${GREEN}"输入要使用的模式 (api/warp)："${RESET})" mode
  if [ "$mode" == "api" ]; then
     cat > ${DOCKER_DIR}/docker-compose.yml <<\EOF
version: "3" 
services:
  go-chatgpt-api:
    build: .
    container_name: go-chatgpt-api
    image: linweiyuan/go-chatgpt-api
    ports:
      - 8080:8080         # 容器端口映射到宿主机8080端口；宿主机监听端口可按需改为其它端口
    #network_mode: host   # 可选，将容器加入主机网络模式，即与主机共享网络命名空间；上面的端口映射将失效
    environment:
      - PORT=
      - TZ=Asia/Shanghai
      - PROXY=                   # PROXY=：可配置科学上网代理地址，例如：http://clash_vpsIP:7890；注释掉或者留空则不启用
      #http://host:port          # PROXY=：科学上网代理地址，例如：http://clash_vpsIP:7890
      #socks5://host:port        # PROXY=：科学上网代理地址，例如：socks5://clash_vpsIP:7890
      - ARKOSE_TOKEN_URL=
      - OPENAI_EMAIL=
      - OPENAI_PASSWORD=
      - CONTINUE_SIGNAL=         # CONTINUE_SIGNAL=1，开启/imitate接口自动继续会话功能，留空关闭，默认关闭
      - ENABLE_HISTORY=
      - IMITATE_ACCESS_TOKEN=
    volumes:
      - ./chat.openai.com.har:/app/chat.openai.com.har
    restart: unless-stopped
EOF
     break
  elif [ "$mode" == "warp" ]; then
      if [[ "$(uname -m)" == "arm"* || "$(uname -m)" == "aarch64" ]]; then
          WARN "当前服务器 CPU 架构为 $(uname -m)，warp 不支持该架构。"
      elif [[ "$(uname -m)" == "x86_64" ]]; then
          INFO1 "当前服务器 CPU 架构为 $(uname -m)，warp 支持该架构。"
          cat > ${DOCKER_DIR}/docker-compose.yml <<\EOF
version: "3"
services:
  go-chatgpt-api:
    build: .
    container_name: go-chatgpt-api
    image: linweiyuan/go-chatgpt-api
    ports:
      - 8080:8080         # 容器端口映射到宿主机8080端口；宿主机监听端口可按需改为其它端口
    #network_mode: host   # 可选，将容器加入主机网络模式，即与主机共享网络命名空间；上面的端口映射将失效
    environment:
      - PORT=
      - TZ=Asia/Shanghai
      - PROXY=socks5://chatgpt-proxy-server-warp:65535
      - ARKOSE_TOKEN_URL=
      - OPENAI_EMAIL=
      - OPENAI_PASSWORD=
      - CONTINUE_SIGNAL=         # CONTINUE_SIGNAL=1，开启/imitate接口自动继续会话功能，留空关闭，默认关闭
      - ENABLE_HISTORY=
      - IMITATE_ACCESS_TOKEN=
    volumes:
      - ./chat.openai.com.har:/app/chat.openai.com.har
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
          break
      else
          WARN "WARNING: 此脚本可能与当前 CPU 架构不完全兼容: $(uname -m)"
      fi
  else
    ERROR "Invalid or missing parameter"
    exit 1
  fi

  attempt=$((attempt + 1))
  if [ $attempt -lt $MAX_ATTEMPTS ]; then
    WARN "您已选择warp，但是当前服务器不支持该架构。请重新选择。 (尝试次数: $attempt)"
  else
    ERROR "您已连续选择warp，但是当前服务器不支持该架构。退出脚本。"
    exit 1
  fi
done


# 提示用户是否需要修改配置
read -e -p "$(echo -e ${GREEN}"是否添加代理? (y/n)："${RESET})" modify_config
case $modify_config in
  [Yy]* )
    # 提示用户本机IP
    ${SETCOLOR_SUCCESS} && echo "---------------------------------------------"  && ${SETCOLOR_NORMAL}
    echo -e "本机网卡：${PURPLE}${INTERFACE}${RESET} 对应IP：${PURPLE}${IP_ADDR}${RESET}"
    ${SETCOLOR_SUCCESS} && echo "---------------------------------------------"  && ${SETCOLOR_NORMAL}
    # 获取用户输入的URL及其类型
    read -e -p "$(echo -e ${GREEN}"输入代理地址 (e.g. host:port): "${RESET})" url
    while [[ -z "$url" ]]; do
      WARN "代理地址不能为空，请重新输入。"
      read -e -p "$(echo -e ${GREEN}"输入代理地址 (e.g. host:port): "${RESET})" url
    done

    while true; do
      read -e -p "$(echo -e ${GREEN}"确认代理协议 (http/socks5)："${RESET})" type
      case $type in
          [Hh][Tt]* ) url_type="http"; break;;
          [Ss][Oo]* ) url_type="socks5"; break;;
          * ) echo "Please answer http or socks5.";;
      esac
    done
    
    # 根据类型更新docker-compose.yml文件
    if [ "$mode" == "api" ]; then
       if [ "$url_type" == "http" ]; then
	  sed -i '/- PROXY=/d' ${DOCKER_DIR}/docker-compose.yml
          sed -i "s|#http://host:port|- PROXY=http://${url}|g" ${DOCKER_DIR}/docker-compose.yml
       elif [ "$url_type" == "socks5" ]; then
	  sed -i '/- PROXY=/d' ${DOCKER_DIR}/docker-compose.yml
          sed -i "s|#socks5://host:port|- PROXY=socks5://${url}|g" ${DOCKER_DIR}/docker-compose.yml
       fi
    elif [ "$mode" == "warp" ]; then
       if [ "$url_type" == "http" ]; then
          sed -i "s|- PROXY=socks5://chatgpt-proxy-server-warp:65535|- PROXY=http://${url}|g" ${DOCKER_DIR}/docker-compose.yml
       elif [ "$url_type" == "socks5" ]; then
          sed -i "s|- PROXY=socks5://chatgpt-proxy-server-warp:65535|- PROXY=socks5://${url}|g" ${DOCKER_DIR}/docker-compose.yml
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
GO_MODIFY_PORT

}

function GO_CHRCK_CONTAINER() {
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

function GO_INSTALL_PROXY() {
# 确认是否强制安装
if [[ "$force_install" = "y" ]]; then
    # 强制安装代码
    WARN "开始强制安装..."
    INSTALL_DOCKER
    INSTALL_COMPOSE
    cd ${DOCKER_DIR} && docker-compose down &>/dev/null
    GO_CONFIG
    cd ${DOCKER_DIR} && docker-compose pull && docker-compose up -d && GO_CHRCK_CONTAINER
elif [[ "$URL" = "OK" ]];then
    # 强制安装代码
    WARN "开始安装..."
    INSTALL_DOCKER
    INSTALL_COMPOSE
    cd ${DOCKER_DIR} && docker-compose down &>/dev/null
    GO_CONFIG
    cd ${DOCKER_DIR} && docker-compose pull && docker-compose up -d && GO_CHRCK_CONTAINER
else
    ERROR "已取消安装."
    exit 0
fi
}

function GO_DEL_IMG_NONE() {
# 删除go-chatgpt-api所有处于 "none" 状态的镜像
if [ -n "$(docker images -q --filter "dangling=true" --filter "reference=linweiyuan/go-chatgpt-api")" ]; then
    docker rmi $(docker images -q --filter "dangling=true" --filter "reference=linweiyuan/go-chatgpt-api") &>/dev/null
fi
}

function GO_ADD_IMAGESUP() {
SUCCESS "Add Crontab"
read -e -p "$(echo -e ${GREEN}"是否加入定时更新镜像？(y/n): "${RESET})" cron

if [[ "$cron" == "y" ]]; then
  mkdir -p /opt/script/go-chatgpt-api
  if [[ "$modify_config" == "y" ]]; then
    cat > /opt/script/go-chatgpt-api/AutoImageUp.sh << \EOF
#!/usr/bin/env bash
export proxy="type_value://url_value"
export http_proxy=$proxy
export https_proxy=$proxy
export ftp_proxy=$proxy
export no_proxy="localhost, 127.0.0.1, ::1"

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

      sed -ri "s#type_value#${type}#" /opt/script/go-chatgpt-api/AutoImageUp.sh
      sed -ri "s#url_value#${url}#" /opt/script/go-chatgpt-api/AutoImageUp.sh
  else
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
  fi

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
    exit 1
fi
}


function GO_ADD_EM_ALERT() {
SUCCESS "Email alerts"
read -e -p "$(echo -e ${GREEN}"是否添加401|403|429检测和告警功能？(y/n): "${RESET})" alert

if [[ "$alert" == "y" ]]; then
mkdir -p /opt/script/go-chatgpt-api
cat > /opt/script/go-chatgpt-api/EmailAlert.sh << \EOF
#!/usr/bin/env bash
email_address="email@com"
images="go-chatgpt-api"
prev_timestamp=""
is_alert=false

while true; do
  error_code=$(docker logs $images | grep -E "401|403|429" | awk '!/INFO\[0000\] (GO_CHATGPT_API_PROXY|Service go-chatgpt-api is ready)/ { match($0, /401|403|429/); if (RSTART > 0) print substr($0, RSTART, RLENGTH) }' | tail -n1)

  if [ -n "$error_code" ]; then
    current_timestamp=$(docker logs $images | grep -E "401|403|429" | awk '!/INFO\[0000\] (GO_CHATGPT_API_PROXY|Service go-chatgpt-api is ready)/ { match($0, /[0-9]{4}\/[0-9]{2}\/[0-9]{2} - [0-9]{2}:[0-9]{2}:[0-9]{2}/); if (RSTART > 0) print substr($0, RSTART, RLENGTH) }' | tail -n1)

    if [ -z "$prev_timestamp" ]; then
      prev_timestamp="$current_timestamp"
    else
      if [ "$current_timestamp" != "$prev_timestamp" ]; then
	echo -e """
-------------------------------------------------------------------
|  报错时间 | $current_timestamp                   
|------------------------------------------------------------------
|  容器名称 | $images                       
|------------------------------------------------------------------
|  错误代码 | $error_code                     
|------------------------------------------------------------------
|  服务器IP | $IP_ADDR                     
|------------------------------------------------------------------
|  推送信息 | Warning: $error_code error detected in container log
-------------------------------------------------------------------
""" | mail -s "Warning: $error_code error" $email_address
        is_alert=true
      fi
      prev_timestamp="$current_timestamp"
    fi
  fi

  sleep 5
done
EOF
chmod +x /opt/script/go-chatgpt-api/EmailAlert.sh
    read -e -p "$(echo -e ${GREEN}"请输入接收告警邮箱: "${RESET})" email
    # 判断输入是否为空或邮箱格式是否正确
    if [[ -z "$email" || ! $email =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}$ ]]; then
        ERROR "ERROR: 请输入正确格式的邮箱地址！"
        exit 1
    fi

    read -e -p "$(echo -e ${GREEN}"请输入 ERROR|WARN 日志错误检测频率,单位秒: "${RESET})" alert_interval
    # 判断alert_interval是否为空或不是纯数字
    if [[ -z "$alert_interval" || ! "$alert_interval" =~ ^[0-9]+$ ]]; then
        ERROR "ERROR: 输入错误！输入必须为纯数字且不可为空！"
        exit 1
    fi

    sed -i "s#email@com#$email#g" /opt/script/go-chatgpt-api/EmailAlert.sh
    sed -i "s#sleep 5#sleep $alert_interval#g" /opt/script/go-chatgpt-api/EmailAlert.sh

    nohup /opt/script/go-chatgpt-api/EmailAlert.sh > /dev/null 2>&1 &
    # 提示用户的定时任务执行时间
    INFO1 "已设置告警消息接收邮箱为 $email 检查频率为 $alert_interval！秒"
elif [[ "$alert" == "n" ]]; then
    # 取消定时任务
    WARN "已取消401|403|429错误检测告警功能！"
else
    ERROR "选项错误！请重新运行脚本并选择正确的选项。"
    exit 1
fi
}

# --------------------------------------------------  go-chatgpt-api END  --------------------------------------------------


# --------------------------------------------------  ninja-chatgpt-api  --------------------------------------------------
function ninja_MODIFY_PORT() {
DOCKER_DIR="/data/ninja-chatgpt-api"
mkdir -p $DOCKER_DIR

max_attempts=3
answer=""

for ((i=1; i<=max_attempts; i++)); do
    read -e -p "$(echo -e ${GREEN}"是否修改容器端口映射? 默认端口8080 (y/n): "${RESET})" answer

    if [ "$answer" == "y" ]; then
        while true; do
            read -e -p "请输入新的端口号(1-65535): " port
            # 校验用户输入的端口是否为纯数字且在范围内
            if ! [[ "$port" =~ ^[0-9]+$ ]] || ((port < 1)) || ((port > 65535)); then
                ERROR "端口必须是 1 到 65535 之间的纯数字，并且不能为空。"
            elif lsof -i:$port >/dev/null 2>&1; then
                WARN "端口已被占用，请重新输入！"
            else
                sed -i "s/- 8080:/- $port:/" ${DOCKER_DIR}/docker-compose.yml
                break
            fi
        done
        sed -i "s/- 8080:/- $port:/" ${DOCKER_DIR}/docker-compose.yml
        break
    elif [ "$answer" == "n" ]; then
        echo "Do not modify!"
        break
    else
        WARN "Invalid input. Please enter 'y' or 'n'."
    fi
done

if [ "$answer" != "y" ] && [ "$answer" != "n" ]; then
    ERROR "Invalid input for $max_attempts attempts. Exiting the script."
    exit 1
fi
}

function ninja_CONFIG_Direct() {
max_attempts=3
valid_input=false

for ((i=1; i<=max_attempts; i++)); do
    read -e -p "$(echo -e ${GREEN}"是否启用直连,不走代理池? 默认关闭 (y/n): "${RESET})" Direct

    if [ "$Direct" == "y" ]; then
        valid_input=true
        sed -i 's/command: run/& --enable-direct/' ${DOCKER_DIR}/docker-compose.yml
        break
    elif [ "$Direct" == "n" ]; then
        valid_input=true
        echo "Do not modify!"
        break
    else
        WARN "Invalid input. Please enter 'y' or 'n'."
    fi
done

if [ "$valid_input" == "false" ]; then
    ERROR "Invalid input for $max_attempts attempts. Exiting the script."
    exit 1
fi
}

function ninja_CONFIG_WEBUI() {
max_attempts=3
valid_input=false

for ((i=1; i<=max_attempts; i++)); do
    read -e -p "$(echo -e ${GREEN}"是否禁用 Ninja Web UI? 默认启用 (y/n): "${RESET})" webui

    if [ "$webui" == "y" ]; then
        valid_input=true
        sed -i 's/command: run/& --disable-webui/' ${DOCKER_DIR}/docker-compose.yml
        break
    elif [ "$webui" == "n" ]; then
        valid_input=true
        echo "Do not modify!"
        break
    else
        WARN "Invalid input. Please enter 'y' or 'n'."
    fi
done

if [ "$valid_input" == "false" ]; then
    ERROR "Invalid input for $max_attempts attempts. Exiting the script."
    exit 1
fi
}

function ninja_CONFIG_GPT3Arkose() {
max_attempts=3
valid_input=false

for ((i=1; i<=max_attempts; i++)); do
    read -e -p "$(echo -e ${GREEN}"是否启用 Arkose GPT-3.5 实验? 默认禁用 (y/n): "${RESET})" GPT3Arkose

    if [ "$GPT3Arkose" == "y" ]; then
        valid_input=true
        sed -i 's/command: run/& --arkose-gpt3-experiment/' ${DOCKER_DIR}/docker-compose.yml
        break
    elif [ "$GPT3Arkose" == "n" ]; then
        valid_input=true
        echo "Do not modify!"
        break
    else
        WARN "Invalid input. Please enter 'y' or 'n'."
    fi
done

if [ "$valid_input" == "false" ]; then
    ERROR "Invalid input for $max_attempts attempts. Exiting the script."
    exit 1
fi
}

function ninja_CONFIG() {
DOCKER_DIR="/data/ninja-chatgpt-api"
mkdir -p ${DOCKER_DIR}
MAX_ATTEMPTS=3
attempt=0
echo "--------------------------------------------------------"
while [ $attempt -lt $MAX_ATTEMPTS ]; do
  read -e -p "$(echo -e ${GREEN}"输入要使用的模式 (api/warp)："${RESET})" mode
  if [ "$mode" == "api" ]; then
     cat > ${DOCKER_DIR}/docker-compose.yml <<\EOF
version: '3'
services:
  ninja:
    image: gngpp/ninja:latest
    container_name: ninja
    restart: unless-stopped
    environment:
      - TZ=Asia/Shanghai
      #http://host:port
      #socks5://host:port
    command: run
    ports:
      - 8080:7999
  watchtower:
    container_name: watchtower
    image: containrrr/watchtower
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    command: --interval 3600 --cleanup
    restart: unless-stopped
EOF
     break
  elif [ "$mode" == "warp" ]; then
      if [[ "$(uname -m)" == "arm"* || "$(uname -m)" == "aarch64" ]]; then
          WARN "当前服务器 CPU 架构为 $(uname -m)，warp 不支持该架构。"
      elif [[ "$(uname -m)" == "x86_64" ]]; then
          INFO1 "当前服务器 CPU 架构为 $(uname -m)，warp 支持该架构。"
          cat > ${DOCKER_DIR}/docker-compose.yml <<\EOF
version: '3'
services:
  ninja:
    image: gngpp/ninja:latest
    container_name: ninja
    restart: unless-stopped
    environment:
      - TZ=Asia/Shanghai
      - PROXIES=socks5://warp:10000
    command: run
    ports:
      - 8080:7999
    depends_on:
      - warp

  warp:
    container_name: warp
    image: ghcr.io/gngpp/warp:latest
    restart: unless-stopped

  watchtower:
    container_name: watchtower
    image: containrrr/watchtower
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    command: --interval 3600 --cleanup
    restart: unless-stopped
EOF
          break
      else
          WARN "WARNING: 此脚本可能与当前 CPU 架构不完全兼容: $(uname -m)"
      fi
  else
    ERROR "Invalid or missing parameter"
    exit 1
  fi

  attempt=$((attempt + 1))
  if [ $attempt -lt $MAX_ATTEMPTS ]; then
    WARN "您已选择warp，但是当前服务器不支持该架构。请重新选择。 (尝试次数: $attempt)"
  else
    ERROR "您已连续选择warp，但是当前服务器不支持该架构。退出脚本。"
    exit 1
  fi
done

# 提示用户是否需要修改配置
read -e -p "$(echo -e ${GREEN}"是否添加代理? (y/n)："${RESET})" modify_config
case $modify_config in
  [Yy]* )
    # 提示用户本机IP
    ${SETCOLOR_SUCCESS} && echo "---------------------------------------------"  && ${SETCOLOR_NORMAL}
    echo -e "本机网卡：${PURPLE}${INTERFACE}${RESET} 对应IP：${PURPLE}${IP_ADDR}${RESET}"
    ${SETCOLOR_SUCCESS} && echo "---------------------------------------------"  && ${SETCOLOR_NORMAL}
    # 获取用户输入的URL及其类型
    read -e -p "$(echo -e ${GREEN}"输入代理地址 (e.g. host:port): "${RESET})" url
    while [[ -z "$url" ]]; do
      WARN "代理地址不能为空，请重新输入。"
      read -e -p "$(echo -e ${GREEN}"输入代理地址 (e.g. host:port): "${RESET})" url
    done
    while true; do
      read -e -p "$(echo -e ${GREEN}"确认代理协议 (http/socks5)："${RESET})" type
      case $type in
          [Hh][Tt]* ) url_type="http"; break;;
          [Ss][Oo]* ) url_type="socks5"; break;;
          * ) echo "Please answer http or socks5.";;
      esac
    done
    
    # 根据类型更新docker-compose.yml文件
    if [ "$mode" == "api" ]; then
       if [ "$url_type" == "http" ]; then
          sed -i '/- PROXIES=/d' ${DOCKER_DIR}/docker-compose.yml
          sed -i "s|#http://host:port|- PROXIES=http://${url}|g" ${DOCKER_DIR}/docker-compose.yml          
       elif [ "$url_type" == "socks5" ]; then
	  sed -i '/- PROXIES=/d' ${DOCKER_DIR}/docker-compose.yml
          sed -i "s|#socks5://host:port|- PROXIES=socks5://${url}|g" ${DOCKER_DIR}/docker-compose.yml
       fi
    elif [ "$mode" == "warp" ]; then
       if [ "$url_type" == "http" ]; then
          sed -i "s|- PROXIES=socks5://chatgpt-proxy-server-warp:65535|- PROXIES=http://${url}|g" ${DOCKER_DIR}/docker-compose.yml
       elif [ "$url_type" == "socks5" ]; then
          sed -i "s|- PROXIES=socks5://chatgpt-proxy-server-warp:65535|- PROXIES=socks5://${url}|g" ${DOCKER_DIR}/docker-compose.yml
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
# 调用修改端口、WEB UI以及是否开启GPT3.5Arkose的配置函数
ninja_MODIFY_PORT
ninja_CONFIG_Direct
ninja_CONFIG_WEBUI
ninja_CONFIG_GPT3Arkose
}


function ninja_CHRCK_CONTAINER() {
# 检查 ninja-chatgpt-api 容器状态
status_ninja_chatgpt_api=$(docker container inspect -f '{{.State.Running}}' ninja 2>/dev/null)

# 判断容器状态并打印提示
if [[ "$status_ninja_chatgpt_api" == "true" ]]; then
    SUCCESS "CHECK"
    Progress
    SUCCESS1 ">>>>> Docker containers are up and running."
else
    SUCCESS "CHECK"
    Progress
    ERROR ">>>>> The following containers are not up"
    if [[ "$status_ninja_chatgpt_api" != "true" ]]; then
        WARN ">>> ninja-chatgpt-api"
    fi
fi
}

function ninja_INSTALL_PROXY() {
# 确认是否强制安装
if [[ "$force_install" = "y" ]]; then
    # 强制安装代码
    WARN "开始强制安装..."
    INSTALL_DOCKER
    INSTALL_COMPOSE
    INFO "开始部署服务,请稍等"
    cd ${DOCKER_DIR} && docker-compose down &>/dev/null
    ninja_CONFIG
    cd ${DOCKER_DIR} && docker-compose pull && docker-compose up -d && ninja_CHRCK_CONTAINER
elif [[ "$URL" = "OK" ]];then
    # 强制安装代码
    WARN "开始安装..."
    INSTALL_DOCKER
    INSTALL_COMPOSE
    cd ${DOCKER_DIR} && docker-compose down &>/dev/null
    ninja_CONFIG
    INFO "开始部署服务,请稍等"
    cd ${DOCKER_DIR} && docker-compose pull && docker-compose up -d && ninja_CHRCK_CONTAINER
else
    ERROR "已取消安装."
    exit 0
fi
}

function ninja_DEL_IMG_NONE() {
# 删除ninja-chatgpt-api所有处于 "none" 状态的镜像
if [ -n "$(docker images -q --filter "dangling=true" --filter "reference=ghcr.io/gngpp/ninja")" ]; then
    docker rmi $(docker images -q --filter "dangling=true" --filter "reference=ghcr.io/gngpp/ninja") &>/dev/null
fi
}


function ninja_ADD_EM_ALERT() {
SUCCESS "Email alerts"
read -e -p "$(echo -e ${GREEN}"是否添加WARN|ERROR日志检测和告警功能？(y/n): "${RESET})" alert

if [[ "$alert" == "y" ]]; then
mkdir -p /opt/script/ninja-chatgpt-api
cat > /opt/script/ninja-chatgpt-api/EmailAlert.sh << \EOF
#!/usr/bin/env bash

email_address="email@com"
container_name="ninja"
prev_error_timestamp=""

while true; do
  error_logs=$(docker logs "$container_name" 2>/dev/null | grep -E "ERROR|WARN")
  
  while read -r error_log; do
    current_error_timestamp=$(echo "$error_log" | cut -d ' ' -f 1,2)
    
    if [ "$current_error_timestamp" != "$prev_error_timestamp" ]; then
      IP_ADDR=$(curl -s ifconfig.me)
      message=$(cat <<-EOM
-------------------------------------------------------------------
|  报错时间 | $current_error_timestamp                   
|------------------------------------------------------------------
|  容器名称 | $container_name                       
|------------------------------------------------------------------
|  错误信息 | $error_log                     
|------------------------------------------------------------------
|  服务器IP | $IP_ADDR                     
|------------------------------------------------------------------
|  推送信息 | Warning: $error_log error detected in container log
-------------------------------------------------------------------
EOM
)
      echo "$message" | mail -s "Warning: $error_log error" "$email_address"
      prev_error_timestamp="$current_error_timestamp"
    fi
  done <<< "$error_logs"

  sleep 5
done
EOF
chmod +x /opt/script/ninja-chatgpt-api/EmailAlert.sh
    read -e -p "$(echo -e ${GREEN}"请输入接收告警邮箱: "${RESET})" email
    # 判断输入是否为空或邮箱格式是否正确
    if [[ -z "$email" || ! $email =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}$ ]]; then
        ERROR "ERROR: 请输入正确格式的邮箱地址！"
        exit 1
    fi

    read -e -p "$(echo -e ${GREEN}"请输入 ERROR|WARN 日志错误检测频率,单位秒: "${RESET})" alert_interval
    # 判断alert_interval是否为空或不是纯数字
    if [[ -z "$alert_interval" || ! "$alert_interval" =~ ^[0-9]+$ ]]; then
        ERROR "ERROR: 输入错误！输入必须为纯数字且不可为空！"
        exit 1
    fi

    sed -i "s#email@com#$email#g" /opt/script/ninja-chatgpt-api/EmailAlert.sh
    sed -i "s#sleep 5#sleep $alert_interval#g" /opt/script/ninja-chatgpt-api/EmailAlert.sh
 
    nohup /opt/script/ninja-chatgpt-api/EmailAlert.sh > /dev/null 2>&1 &
    # 提示用户的定时任务执行时间
    INFO1 "已设置告警消息接收邮箱为 $email 检查频率为 $alert_interval！秒"
elif [[ "$alert" == "n" ]]; then
    # 取消定时任务
    WARN "已取消 ERROR|WARN 日志错误检测告警功能！"
else
    ERROR "选项错误！请重新运行脚本并选择正确的选项。"
    exit 1
fi
}

# --------------------------------------------------  ninja-chatgpt-api END  --------------------------------------------------


function ADD_UPTIME_KUMA() {
    SUCCESS "Uptime Kuma"
    read -e -p "$(echo -e ${GREEN}"是否部署uptime-kuma监控工具？(y/n): "${RESET})" uptime

    if [[ "$uptime" == "y" ]]; then
        # 检查是否已经运行了 uptime-kuma 容器
        if docker ps -a --format "{{.Names}}" | grep -q "uptime-kuma"; then
            WARN "已经运行了uptime-kuma监控工具。"
            read -e -p "$(echo -e ${GREEN}"是否停止和删除旧的容器并继续安装？(y/n): "${RESET})" continue_install

            if [[ "$continue_install" == "y" ]]; then
                docker stop uptime-kuma
                docker rm uptime-kuma
                INFO1 "已停止和删除旧的uptime-kuma容器。"
            else
                INFO1 "已取消部署uptime-kuma监控工具。"
                exit 0
            fi
        fi

        while true; do
            read -e -p "$(echo -e ${GREEN}"请输入监听的端口: "${RESET})" UPTIME_PORT
            # 校验用户输入的端口是否为纯数字且在范围内
            if ! [[ "$UPTIME_PORT" =~ ^[0-9]+$ ]] || ((UPTIME_PORT < 1)) || ((UPTIME_PORT > 65535)); then
                ERROR "端口必须是1到65535之间的纯数字且不可为空。"
            elif lsof -i:$UPTIME_PORT >/dev/null 2>&1; then
                WARN "该端口已被占用，请重新输入！"
            else
                break
            fi
        done

        while true; do
            # 提示用户输入映射的目录
            read -e -p "$(echo -e ${GREEN}"请输入数据持久化在宿主机上的目录路径: "${RESET})" MAPPING_DIR
            # 校验用户输入的目录路径是否为空
            if [[ -z "$MAPPING_DIR" ]]; then
                ERROR "目录路径不能为空。"
            else
                break
            fi
        done

        # 检查目录是否存在，如果不存在则创建
        if [ ! -d "${MAPPING_DIR}" ]; then
            mkdir -p "${MAPPING_DIR}"
            INFO1 "目录已创建：${MAPPING_DIR}"
        fi

        # 启动 Docker 容器
        docker run -d --restart=always -p "${UPTIME_PORT}":3001 -v "${MAPPING_DIR}":/app/data --name uptime-kuma louislam/uptime-kuma:1
        # 检查 uptime-kuma 容器状态
        status_uptime=`docker container inspect -f '{{.State.Running}}' uptime-kuma 2>/dev/null`

        # 判断容器状态并打印提示
        if [[ "$status_uptime" == "true" ]]; then
            SUCCESS "CHECK"
            Progress
            SUCCESS1 ">>>>> Docker containers are up and running."
            INFO1 "uptime-kuma 安装完成，请在浏览器输入 IP:${UPTIME_PORT} 进行访问。"
        else
            SUCCESS "CHECK"
            Progress
            ERROR ">>>>> The following containers are not up"
            if [[ "$status_uptime" != "true" ]]; then
                ERROR "uptime-kuma 安装过程中出现问题，请检查日志或手动验证容器状态。"
            fi
        fi
    elif [[ "$uptime" == "n" ]]; then
        # 取消部署uptime-kuma
        WARN "已取消部署uptime-kuma监控工具！"
    else
        ERROR "选项错误！请重新运行脚本并选择正确的选项。"
        exit 1
    fi
}

deploy_go_chatgpt_api() {
    INFO1 "部署 go-chatgpt-api"
    GO_INSTALL_PROXY
    GO_DEL_IMG_NONE
    print_prompt_go
    GO_ADD_IMAGESUP
    GO_ADD_EM_ALERT
}

deploy_ninja_chatgpt_api() {
    INFO1 "部署 ninja-chatgpt-api"
    ninja_INSTALL_PROXY
    ninja_DEL_IMG_NONE
    print_prompt_ninja
    ninja_ADD_EM_ALERT
}

show_menu() {
    echo "--------------------------------------------------------"
    echo -e "${GREEN}请选择要部署的应用:${RESET}"
    echo -e "1. go-chatgpt-api"
    echo -e "2. ninja-chatgpt-api"
    echo -e "3. 退出脚本"
}

print_prompt_go() {
SUCCESS "PROMPT"
INFO1 "HTTP公开接口"
echo "ChatGPT-API:
  http(s)://host:port/chatgpt/backend-api/
ChatGPT-To-API:
  http(s)://host:port/imitate"
}

print_prompt_ninja() {
SUCCESS "PROMPT"
INFO1 "HTTP公开接口"
echo "ChatGPT-API:
  http(s)://host:port/public-api/*
  http(s)://host:port/backend-api/*
OpenAI-API:
  http(s)://host:port/v1/*
Platform-API:
  http(s)://host:port/dashboard/*
ChatGPT-To-API:
  http(s)://host:port/to/v1/chat/completions"
if [ "$webui" = "n" ];then
INFO1 "Ninja WEB UI URL"
echo "请在浏览器访问下面的地址
  http(s)://host:port"
fi

if [ "$GPT3Arkose" == "y" ]; then
INFO1 "HAR文件上传URL"
echo "请在浏览器访问下面的地址
  http(s)://host:port/har/upload"
fi
}

main() {
    CHECK_CPU
    CHECK_OPENAI
    CHECK_PACKAGE_MANAGER
    CHECK_PKG_MANAGER
    CHECK_OS
    CHECKFIRE
    INSTALL_PACKAGE

    show_menu
    echo "--------------------------------------------------------"
    read -e -p "$(echo -e ${GREEN}"请输入对应的数字: "${RESET})" api_choice
    echo "--------------------------------------------------------"
    case $api_choice in
        1)
            deploy_go_chatgpt_api
            ;;
        2)
            deploy_ninja_chatgpt_api
            ;;
        3)
            exit 0
            ;;
        *)
            ERROR "无效选项，请重新输入数字并选择正确的选项"
            exit 1
            ;;
    esac

    ADD_UPTIME_KUMA
    TGCODE
}
main
