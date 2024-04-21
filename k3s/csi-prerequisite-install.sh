sudo apt-get update && sudo apt-get install -y open-iscsi
sudo systemctl start iscsid
sudo systemctl enable iscsid
sudo apt-get update && sudo apt-get install -y nfs-common


echo 'rc_ulimit="-n 1048576"' >> /etc/rancher/k3s/k3s.env

#/etc/sysctl.conf
#fs.file-max = 65536


# sudo systemctl edit k3s.service

# [Service]
# # Type=notify
# # EnvironmentFile=-/etc/default/%N
# # EnvironmentFile=-/etc/sysconfig/%N
# # EnvironmentFile=-/etc/systemd/system/k3s.service.env
# # KillMode=process
# # Delegate=yes
# # # Having non-zero Limit*s causes performance problems due to accounting overhead
# # # in the kernel. We recommend using cgroups to do container-local accounting.
# LimitNOFILE=1048576
# LimitNPROC=infinity
# LimitCORE=infinity
# TasksMax=infinity
# # TimeoutStartSec=0
# # Restart=always
# # RestartSec=5s
# # ExecStartPre=/bin/sh -xc '! /usr/bin/systemctl is-enabled --quiet nm-cloud-setup.service 2>/dev/null'
# # ExecStartPre=-/sbin/modprobe br_netfilter
# # ExecStartPre=-/sbin/modprobe overlay
# # ExecStart=/usr/local/bin/k3s \
# #     server \
# #       '--cluster-cidr=172.19.0.0/16' \

# sudo systemctl daemon-reload
# sudo systemctl restart k3s

# sudo sysctl -w fs.inotify.max_user_watches=2099999999
# sudo sysctl -w fs.inotify.max_user_instances=2099999999
# sudo sysctl -w fs.inotify.max_queued_events=2099999999