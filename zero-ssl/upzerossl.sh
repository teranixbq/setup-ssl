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
