#!/bin/bash -eux

# Install postgresql
sudo apt-get install -y postgresql-9.5 postgresql-contrib-9.5 postgresql-client-9.5

# Set password for postgres database user
sudo -u postgres psql postgres postgres -c "ALTER USER postgres WITH ENCRYPTED PASSWORD 'postgres'"

# allow all users to access postgres locally from any user
sudo rm /etc/postgresql/9.5/main/pg_hba.conf
echo "local   all             all                                     md5"|sudo tee --append /etc/postgresql/9.5/main/pg_hba.conf
echo "local   all             postgres                                peer"|sudo tee --append /etc/postgresql/9.5/main/pg_hba.conf
echo "local   all             all                                     peer"|sudo tee --append /etc/postgresql/9.5/main/pg_hba.conf
echo "host    all             all             0.0.0.0/0            md5"|sudo tee --append /etc/postgresql/9.5/main/pg_hba.conf
echo "host    all             all             ::1/128                 md5"|sudo tee --append /etc/postgresql/9.5/main/pg_hba.conf

echo "listen_addresses = '*'" |sudo tee  --append /etc/postgresql/9.5/main/postgresql.conf

sudo service postgresql restart
