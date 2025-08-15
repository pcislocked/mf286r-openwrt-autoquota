# mf286r-openwrt-kotasiken
A simple script querying LTE data quota via sms-tool and returning value periodically via telegram so i can buy more if i need.


abi telekoma sms atıp ne kadar int kaldı diye soruyo işte. osnra bana atıyo. normalde 5gb altında kalınca ek 10gb direkt alıyodu MOBIL EK 10GB diye mesaj atıp. biraz kontrolden çıkınca o kısmı sildim. 

türk telekom için bu, ama içini az düzenleyip kendi operatörünüzün mesajına göre de olabilir. otomatik kota alma kısmını da ekleyebilirim geri umursayan olursa

örnek çıktı;

```
root@ist-gw-2:~# ./quota.sh
kotasiken
sms sent sucessfully: 63
mesaj bekleniyor
--> sms bekliyom(1/10)...
kalan int 17650 MB, sınır 5120 MB
telegrama mesaj atıldı
root@ist-gw-2:~#
```

scriptin içine telegram bot tokeninizi ve chat id'nizi eklemeyi unutmayın

curl ve [sms_tool](https://github.com/4IceG/luci-app-sms-tool) GEREKLİDİR.
