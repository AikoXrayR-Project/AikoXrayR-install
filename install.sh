#!/bin/bash
suijishu=`cat /dev/urandom | tr -dc '0-9a-z' | head -c 15`
git clone https://github.com/AikoCute/XrayR-release /tmp/$suijishu && cd /tmp/$suijishu
sleep 5s
file="./config/config.yml"
link="https://aikocute.com/"
docker_compose_file="./docker-compose.yml"
#Nhập thông tin
read -p "Vui lòng nhập tên vùng chứa < Aiko >：" docker_name
read -p "Vui lòng nhập địa chỉ bảng điều khiển <API Host > ：" apihost
read -p "Vui lòng nhập API Key Web："  apikey
read -p "Vui lòng nhập ID nút：" nodeid


#Ghi thông tin
sed -i "s|$link|$apihost|" $file
sed -i "s|123|$apikey|" $file
sed -i "s|41|$nodeid|" $file
sed -i "s|HIM|$docker_name|" $docker_compose_file

echo "Cấu hình hoàn tất"
echo "bật lên XrayR Docker Compose" && docker-compose up -d


 