# practica-iaw-1.10
# Balanceador de carga con Nginx
## 1. Introducción
En esta práctica configuramos una arquitectura de aplicación web en tres niveles utilizando Nginx como balanceador de carga.

La infraestructura constará de cuatro máquinas virtuales creadas en Amazon Web Services (AWS):

1. <ins>Balanceador de carga (Load Balancer)</ins>:
- Nginx como servidor de balanceo.
- Configurado para HTTPS con Certbot.
2. <ins>Dos Frontales Web</ins>:
- Configurados para servir páginas PHP.
- Conectados a una base de datos MySQL en el servidor backend.
3. <ins>Servidor MySQL:</ins>
- Base de datos central para la arquitectura.


Para ello desarrollaremos varios scripts que dividiremos entre los que tenemos que instalar en la maquina que actuará con Frontend y otros que instalaremos en la maquina que actuará como Backend.



## 2. Creación de dos instancias nuevas en EC2 en AWS

Para empezar a crear nuestras maquinas deberemos primero crear otro grupo de seguridad
-El grupo de seguidad para el <ins>*LoadBalancer*</ins>, que llamaremos por ejemplo <ins>*gs_Loadbalancer*</ins> , con las siguientes reglas de entrada: 

  ![ETVm1eadKB](https://github.com/user-attachments/assets/d8ef9e2f-1513-44dd-a89a-032f45248a8b)


Crearemos dos instancias:
- Una llamada LoadBalancer que será el balanceador de carga, con un sistema Ubuntu server y con el grupo de seguridad que hemos creado antes.
- Otro Frontend al que le asociaremos el grupo de seguridad Frontend que creamos en la practica [Práctica 1.9](https://github.com/marinaferb92/practica-iaw-1.9/tree/main)

Tambien crearemos y asociaremos dos IPs elásticas a cada una de ellas.

- la IP de la maquina <ins>*LoadBalancer*</ins> es la siguiente

  ![sBaaSkFbL6](https://github.com/user-attachments/assets/6e0f45d6-07fc-4036-a08a-ceca9600e414)

- la IP de la maquina <ins>*Frontend*</ins> es la siguiente

  ![ESJNli6sv5](https://github.com/user-attachments/assets/6d6ec5f4-4a99-467a-97e5-5d994f676341)



## 3. Instalación de pila LAMP en el nuevo Frontend

En la nueva maquina Frontend deberemos ejecutar el script que habiamos creado para la practica 1.9 [install_lamp_frontend.sh](https://github.com/marinaferb92/practica-iaw-1.9/blob/0d65a1954498b7fb4e5bb7d673ec30ec078b2fac/scripts/install_lamp_frontend.sh)



## 4. Registrar un Nombre de Dominio

Usamos un proveedor gratuito de nombres de dominio como son Freenom o No-IP.
En nuestro caso lo hemos hecho a traves de No-IP, nos hemos registrado en la página web y hemos registrado un nombre de dominio con la IP pública del servidor *Loadbalancer*.

![image](https://github.com/user-attachments/assets/dd32dd87-dcb6-4d26-afc4-8d432183d293)





## 5. Instalación del balanceador de carga.

### 1. Cargamos el archivo de variables
El primer paso de nuestro script sera crear un archivo de variable ``` . env ``` donde iremos definiendo las diferentes variables que necesitemos, y cargarlo en el entorno del script.

``` source.env ```



### 2. Configuramos el script
   
Configuraremos el script para que en caso de que haya errores en algun comando este se detenga ```-e```, ademas de que para que nos muestre los comando antes de ejecutarlos ```-x```.

``` set -ex ```



### 3. Actualización del sistema

Actualizamos la lista de paquetes en el sistema.

````
apt update
````



### 4. Actualización de todos los paquetes

Actualizamos todos los paquetes instalados en el sistemacon la opción -y se aceptan automáticamente la actualización sin pedir confirmación.

``
apt upgrade -y
``



### 5. Instalación de Nginx

Instalamos el servidor web Nginx.

``
apt install nginx -y
``



### 6. Deshabilitar el Virtual Host por defecto de Nginx

- <ins>**if [ -f "/etc/nginx/sites-enabled/default" ]:**</ins>

  Verifica si el archivo default existe en el directorio /etc/nginx/sites-enabled/. (El archivo que configura el Virtual Host por defecto de Nginx.)
  
- <ins>**unlink /etc/nginx/sites-enabled/default:**</ins>

  Si el archivo default existe, se elimina el enlace simbólico a este archivo, habilitando el Virtual Host por defecto

- <ins>**echo "Virtualhost por defecto deshabilitado.":**</ins>

  Enseña un mensaje en la consola indicando que el Virtual Host por defecto ha sido deshabilitado.

``
if [ -f "/etc/nginx/sites-enabled/default" ]; then
    unlink /etc/nginx/sites-enabled/default
    echo "Virtualhost por defecto deshabilitado."
fi
``



### 7. Copiar el archivo de configuración de Nginx

Copiamos el archivo loadbalancer.conf al directorio /etc/nginx/sites-available/. 

``
cp ../conf/loadbalancer.conf /etc/nginx/sites-available/
``

Este archivo contiene la configuración personalizada de Nginx para el balanceo de carga y contendra la siguiente estructura.

````
upstream frontend_servers {
    server IP_FRONTEND_1;
    server IP_FRONTEND_2;
}

server {
    listen 80;
    server_name LE_DOMAIN;

    location / {
        proxy_pass http://frontend_servers;
    }
}
````




### 8. Sustituir los valores en el archivo de configuración

Con el comando sed sustituiremos los valores IP_FRONTEND_1 por el valor de la variable *$IP_FRONTEND_1*

También sustituiremos el valor de IP_FRONTEND_2 por el valor de la variable $IP_FRONTEND_2 y el de LE_DOMAIN por el valor de la variable $LE_DOMAIN.

Estas variables estarán definidas en el archivo *.env*

````
sed -i "s/IP_FRONTEND_1/$IP_FRONTEND_1/" /etc/nginx/sites-available/loadbalancer.conf
sed -i "s/IP_FRONTEND_2/$IP_FRONTEND_2/" /etc/nginx/sites-available/loadbalancer.conf
sed -i "s/LE_DOMAIN/$LE_DOMAIN/" /etc/nginx/sites-available/loadbalancer.conf
````




### 9. Habilitar el sitio de configuración de Nginx

- <ins>**if [ ! -f "/etc/nginx/sites-enabled/loadbalancer.conf" ]**</ins>:

  Verifica si el archivo loadbalancer.conf no existe en el directorio /etc/nginx/sites-enabled/.
- <ins>**ln -s /etc/nginx/sites-available/loadbalancer.conf /etc/nginx/sites-enabled/:**</ins>

  Si el archivo no existe, se crea un enlace simbólico a loadbalancer.conf desde el directorio sites-available a sites-enabled.
  
````
if [ ! -f "/etc/nginx/sites-enabled/loadbalancer.conf" ]; then
    ln -s /etc/nginx/sites-available/loadbalancer.conf /etc/nginx/sites-enabled/
fi
````



### 10. Recargar Nginx para aplicar los cambios

Reiniciamos el servicio de Nginx para que cargue la nueva configuración y se apliquen los cambios. 

````
systemctl restart nginx
````




## 5. Instalar Certbot y Configurar el Certificado SSL/TLS con Let’s Encrypt
Para la realizacion de este apartado seguiremos los pasos detallados en la practica-iaw-1.5 y utilizaremos el script ``` setup_letsencrypt_certificate.sh ```.

aunque deberemos cambiar la última línea del script para que funcione en un sistema Nginx
````
sudo certbot --nginx -m $LE_EMAIL --agree-tos --no-eff-email -d $LE_DOMAIN --non-interactive
````

Tras esto una vez que entremos en el dominio configurado, podremos verificar que el certiicado se ha instalado correctamente.

  ![w9FJxDPDQH](https://github.com/user-attachments/assets/952a028a-2388-48ed-95e6-0af4f1ffab74)


[Practica-iaw-1.5](https://github.com/marinaferb92/practica-iaw-1.5)




## 6. Comprobaciones

Entraremos en el dominio que hemos configurado, al pulsar `F5` vemos como el balanceador de carga nos irá cambiando de un servidor Frontend a otro repetidamente.
  ![Z2aiZxGhWF](https://github.com/user-attachments/assets/bbbce43d-5135-4b2a-b76f-f7687e0380ad)
  ![YGQvEmSrCD](https://github.com/user-attachments/assets/9c8c7a21-6a89-4a7a-9048-8d5633c8fe59)







