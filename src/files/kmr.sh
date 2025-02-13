#!/bin/bash

# Define color for yellow
YELLOW='\033[1;33m'
GRENN='\033[32m'
NC='\033[0m' # No Color

# Set DEBIAN_FRONTEND to noninteractive to avoid GUI prompts during installation
export DEBIAN_FRONTEND=noninteractive

# Update and install required packages
echo -e "${YELLOW}Updating system and installing Apache, PHP, MySQL, phpMyAdmin...${NC}"
apt install -y apache2 php mariadb-server phpmyadmin wget unzip expect

# Enable Apache modules (ensure URL rewriting works for WordPress)
echo -e "${YELLOW}Enabling necessary Apache modules...${NC}"
a2enmod rewrite
systemctl restart apache2

# Navigate to the web directory
cd /var/www/html/

# Download WordPress
echo -e "${YELLOW}Downloading WordPress...${NC}"
wget http://172.16.90.2/unduh/wordpress.zip

# List files in the directory
echo -e "${YELLOW}Listing files in /var/www/html/...${NC}"
ls

# Unzip the WordPress package
echo -e "${YELLOW}Unzipping WordPress...${NC}"
unzip wordpress.zip

# Set permissions for the WordPress directory
echo -e "${YELLOW}Setting permissions for WordPress directory...${NC}"
chmod -R 777 wordpress

# Prompt for MySQL root password
echo -e "${YELLOW}Enter MySQL root password:${NC}"
read -s ROOT_PASS

# Prompt for database name, username, and password
echo -e "${YELLOW}BUAT DATABASE WordPress:${NC} \c"
read DB_NAME

echo -e "${YELLOW}BUAT USER UNTUK WordPress:${NC} \c"
read DB_USER

echo -e "${YELLOW}Enter the password for the MySQL WordPress user:${NC} \c"
read -s DB_PASS

# Automate mysql_secure_installation
echo -e "${YELLOW}Automating mysql_secure_installation...${NC}"

expect <<EOF
spawn mysql_secure_installation

# Enter MySQL root password
expect "Enter current password for root (enter for none):"
send "$ROOT_PASS\r"

# Set root password (answer 'Y' for setting root password)
expect "Set root password? [Y/n]"
send "Y\r"

# New password for MySQL root
expect "New password:"
send "$ROOT_PASS\r"

# Re-enter new password
expect "Re-enter new password:"
send "$ROOT_PASS\r"

# Remove anonymous users
expect "Remove anonymous users? [Y/n]"
send "Y\r"

# Disallow remote root login
expect "Disallow root login remotely? [Y/n]"
send "Y\r"

# Remove test database
expect "Remove test database and access to it? [Y/n]"
send "Y\r"

# Reload privilege tables
expect "Reload privilege tables now? [Y/n]"
send "Y\r"

# End the expect block
expect eof
EOF

# Log in to MySQL and create the database and user
echo -e "${YELLOW}Creating MySQL database and user...${NC}"
mysql -u root -p"$ROOT_PASS" <<MYSQL_SCRIPT
CREATE DATABASE $DB_NAME;
CREATE USER '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASS';
GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost';
FLUSH PRIVILEGES;
MYSQL_SCRIPT

# Generate random authentication keys and salts for WordPress
AUTH_KEY=$(openssl rand -base64 32)
SECURE_AUTH_KEY=$(openssl rand -base64 32)
LOGGED_IN_KEY=$(openssl rand -base64 32)
NONCE_KEY=$(openssl rand -base64 32)
AUTH_SALT=$(openssl rand -base64 32)
SECURE_AUTH_SALT=$(openssl rand -base64 32)
LOGGED_IN_SALT=$(openssl rand -base64 32)
NONCE_SALT=$(openssl rand -base64 32)

# Create wp-config.php file automatically
echo -e "${YELLOW}Creating wp-config.php file...${NC}"

cat <<EOL > /var/www/html/wordpress/wp-config.php
<?php
/**
 * The base configuration for WordPress
 *
 * The wp-config.php creation script uses this file during the installation.
 * You don't have to use the web site, you can copy this file to "wp-config.php" and fill in the values.
 *
 * @link https://codex.wordpress.org/Editing_wp-config.php
 *
 * @package WordPress
 */

// ** MySQL settings - You can get these from your web host ** //
define( 'DB_NAME', '$DB_NAME' );
define( 'DB_USER', '$DB_USER' );
define( 'DB_PASSWORD', '$DB_PASS' );
define( 'DB_HOST', 'localhost' );

// ** Authentication Unique Keys and Salts.**
define( 'AUTH_KEY',         '$AUTH_KEY' );
define( 'SECURE_AUTH_KEY',  '$SECURE_AUTH_KEY' );
define( 'LOGGED_IN_KEY',    '$LOGGED_IN_KEY' );
define( 'NONCE_KEY',        '$NONCE_KEY' );
define( 'AUTH_SALT',        '$AUTH_SALT' );
define( 'SECURE_AUTH_SALT', '$SECURE_AUTH_SALT' );
define( 'LOGGED_IN_SALT',   '$LOGGED_IN_SALT' );
define( 'NONCE_SALT',       '$NONCE_SALT' );

// ** Database Table prefix.**
$table_prefix = 'wp_';

// ** For developers: WordPress debugging mode.**
define( 'WP_DEBUG', false );

/* That's all, stop editing! Happy publishing. */

/** Absolute path to the WordPress directory. */
if ( !defined('ABSPATH') )
	define('ABSPATH', __DIR__ . '/' );

/** Sets up WordPress vars and included files. */
require_once(ABSPATH . 'wp-settings.php');
EOL

# Display completion message
echo -e "${YELLOW}Database and user created successfully. wp-config.php file generated.${NC}"

# Restart Apache to apply changes
echo -e "${YELLOW}Restarting Apache...${NC}"
systemctl restart apache2

# Display instructions for next steps
echo -e "${YELLOW}You can now access WordPress by visiting http://<your-server-ip>/wordpress in your browser.${NC}"
echo -e "${YELLOW}Installation complete!${NC}"
echo "///////////////////////////////////////////////////////////"
echo -e "${GRENN} Script Created BY @Bangkomar232@gmail.com ${NC}"
echo "///////////////////////////////////////////////////////////"
