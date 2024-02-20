## Free SSL dengan ZeroSSL

1. Register akun terlebih dahulu [disini](https://app.zerossl.com/signup)

2. Klik `New Certificate` 

## Step 3 : Masukkan domain

![zerossl](https://github.com/teranixbq/setup-ssl/assets/66883583/cbea337d-414f-427a-a9da-bbb574db7f58)

- Set `Validity` 90 Day (free plan)
- Klik `on button` auto generate CSR
- Pilih free plan

## Step 4 : Verifikasi domain

![WhatsApp Image 2024-02-20 at 9 53 20 PM](https://github.com/teranixbq/setup-ssl/assets/66883583/98f43c65-de9b-4504-8786-014e4d5501b6)

Ada 3 metode verifikasi, bisa menggunakan email, DNS (CNAME), atau HTTP file upload. Tapi pada tulisan ini verifikasi menggunakan `DNS (CNAME)`.

Hanya perlu membuat record dns baru pada menu konfigurasi DNS di layanan domain. Set `TTL` ke 1 jam (1hr). Setelah itu lanjut ke next step dan tunggu proses verifikasi selesai.

![zero](https://github.com/teranixbq/setup-ssl/assets/66883583/af309a02-bed1-4755-995a-2144d10b36f8)


## Step 5 : Install certificate

Download terlebih dahulu certificatenya. Pilih Nginx
![zero](https://github.com/teranixbq/setup-ssl/assets/66883583/8008bb61-5ca2-4194-a099-7d764c20079d)

ekstrak file zip dari hasil download certificate, didalamnya terdapat 3 file `ca_bundle.crt, certificate.crt, private.key`. Yang akan digunakan untuk SSL yaitu certificate.crt dan private.key, namun sebelumnya lakukan penggabungan file .crt dengan bundle ca.


_merge .crt files↴_
```
cat certificate.crt ca_bundle.crt >> certificate.crt
```
2 file tersebut (certificate.crt & private.key) harus disimpan didalam server. Maka keduanya harus di salin terlebih dahulu, atau melakukan unzip dan merge .crt didalam server. 

Anda bisa gunakan kode script ini untuk melakukan otomatis unzip dan copy ke server dari local.

---

_upload.sh↴_
```sh
SSH_USER=<your-user-host>
SSH_HOST=<your-host>
SSH_DIRECTORY=<your-directory>   # directory for certificate ssl. e.g >> /etc/ssl/testing
SSH_KEY=<your-ssh-key-path>      # e.g >> ~/.ssh/key.pem
FILE_ZIP=<your-file-zip>         # download on zero ssl
FOLDER=<destination-ekstrak>

cd Downlo
# Unzip file testing.zip
unzip $FILE_ZIP -d $FOLDER

# Masuk ke folder hasil ekstrak
cd $FOLDER

# Menggabungkan file certificate.crt dan ca_bundle.crt
cat certificate.crt ca_bundle.crt >> certificate.crt

# Membuat folder testing di server
ssh -i $SSH_KEY $SSH_USER@$SSH_HOST "sudo mkdir $SSH_DIRECTORY && sudo chmod o+w $SSH_DIRECTORY"

# Mengupload file certificate.crt ke server
sudo scp -i $SSH_KEY certificate.crt private.key $SSH_USER@$SSH_HOST:$SSH_DIRECTORY

# Mengubah kembali akses folder
ssh -i $SSH_KEY $SSH_USER@$SSH_HOST "sudo chmod o-w $SSH_DIRECTORY"

# Memberikan notifikasi bahwa proses telah selesai
echo "Proses upload file selesai."

```

## Step 6 : Konfigurasi Nginx

Setelah melakukan unzip serta mengupload certificate ssl di folder server. Lalu melakukan settingan Nginx sederhana, yang nantinya lokasi path file certificate akan di setting di konfigurasi nginx.

- **Pergi** ke `/etc/nginx/site-available/` dan buat konfigurasi baru dengan nama apapun.
- **Masukkan kode** dibawah ini untuk konfigurasi (ganti bagian yang diperlukan)

    ```nginx
    server {
        listen 80;
        listen 443 ssl;
        server_name domain.com;  #ganti dengan nama domain anda
        
        ssl_certificate    /etc/ssl/testing/certificate.crt;  # ganti dengan path certificate yang ada diserver
        ssl_certificate_key    /etc/ssl/testing/private.key;    

        # folder root 
        root /var/www/html;

        index index.html index.htm;
    }

    ```
- **Buat tautan simbolik**

    ```bash
    sudo ln -s /etc/nginx/sites-available/namafile /etc/nginx/sites-enabled/namafile
    ```
    ganti `namafile` dengan nama file konfigurasi anda

- **Cek Nginx Konfigurasi**

    Lakukan pengecekkan apakah konfigurasi sudah benar dengan command ini :
    ```bash
    sudo nginx -t
    ```
    jika outputnya seperti ini berarti sudah ok,
    ```bash
    nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
    nginx: configuration file /etc/nginx/nginx.conf test is successful
    ```

- **Reload Nginx**

    ```bash
    sudo systemctl reload nginx
    ```

Terakhir cek domain anda di browser, web akan menampilkan default html Nginx sederhana dan ada lambang kunci di urlnya  artinya sudah berhasil menerapkan SSL 🚀