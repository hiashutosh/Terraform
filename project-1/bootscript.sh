#!/bin/bash

wordpress_conf() {
cat > wordpress/wp-config.php << EOF
<?php
/**
 * The base configuration for WordPress
 *
 * The wp-config.php creation script uses this file during the installation.
 * You don't have to use the web site, you can copy this file to "wp-config.php"
 * and fill in the values.
 *
 * This file contains the following configurations:
 *
 * * MySQL settings
 * * Secret keys
 * * Database table prefix
 * * ABSPATH
 *
 * @link https://wordpress.org/support/article/editing-wp-config-php/
 *
 * @package WordPress
 */

// ** MySQL settings - You can get this info from your web host ** //
/** The name of the database for WordPress */
define( 'DB_NAME', '${database_name_here}' );

/** MySQL database username */
define( 'DB_USER', '${username_here}' );

/** MySQL database password */
define( 'DB_PASSWORD', '${password_here}' );

/** MySQL hostname */
define( 'DB_HOST', '${localhost}' );

/** Database charset to use in creating database tables. */
define( 'DB_CHARSET', 'utf8' );

/** The database collate type. Don't change this if in doubt. */
define( 'DB_COLLATE', '' );

/**#@+
 * Authentication unique keys and salts.
 *
 * Change these to different unique phrases! You can generate these using
 * the {@link https://api.wordpress.org/secret-key/1.1/salt/ WordPress.org secret-key service}.
 *
 * You can change these at any point in time to invalidate all existing cookies.
 * This will force all users to have to log in again.
 *
 * @since 2.6.0
 */
define( 'AUTH_KEY',         'put your unique phrase here' );
define( 'SECURE_AUTH_KEY',  'put your unique phrase here' );
define( 'LOGGED_IN_KEY',    'put your unique phrase here' );
define( 'NONCE_KEY',        'put your unique phrase here' );
define( 'AUTH_SALT',        'put your unique phrase here' );
define( 'SECURE_AUTH_SALT', 'put your unique phrase here' );
define( 'LOGGED_IN_SALT',   'put your unique phrase here' );
define( 'NONCE_SALT',       'put your unique phrase here' );

/**#@-*/

/**
 * WordPress database table prefix.
 *
 * You can have multiple installations in one database if you give each
 * a unique prefix. Only numbers, letters, and underscores please!
 */
$table_prefix = 'wp_';

/**
 * For developers: WordPress debugging mode.
 *
 * Change this to true to enable the display of notices during development.
 * It is strongly recommended that plugin and theme developers use WP_DEBUG
 * in their development environments.
 *
 * For information on other constants that can be used for debugging,
 * visit the documentation.
 *
 * @link https://wordpress.org/support/article/debugging-in-wordpress/
 */
define( 'WP_DEBUG', false );

/* Add any custom values between this line and the "stop editing" line. */



/* That's all, stop editing! Happy publishing. */

/** Absolute path to the WordPress directory. */
if ( ! defined( 'ABSPATH' ) ) {
	define( 'ABSPATH', __DIR__ . '/' );
}

/** Sets up WordPress vars and included files. */
require_once ABSPATH . 'wp-settings.php';

EOF
}

wordpress_key() {
    awk '
            /put your unique phrase here/ {
                    cmd = "head -c1m /dev/urandom | sha1sum | cut -d\\  -f1"
                    cmd | getline str
                    close(cmd)
                    gsub("put your unique phrase here", str)
            }
            { print }
    ' wordpress/wp-config.php > wp-config.php
    
    cp wp-config.php wordpress/wp-config.php
}


