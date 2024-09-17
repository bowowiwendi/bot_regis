#!/bin/bash
export HOME=/root
export TERM=xterm

NC='\e[0m'
dateFromServer=$(curl -v --insecure --silent https://google.com/ 2>&1 | grep Date | sed -e 's/< Date: //')
biji=$(date +"%Y-%m-%d" -d "$dateFromServer")
ipsaya=$(wget -qO- ipinfo.io/ip)
data_server=$(curl -v --insecure --silent https://google.com/ 2>&1 | grep Date | sed -e 's/< Date: //')
date_list=$(date +"%Y-%m-%d" -d "$data_server")

clear
Repo1="https://raw.githubusercontent.com/bowowiwendi/ipvps/main/ip"
export MYIP=$( curl -s https://ipinfo.io/ip/ )
SELLER=$(curl -sS ${Repo1}ip | grep $MYIP | awk '{print $2}')
Exp=$(curl -sS ${Repo1}ip | grep $MYIP | awk '{print $3}')
data_ip="https://raw.githubusercontent.com/bowowiwendi/ipvps/main/ip"
d2=$(date -d "$date_list" +"+%s")
d1=$(date -d "$Exp" +"+%s")
dayleft=$(( ($d1 - $d2) / 86400 ))

#########################
[[ ! -f /usr/bin/git ]] && apt install git -y &> /dev/null
# COLOR VALIDATION
clear
RED='\033[0;31m'
NC='\e[0m'
gray="\e[1;30m"
Blue="\033[1;36m"
GREEN='\033[0;32m'
grenbo="\033[1;95m"
YELL='\033[1;33m'
BGX="\033[42m"
END='\e[0m'
AKTIF="VERIFIED"
REPO="https://github.com/bowowiwendi/ipvps.git"
REPO2="https://raw.githubusercontent.com/bowowiwendi/ipvps/main/ip"
EMAIL="bowowiwendi@gmail.com"
USER="bowowiwendi"

function send_log() {
TIMES="10"
CHATID=$(grep -E "^#bot# " "/etc/bot/.bot.db" | cut -d ' ' -f 3)
KEY=$(grep -E "^#bot# " "/etc/bot/.bot.db" | cut -d ' ' -f 2)
URL="https://api.telegram.org/bot$KEY/sendMessage"
TEXT1="
<code>───────────────────────────</code>
<code>    SUCCES DELETE  IP VPS</code>
<code>───────────────────────────</code>
<code>USERNAME       : $name</code>
<code>IP Address     : $ipdel</code>
<code>Expired On     : $exp</code>
<code>───────────────────────────</code>
"
curl -s --max-time $TIMES -d "chat_id=$CHATID&disable_web_page_preview=1&text=$TEXT1&parse_mode=html" $URL >/dev/null
}
    rm -rf /root/ipvps
    mkdir /root/ipvps
    touch /root/ipvps/ip
    wget -q -O /root/ipvps/ip "${REPO2}" &> /dev/null
    read -p "   Input IP Address To Delete : " ip
    name=$(cat /root/ipvps/ip | grep $ip | awk '{print $4}')
    exp=$(cat /root/ipvps/ip | grep $ip | awk '{print $3}')
    sed -i "/^### $name $exp $ip/,/^},{/d" /root/ipvps/ip
    cd /root/ipvps
    git config --global user.email "${EMAIL}" &> /dev/null
    git config --global user.name "${USER}" &> /dev/null
    rm -rf .git &> /dev/null
    git init &> /dev/null
    git add . &> /dev/null
    git commit -m "update file" &> /dev/null
    git branch -M main &> /dev/null
    git remote add origin git@github.com:bowowiwendi/ipvps.git
    git push -f origin main &> /dev/null
    rm -rf /root/ipvps
    clear
    send_log