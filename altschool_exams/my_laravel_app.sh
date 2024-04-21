#!/bin/bash

#define variables
DB_CONNECTION="mysql"
DB_HOST="127.0.0.1"
DB_PORT="3306"
DB_DATABASE="laravel"
DB_USERNAME="praise"
DB_PASSWORD="password"

# Update package lists
sudo apt update

#install apache2
echo 'Installing Apache web server'
sudo apt install -y apache2
echo 'Apache web server has been installed'

#install package repository
sudo add-apt-repository ppa:ondrej/php --yes

# Update package lists
sudo apt update

#Install php
echo "Install PHP and it's dependencies"
sudo apt install -y php8.2
sudo apt install -y php8.2-curl php8.2-dom php8.2-mbstring php8.2-xml php8.2-mysql zip unzip
echo "PHP and it's dependencies has been installed"

#rewrite apache module
sudo a2enmod rewrite
sudo systemctl restart apache2

#change directory
cd /usr/bin

#install composer
sudo curl -sS https://getcomposer.org/installer | sudo php -q
sudo mv composer.phar composer
echo "You've successfully installer composer"

cd /var/www/
# Clone the PHP Git repository
sudo git clone https://github.com/laravel/laravel.git
sudo chown -R root laravel

#install autoloader
cd /var/www/laravel
sudo composer install --no-interaction --optimize-autoloader --no-dev
sudo composer update --no-interaction

#setup staging environment
sudo cp .env.example .env
sudo php artisan key:generate
sudo chown -R www-data storage
sudo chown -R www-data bootstrap/cache


# Check if the .env file exists
if [ -f ".env" ]; then
    # Uncomment and update database configuration
    sudo sed -i "s/^#* *\(DB_CONNECTION=\).*/\1${DB_CONNECTION}/" .env
    sudo sed -i "s/^#* *\(DB_HOST=\).*/\1${DB_HOST}/" .env
    sudo sed -i "s/^#* *\(DB_PORT=\).*/\1${DB_PORT}/" .env
    sudo sed -i "s/^#* *\(DB_DATABASE=\).*/\1${DB_DATABASE}/" .env
    sudo sed -i "s/^#* *\(DB_USERNAME=\).*/\1${DB_USERNAME}/" .env
    sudo sed -i "s/^#* *\(DB_PASSWORD=\).*/\1${DB_PASSWORD}/" .env
    
    echo "Database configuration updated in .env file"
else
    echo ".env file not found. Please create one."
fi

# Create a virtual host configuration file for Apache
sudo bash -c 'cat <<EOF > /etc/apache2/sites-available/mylaravelapp.conf
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/laravel/public

    <Directory /var/www/laravel>
        Options Indexes FollowSymLinks MultiViews
        AllowOverride All
        Order allow,deny
        allow from all
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF'

#disable apache default site
sudo a2dissite 000-default

# Enable the virtual host
sudo a2ensite mylaravelapp.conf
sudo systemctl restart apache2


# Print a message indicating the setup is complete
echo "PHP Git repository cloned and configured into Apache2 default site. You can access it using the IP address of this machine."

echo 'Setting up database'

#install mysql
echo 'Install MySQL'
sudo apt install -y mysql-server
echo 'MySQL has been installed'

sudo apt install mysql-client
sudo systemctl start mysql

#update database with MySQL commands
sudo mysql -uroot -e "CREATE DATABASE ${DB_DATABASE};"
sudo mysql -uroot -e "CREATE USER '${DB_USERNAME}'@'localhost' IDENTIFIED BY '${DB_PASSWORD}';"
sudo mysql -uroot -e "GRANT ALL PRIVILEGES ON ${DB_DATABASE} . * TO '${DB_USERNAME}'@'localhost';"
sudo mysql -uroot -e "FLUSH PRIVILEGES;"

sudo php artisan migrate
sudo php artisan db:seed

echo 'Restarting the service'
sudo systemctl restart apache2


echo "Checking the status of the services"

echo Apache service is $(systemctl show -p ActiveState --value apache2)
echo MySQL service is $(systemctl show -p ActiveState --value mysql)