nginx_conf() {
sudo cat > default << EOF
server {
    listen 80;
    listen [::]:80;
    server_name default_server;

    root /var/www/html/wordpress;
    listen 443 ssl default_server;
    listen [::]:443 ssl default_server;
    ssl_certificate /etc/nginx/ssl/ca.crt;
    ssl_certificate_key /etc/nginx/ssl/ca.key;
    index index.php index.html index.nginx-debian.html;
    server_name _;
    location / {
        try_files \$uri \$uri/ /index.php\$is_args\$args;
    }
    location ~ \.php$ {
        try_files \$uri =404;
        fastcgi_split_path_info ^(.+\.php)(/.+);
        fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_\script_name;
        fastcgi_param PATH_INFO \$fastcgi_path_info;
    }
        location ~ /\.ht {
            deny all;
        }
    }
EOF

server {
        listen 80 default_server;
        listen [::]:80 default_server;

        root /var/www/html;
        server_name worker1.unixcop.com;

        location / {
                # First attempt to serve request as file, then
                try_files $uri $uri/ /index.php$is_args$args;
        }
        location = /favicon.ico { log_not_found off; access_log off; }
        location = /robots.txt { log_not_found off; access_log off; allow all; }
        location ~* \.(css|gif|ico|jpeg|jpg|js|png)$ {
                expires max;
                log_not_found off;
        }
        location ~ \.php$ {
                try_files $uri =404;
                fastcgi_split_path_info ^(.+\.php)(/.+)$;
                fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;
                fastcgi_index index.php;
                fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
                include fastcgi_params;
        }
}

server {
        listen 80;
        listen [::]:80;
        root /var/www/html/mysite.com;
        index  index.php index.html index.htm;
        server_name mysite.com www.mysite.com;

        error_log /var/log/nginx/mysite.com_error.log;
        access_log /var/log/nginx/mysite.com_access.log;
        
        client_max_body_size 100M;
        location / {
                try_files $uri $uri/ /index.php?$args;
        }
        location ~ \.php$ {
                include snippets/fastcgi-php.conf;
                fastcgi_pass unix:/run/php/php7.4-fpm.sock;
                fastcgi_param   SCRIPT_FILENAME $document_root$fastcgi_script_name;
        }
}

server {
        listen 80;

        root /var/www/wordpress;
        index index.php index.html index.htm;

        server_name blog.scw-site.ml;

        error_page 404 /404.html;

        error_page 500 502 503 504 /50x.html;
        location = /50x.html {
                root /usr/share/nginx/html;
        }
location / {
                # try_files $uri $uri/ =404;
                try_files $uri $uri/ /index.php?q=$uri&$args;
        }

        location ~ \.php$ {
                try_files $uri =404;
                fastcgi_split_path_info ^(.+\.php)(/.+)$;
                fastcgi_pass unix:/var/run/php5-fpm.sock;
                fastcgi_index index.php;
                fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
                include fastcgi_params;
        }

location = /favicon.ico {
        access_log off;
        log_not_found off;
        expires max;
}
location = /robots.txt {
        access_log off;
        log_not_found off;
}

# Cache Static Files For As Long As Possible
location ~*
\.(ogg|ogv|svg|svgz|eot|otf|woff|mp4|ttf|css|rss|atom|js|jpg|jpeg|gif|png|ico|zip|tgz|gz|rar|bz2|doc|xls|exe|ppt|tar|mid|midi|wav|bmp|rtf)$
{
        access_log off;
        log_not_found off;
        expires max;
}
# Security Settings For Better Privacy Deny Hidden Files
location ~ /\. {
        deny all;
        access_log off;
        log_not_found off;
}
# Return 403 Forbidden For readme.(txt|html) or license.(txt|html)
if ($request_uri ~* "^.+(readme|license)\.(txt|html)$") {
    return 403;
}
# Disallow PHP In Upload Folder
location /wp-content/uploads/ {
        location ~ \.php$ {
                deny all;
        }
}
}


server {
listen 80;
listen [::]:80;
root /var/www/servonode;
index index.php index.html index.htm;
server_name example.com www.example.com;

client_max_body_size 100M;

location / {
try_files $uri $uri/ /index.php?$args; 
}

location ~ \.php$ {
include snippets/fastcgi-php.conf;
fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;
fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
}
}

sudo cp default /etc/nginx/sites-available/default 
}

sudo apt update -y
sudo apt purge apache2 -y
sudo apt install -y nginx php-curl php php-mysql php-gd php-cli php-common php-fpm
cd /tmp/
wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz

sudo mkdir -p /etc/nginx/ssl/
sudo openssl req -nodes -x509 -newkey rsa:2048 -keyout /etc/nginx/ssl/ca.key -out /etc/nginx/ssl/ca.crt -subj "/C=IN/ST=UP/L=Kanpur/O=testing/OU=root/CN=test@gmail.com"

wordpress_conf
wordpress_key
nginx_conf
sudo mkdir -p /var/www/html/
sudo cp -a wordpress/. /var/www/html/wordpress
sudo chown -R www-data:www-data /var/www/html/wordpress
sudo /usr/bin/find /var/www/html/wordpress -type d -exec chmod 755 {} \;
sudo /usr/bin/find /var/www/html/wordpress -type f -exec chmod 644 {} \;

sudo systemctl start nginx
sudo systemctl enable nginx
sudo nginx -s reload
