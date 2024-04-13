sudo apt-get update && sudo apt-get install -y open-iscsi
sudo systemctl start iscsid
sudo systemctl enable iscsid
sudo apt-get update && sudo apt-get install -y nfs-common

#/etc/sysctl.conf
#fs.file-max = 65536