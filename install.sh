wget https://raw.githubusercontent.com/bowowiwendi/bot_regis/main/add-vps.sh
wget https://raw.githubusercontent.com/bowowiwendi/bot_regis/main/del-ip.sh
wget https://raw.githubusercontent.com/bowowiwendi/bot_regis/main/renew-ip.sh
wget https://raw.githubusercontent.com/bowowiwendi/bot_regis/main/regis.py
wget https://raw.githubusercontent.com/bowowiwendi/bot_regis/main/wendy.txt
chmod +x *.sh
read -p "  Input ID admin Bot : " id
echo "${id}" >> /root/wendy.txt
echo " Imput ID ${id} sukses"
clear
python3 regis.py