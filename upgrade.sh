#!/bin/bash
export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

# 检查系统信息
if [ -f /etc/redhat-release ];then
        OS='CentOS'
    elif [ ! -z "`cat /etc/issue | grep bian`" ];then
        OS='Debian'
    elif [ ! -z "`cat /etc/issue | grep Ubuntu`" ];then
        OS='Ubuntu'
    else
        echo "Not support OS, Please reinstall OS and retry!"
        exit 1
fi

# 安装依赖
if [[ ${OS} == 'CentOS' ]];then
    curl --silent --location https://rpm.nodesource.com/setup_8.x | sudo bash -
	yum install curl wget unzip git ntp ntpdate lrzsz python socat nodejs -y
    npm install -g qrcode
else
    curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
	apt-get update
	apt-get install curl unzip git ntp wget ntpdate python socat lrzsz nodejs -y
    npm install -g qrcode
fi

# 重装V2ray.fun
rm -rf /usr/local/v2ray.fun
cd /usr/local/
git clone https://github.com/tracyone/v2ray.fun
cd /usr/local/v2ray.fun/
chmod +x *.py

# 重装操作菜单
rm -rf /usr/local/bin/v2ray
ln -sf /usr/local/v2ray.fun/v2ray /usr/local/bin/
chmod +x /usr/local/bin/v2ray

# 更新Vray主程序
bash <(curl -L -s https://install.direct/go.sh)

mv /etc/v2ray/config.json /etc/v2ray/config.json.$(date "+%Y%M%d")
cp /usr/local/v2ray.fun/json_template/server.json /etc/v2ray/config.json
let PORT=$RANDOM+10000
UUID=$(cat /proc/sys/kernel/random/uuid)
sed -i "s/cc4f8d5b-967b-4557-a4b6-bde92965bc27/${UUID}/g" /etc/v2ray/config.json
sed -i "s/12345/${PORT}/g" "/etc/v2ray/config.json"

# 初始化环境
python /usr/local/v2ray.fun/openport.py
service v2ray restart

cat /etc/rc.local | grep openport.py
if [[ $? -ne 0 ]]; then
cat>>/etc/rc.local<<EOF
python /usr/local/v2ray.fun/openport.py
EOF
chmod a+x /etc/rc.local
fi


clear
echo "原来的config.json已经另外保存为/etc/v2ray/config.json.$(date "+%Y%M%d")"
echo "脚本已更新！"
