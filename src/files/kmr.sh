#!/bin/bash

# Define color for yellow
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Set DEBIAN_FRONTEND to noninteractive to avoid GUI prompts during installation
export DEBIAN_FRONTEND=noninteractive

# Update and install required packages
echo -e "${YELLOW}Updating system and installing Apache, PHP, MySQL, phpMyAdmin...${NC}"
apt update -y
apt install -y apache2 php mariadb-server phpmyadmin wget unzip

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

# Run mysql_secure_installation
echo -e "${YELLOW}Running mysql_secure_installation...${NC}"
mysql_secure_installation

# Log in to MySQL and create the database and user
echo -e "${YELLOW}Creating MySQL database and user...${NC}"
mysql -u root -p"$ROOT_PASS" <<MYSQL_SCRIPT
CREATE DATABASE $DB_NAME;
CREATE USER '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASS';
GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost';
FLUSH PRIVILEGES;
MYSQL_SCRIPT

# Display completion message
echo -e "${YELLOW}Database and user created successfully. You can now configure WordPress.${NC}"

# Display instructions for next steps
echo -e "${YELLOW}Remember to configure your wp-config.php with the database details.${NC}"
echo -e "${YELLOW}Installation complete!${NC}"
