yum install -y docker-io
service docker start
yum install -y git wget

# turn off selinux enforcing, will be re-enabled on reboot
setenforce 0

cd /tmp/

# Install anaconda
wget https://3230d63b5fc54e62148e-c95ac804525aac4b6dba79b00b39d1d3.ssl.cf1.rackcdn.com/Anaconda3-2.3.0-Linux-x86_64.sh
bash Anaconda3-2.3.0-Linux-x86_64.sh -b -p /opt/anaconda
export PATH="/opt/anaconda/bin:$PATH"
echo 'export PATH="/opt/anaconda/bin:$PATH"' >> /root/.bashrc

docker pull swarm
