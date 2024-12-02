#!/bin/bash 

# Para mostrar los comandos que se van ejecutando
set -ex

# Cargamos las variables de configuración
source .env

# Borramos descargas previas de WP-CLI
rm -rf /tmp/wp-cli.phar

# Descargamos el archivo wp-cli.phar
wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -P /tmp

# Asignamos permisos de ejecución al archivo 
chmod +x /tmp/wp-cli.phar

# Movemos el script WP-CLI al directorio /usr/local/bin
mv /tmp/wp-cli.phar /usr/local/bin/wp

# Borramos instalaciones previas en /var/www/html
rm -rf $WORDPRESS_DIRECTORY*

# Descargamos el código fuente de WordPress 
wp core download \
  --locale=es_ES \
  --path=$WORDPRESS_DIRECTORY \
  --allow-root

# Crear el archivo de configuración de WordPress (configuración sin base de datos)
wp config create \
  --dbname=$WORDPRESS_DB_NAME \
  --dbuser=$WORDPRESS_DB_USER \
  --dbpass=$WORDPRESS_DB_PASSWORD \
  --dbhost=$BACKEND_PRIVATE_IP \
  --path=$WORDPRESS_DIRECTORY \
  --allow-root

# Instalar WordPress (sin crear base de datos, solo configurando el frontend)
wp core install \
  --url=$LE_DOMAIN \
  --title="$WORDPRESS_TITLE" \
  --admin_user=$WORDPRESS_ADMIN_USER \
  --admin_password=$WORDPRESS_ADMIN_PASS \
  --admin_email=$WORDPRESS_ADMIN_EMAIL \
  --path=$WORDPRESS_DIRECTORY \
  --allow-root

# Instalar y activar un tema
wp theme install mindscape --activate --path=$WORDPRESS_DIRECTORY --allow-root

# Instalar y activar un plugin (Wp Hide Login)
wp plugin install wps-hide-login --activate --path=$WORDPRESS_DIRECTORY --allow-root

# Configurar el plugin de seguridad WPS Hide Login
wp option update whl_page "$WORDPRESS_HIDE_LOGIN_URL" --path=$WORDPRESS_DIRECTORY --allow-root

# Configurar los enlaces permanentes con el nombre de las entradas
wp rewrite structure '/%postname%/' --path=$WORDPRESS_DIRECTORY --allow-root

# Copiar el archivo .htaccess de configuración personalizada
cp ../htaccess/.htaccess $WORDPRESS_DIRECTORY

# Dar permisos a www-data para el directorio de WordPress
chown -R www-data:www-data $WORDPRESS_DIRECTORY

sed -i "/COLLATE/a $_SERVER['HTTPS'] = 'on';" /var/www/html/wp-config.php

# Reiniciar el servicio de Apache 
systemctl restart apache2 
