#!/bin/bash
apt update -y
#apt install apache2 -y
myip=`curl http://169.254.169.254/latest/meta-data/local-ipv4`
#cat <<EOF > /var/www/html/index.html
#<html>
#<body bgcolor="black">
#<h2><font color="gold">Build by Power of Terraform <font color="red"> v0.12</font></h2><br><p>
#<font color="green">Server PrivateIP: <font color="aqua">$myip<br><br>
#<font color="magenta">
#<b>Version 3.0</b>
#</body>
#</html>
#EOF
apt install openssh-server -y
apt install mc -y
#apt install git-lfs -y
apt install python-minimal -y 
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDm7GhOxCFlcsl4dKAE5zLEvZTNtXywAbJM/cCSIG/IPCFw0yVGEGnIe5U1s0zrC/08yRpMxSLjroHIOKAykF1X/BYsggiRxHuPzXVEPrD9E39jg9B7SZmZ/c9gmcWCG7Ikq/EEHGKzHEgq2zfg1Ki3+bW6XXrokVOpBGGDHyzFHCoq4jLhKxls4UqoIbOsFK7RrAkFwhe9wXXwQ0dgP8NFTFM8RDhU6hIgL0T+ehxevU3fJspj1vJgHvZUFpYEddhLp+Aetb8kuoqzyM8ZmnLAbwjkrI4q25NoPLLp2xviEtJarY4WQ1AY4EsidfU9IhhhEfV5DUcpMRmLAL7APKat administrator@debian" >> /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys
