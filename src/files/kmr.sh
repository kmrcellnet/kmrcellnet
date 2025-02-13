#!/bin/bash

# Definisikan Warna untuk Output
YELLOW='\033[1;33m'
GREEN='\033[32m'
NC='\033[0m' # No Color

# Set DEBIAN_FRONTEND ke noninteractive untuk menghindari prompt GUI
export DEBIAN_FRONTEND=noninteractive

# Update dan Instal Paket yang Diperlukan
echo -e "${YELLOW}Updating system and installing Apache, PHP, MySQL, phpMyAdmin, wget, unzip, and expect...${NC}"
apt update && apt upgrade -y
apt install -y apache2 php mariadb-server phpmyadmin wget unzip expect || { echo "Package installation failed!"; exit 1; }

# Aktifkan Modul Apache yang Diperlukan
echo -e "${YELLOW}Enabling necessary Apache modules...${NC}"
a2enmod rewrite
systemctl restart apache2

# Konfigurasi phpMyAdmin
echo -e "${YELLOW}Configuring phpMyAdmin...${NC}"
ln -s /usr/share/phpmyadmin /var/www/html/phpmyadmin
systemctl restart apache2

# Pindah ke Direktori Web
cd /var/www/html/

# Download WordPress dari URL Resmi
echo -e "${YELLOW}Downloading WordPress...${NC}"
wget https://wordpress.org/latest.zip || { echo "Download failed!"; exit 1; }

# List File dalam Direktori
echo -e "${YELLOW}Listing files in /var/www/html/...${NC}"
ls

# Ekstrak Paket WordPress
echo -e "${YELLOW}Unzipping WordPress...${NC}"
unzip latest.zip
rm latest.zip

# Atur Izin 777 untuk Direktori WordPress
echo -e "${YELLOW}Setting permissions for WordPress directory to 777...${NC}"
chmod -R 777 wordpress
systemctl restart apache2

# Meminta Password Root MySQL
echo -e "${YELLOW}Enter MySQL root password:${NC}"
read -s ROOT_PASS

# Meminta Nama Database, Username, dan Password
echo -e "${YELLOW}BUAT DATABASE WordPress:${NC} \c"
read DB_NAME

echo -e "${YELLOW}BUAT USER UNTUK WordPress:${NC} \c"
read DB_USER

echo -e "${YELLOW}Enter the password for the MySQL WordPress user:${NC} \c"
read -s DB_PASS

# Automasi mysql_secure_installation
echo -e "${YELLOW}Automating mysql_secure_installation...${NC}"

expect <<EOF
spawn mysql_secure_installation
expect "Enter current password for root (enter for none):"
send "\r"
expect "Set root password? [Y/n]"
send "Y\r"
expect "New password:"
send "$ROOT_PASS\r"
expect "Re-enter new password:"
send "$ROOT_PASS\r"
expect "Remove anonymous users? [Y/n]"
send "Y\r"
expect "Disallow root login remotely? [Y/n]"
send "Y\r"
expect "Remove test database and access to it? [Y/n]"
send "Y\r"
expect "Reload privilege tables now? [Y/n]"
send "Y\r"
expect eof
EOF

# Buat Database dan User MySQL
echo -e "${YELLOW}Creating MySQL database and user...${NC}"
mysql -u root -p"$ROOT_PASS" <<MYSQL_SCRIPT
CREATE DATABASE $DB_NAME;
CREATE USER '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASS';
GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost';
FLUSH PRIVILEGES;
MYSQL_SCRIPT

# Generate Authentication Keys and Salts untuk WordPress
AUTH_KEY=$(openssl rand -base64 32)
SECURE_AUTH_KEY=$(openssl rand -base64 32)
LOGGED_IN_KEY=$(openssl rand -base64 32)
NONCE_KEY=$(openssl rand -base64 32)
AUTH_SALT=$(openssl rand -base64 32)
SECURE_AUTH_SALT=$(openssl rand -base64 32)
LOGGED_IN_SALT=$(openssl rand -base64 32)
NONCE_SALT=$(openssl rand -base64 32)

# Buat File wp-config.php secara Otomatis
echo -e "${YELLOW}Creating wp-config.php file...${NC}"

cat <<EOL > /var/www/html/wordpress/wp-config.php
<?php
define( 'DB_NAME', '$DB_NAME' );
define( 'DB_USER', '$DB_USER' );
define( 'DB_PASSWORD', '$DB_PASS' );
define( 'DB_HOST', 'localhost' );

define( 'AUTH_KEY',         '$AUTH_KEY' );
define( 'SECURE_AUTH_KEY',  '$SECURE_AUTH_KEY' );
define( 'LOGGED_IN_KEY',    '$LOGGED_IN_KEY' );
define( 'NONCE_KEY',        '$NONCE_KEY' );
define( 'AUTH_SALT',        '$AUTH_SALT' );
define( 'SECURE_AUTH_SALT', '$SECURE_AUTH_SALT' );
define( 'LOGGED_IN_SALT',   '$LOGGED_IN_SALT' );
define( 'NONCE_SALT',       '$NONCE_SALT' );

\$table_prefix = 'wp_';
define( 'WP_DEBUG', false );

if ( !defined('ABSPATH') )
    define('ABSPATH', __DIR__ . '/' );
require_once(ABSPATH . 'wp-settings.php');
EOL

# Restart Apache untuk Menerapkan Perubahan
echo -e "${YELLOW}Restarting Apache...${NC}"
systemctl restart apache2

# Pesan Selesai
echo -e "${YELLOW}You can now access WordPress by visiting http://<your-server-ip>/wordpress in your browser.${NC}"
echo -e "${YELLOW}Installation complete!${NC}"
echo "///////////////////////////////////////////////////////////"
echo -e "${GREEN} Script Created BY @Bangkomar232@gmail.com ${NC}"
echo "///////////////////////////////////////////////////////////"
