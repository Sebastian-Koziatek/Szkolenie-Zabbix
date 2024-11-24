#!/bin/bash
# Instalacja MariaDB
echo "Instalowanie MariaDB..."
apt update
apt install -y mariadb-server

# Uruchomienie MariaDB
echo "Uruchamianie serwera MariaDB..."
systemctl start mariadb
systemctl enable mariadb

# Ustawienie hasła dla root i zabezpieczenie instalacji
echo "Zabezpieczanie instalacji MariaDB..."
mysql_secure_installation <<EOF

y
password
password
y
y
y
y
EOF

# Tworzenie bazy danych Zabbix
echo "Tworzenie początkowej bazy danych Zabbix..."
mysql -uroot -ppassword <<MYSQL
CREATE DATABASE zabbix CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;
CREATE USER 'zabbix'@'localhost' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON zabbix.* TO 'zabbix'@'localhost';
SET GLOBAL log_bin_trust_function_creators = 1;
QUIT;
MYSQL

# Instalacja Zabbix
echo "Instalowanie Zabbix..."
wget https://repo.zabbix.com/zabbix/7.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_latest+ubuntu24.04_all.deb
dpkg -i zabbix-release_latest+ubuntu24.04_all.deb
apt update
apt install -y zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-sql-scripts zabbix-agent

# Importowanie schematu i danych do bazy danych Zabbix
echo "Importowanie schematu i danych do bazy danych Zabbix..."
zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | mysql --default-character-set=utf8mb4 -uzabbix -ppassword zabbix

# Wyłączanie opcji log_bin_trust_function_creators
echo "Wyłączanie opcji log_bin_trust_function_creators..."
mysql -uroot -ppassword <<MYSQL
SET GLOBAL log_bin_trust_function_creators = 0;
QUIT;
MYSQL

# Sprawdzanie i zmiana konfiguracji DBPassword w pliku /etc/zabbix/zabbix_server.conf
echo "Sprawdzanie i modyfikacja parametru DBPassword w pliku /etc/zabbix/zabbix_server.conf..."
CONF_FILE="/etc/zabbix/zabbix_server.conf"

# Sprawdzenie, czy linia z #DBPassword= istnieje i modyfikacja jej
if grep -q "^# DBPassword=" "$CONF_FILE"; then
    echo "Znaleziono zakomentowany parametr DBPassword, zmieniamy na DBPassword=password."
    # Usuwanie komentarza (usuwamy # z początku linii) i ustawienie DBPassword=password
    sed -i 's/^# DBPassword=.*/DBPassword=password/' "$CONF_FILE"
else
    # Jeśli linia #DBPassword= nie istnieje, dodajemy ją
    echo "Nie znaleziono zakomentowanego parametru DBPassword. Dodajemy go do pliku."
    echo "DBPassword=password" >> "$CONF_FILE"
fi

# Restartowanie wszystkich serwisów Zabbix
echo "Restartowanie serwisów Zabbix..."
systemctl restart zabbix-server zabbix-agent apache2
systemctl enable zabbix-server zabbix-agent apache2

echo "Instalacja i konfiguracja Zabbix zakończona pomyślnie."
