#!/bin/bash

# Define color for yellow
YELLOW='\033[1;33m'
GREEN='\033[32m'
NC='\033[0m' # No Color

# Set DEBIAN_FRONTEND to noninteractive to avoid GUI prompts during installation
export DEBIAN_FRONTEND=noninteractive

# Update and install required packages
echo -e "${YELLOW}Updating system and installing Apache, PHP, MySQL, phpMyAdmin...${NC}"
apt update -y
apt install -y apache2 php mariadb-server phpmyadmin wget unzip

# Create symbolic link for phpMyAdmin
echo -e "${YELLOW}Creating symbolic link for phpMyAdmin...${NC}"
ln -s /usr/share/phpmyadmin /var/www/html/phpmyadmin

# Restart Apache to apply the changes
echo -e "${YELLOW}Restarting Apache...${NC}"
systemctl restart apache2

# Navigate to the web directory
cd /var/www/html/

# Download WordPress
echo -e "${YELLOW}Downloading WordPress...${NC}"
wget http://172.16.90.2/unduh/wordpress.zip

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
echo -e "${GREEN}Enter WordPress Database Name:${NC} \c"
read DB_NAME

echo -e "${GREEN}Enter WordPress Database User:${NC} \c"
read DB_USER

echo -e "${GREEN}Enter WordPress Database Password:${NC} \c"
read -s DB_PASS

# Log in to MySQL and create the database and user
echo -e "${YELLOW}Creating MySQL database and user...${NC}"
mysql -u root -p"$ROOT_PASS" <<MYSQL_SCRIPT
CREATE DATABASE $DB_NAME;
CREATE USER '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASS';
GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost';
FLUSH PRIVILEGES;
MYSQL_SCRIPT

# Get the server IP address
SERVER_IP=$(hostname -I | awk '{print $1}')

# Display completion message
echo -e "${YELLOW}Database and user created successfully. You can now configure WordPress.${NC}"

# Automatically configure wp-config.php
echo -e "${YELLOW}Configuring wp-config.php file with database details...${NC}"

WP_CONFIG_PATH="/var/www/html/wordpress/wp-config.php"

# If wp-config.php doesn't exist, copy the sample file
if [ ! -f "$WP_CONFIG_PATH" ]; then
    cp /var/www/html/wordpress/wp-config-sample.php $WP_CONFIG_PATH
fi

# Update wp-config.php with database info
sed -i "s/database_name_here/$DB_NAME/" $WP_CONFIG_PATH
sed -i "s/username_here/$DB_USER/" $WP_CONFIG_PATH
sed -i "s/password_here/$DB_PASS/" $WP_CONFIG_PATH
sed -i "s/localhost/$SERVER_IP/" $WP_CONFIG_PATH

# Display instructions for next steps
echo -e "${YELLOW}WordPress is now configured. You can access it via the server IP.${NC}"
echo -e "${GREEN}Installation complete! You can now access phpMyAdmin at http://$SERVER_IP/phpmyadmin.${NC}"
echo -e "${GREEN}You can also access WordPress at http://$SERVER_IP/wordpress.${NC}"
echo -e "${GREEN}///////////////////////////////////////////////////////////////////////${NC}"
echo -e "${GREEN}Script by Bangkomar232@gmail.com.${NC}"
echo -e "${GREEN}@nkmrx_18${NC}"
echo -e "${GREEN}//////////////////////////////////////////////////////////////////////${NC}"
