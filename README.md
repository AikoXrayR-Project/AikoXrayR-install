# XRayR
Một khung phụ trợ Xray có thể dễ dàng hỗ trợ nhiều bảng.

Một khung công tác back-end dựa trên Xray, hỗ trợ các giao thức V2ay, Trojan, Shadowsocks, cực kỳ dễ dàng mở rộng và hỗ trợ kết nối nhiều bảng điều khiển

Tìm mã nguồn tại đây: [XrayR-project/XrayR](https://github.com/AikoCute/XrayR)

## Hướng dẫn chi tiết
[Hướng dẫn](https://xrayr.aikocute.com)

## Cài đặt 
```
bash <(curl -Ls https://raw.githubusercontent.com/AikoCute/XrayR-release/main/install.sh)
```
## Cấu hình xrayr
Vào thư mục này để cấu hình
```
vi /etc/XrayR/config.yml
```
1: dòng `PanelType` : ví dụ `V2board`, `SSpanel`,... (chữ đầu viết hoa)

2: dòng `ApiHost` : Link web ví dụ `https://domain.com/`

3: dòng `ApiKey` : key của web (lấy trên web admin)

4: dòng `NodeID` : `ID` server (tự đặt)

5: dòng `certdomain` : `IP` của server muốn đưa lên web

```
AikoCute Hột Me
```
Nếu bị lỗi xrayr không chạy thì bỏ dòng `DisableSniffing: true` đi nhé 

Dòng nào có ngoặc kép nhớ để ý viết trong ngoặc kép

Cấu hình xong nhớ khởi động lại xrayr nhé.

