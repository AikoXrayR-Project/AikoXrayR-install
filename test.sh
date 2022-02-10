
#giới hạn thiết bị
    echo "Giới hạn thiết bị < nếu không nhập sẽ cài mặt định là 2 >"
    echo ""
    read -p "Vui lòng nhập Số thiết bị tối đa: " DeviceLimit
    [ -z "${DeviceLimit}" ]
    echo "---------------------------"
    echo "giới hạn số thiết bị: ${Devicelimit}"
    echo "---------------------------"
    echo ""


    sed -i "s/DeviceLimit:.*/DeviceLimit: ${Devicelimit}/g" /etc/XrayR/config.yml