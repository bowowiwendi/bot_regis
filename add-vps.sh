#!/bin/bash
NC='\e[0m'
export HOME=/root
export TERM=xterm
# Mengambil tanggal dari server
dateFromServer=$(curl -v --insecure --silent https://google.com/ 2>&1 | grep Date | sed -e 's/< Date: //')
data_server=$(curl -v --insecure --silent https://google.com/ 2>&1 | grep Date | sed -e 's/< Date: //')
date_list=$(date +"%Y-%m-%d" -d "$data_server")

clear
Repo1="https://raw.githubusercontent.com/bowowiwendi/ipvps/main/ip"
export MYIP=$(curl -s https://ipinfo.io/ip/)
SELLER=$(curl -sS ${Repo1}ip | grep $MYIP | awk '{print $2}')
Exp=$(curl -sS ${Repo1}ip | grep $MYIP | awk '{print $3}')
d2=$(date -d "$date_list" +"+%s")
d1=$(date -d "$Exp" +"+%s")
dayleft=$(( ($d1 - $d2) / 86400 ))

# Memastikan git terinstal
[[ ! -f /usr/bin/git ]] && apt install git -y &> /dev/null

# Warna untuk output
RED='\033[0;31m'
GREEN='\033[0;32m'
EMAIL="bowowiwendi@gmail.com"
USER="bowowiwendi"

# Mengambil informasi bot Telegram
function send_log() {
TIMES="10"
CHATID=$(grep -E "^#bot# " "/etc/bot/.bot.db" | cut -d ' ' -f 3)
KEY=$(grep -E "^#bot# " "/etc/bot/.bot.db" | cut -d ' ' -f 2)
URL="https://api.telegram.org/bot$KEY/sendMessage"
TEXT="
<code>───────────────────────────</code>
<code> SUCCES  REGISTERED IP VPS </code>
<code>───────────────────────────</code>
<code>USERNAME       : $name</code>
<code>IP Address     : $ip</code>
<code>Registered On  : $today</code>
<code>Expired On     : $exp2</code>
<code>───────────────────────────</code>
"
curl -s --max-time $TIMES -d "chat_id=$CHATID&disable_web_page_preview=1&text=$TEXT&parse_mode=html" $URL >/dev/null
}
# Membuat direktori dan mengunduh daftar IP
today=$(date -d "0 days" +"%Y-%m-%d")
mkdir -p /root/ipvps
touch /root/ipvps/ip
wget -q -O /root/ipvps/ip "${Repo1}" &> /dev/null || { echo "Failed to download IP list"; exit 1; }

# Meminta input dari pengguna

read -p "  Input IP Address : " ip
read -p "  Input Username IP (Example : Wendy) : " name
read -p "  Input Expired Days : " exp11
if ! [[ "$exp11" =~ ^[0-9]+$ ]]; then
    exp2="lifetime"
else
    exp2=$(date -d "$exp11 days" +"%Y-%m-%d")
fi
echo "### ${name} ${exp2} ${ip}" >> /root/ipvps/ip

# Mengatur git dan mengunggah perubahan
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
send_log