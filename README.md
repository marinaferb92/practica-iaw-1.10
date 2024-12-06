# practica-iaw-1.10
# Balanceador de carga con Nginx
## 1. Introducción
En esta práctica configuramos una arquitectura de aplicación web en tres niveles utilizando Nginx como balanceador de carga.

La infraestructura constará de cuatro máquinas virtuales creadas en Amazon Web Services (AWS):

1. <ins>Balanceador de carga (Load Balancer)</ins>:
- Nginx como servidor de balanceo.
- Dirección IP elástica asociada.
- Configurado para HTTPS con Certbot.
2. <ins>Dos Frontales Web</ins>:
- Configurados para servir páginas PHP.
- Conectados a una base de datos MySQL en el servidor backend.
- Servidor MySQL:
3. <ins>Servidor MySQL:</ins>
- Base de datos central para la arquitectura.

- Configuración del servidor web con Apache y PHP. <ins>(*Frontend*)</ins> 
- Configuración del servidor MySQL con soporte para conexiones remotas. <ins>(*Backend*)</ins> 
- Integración de una aplicación web que se conecta al servidor de base de datos remoto. <ins>(*Wordpress*)</ins>

[Usuario] --> [Servidor Apache/PHP] --> [Servidor MySQL]

Para ello desarrollaremos varios scripts que dividiremos entre los que tenemos que instalar en la maquina que actuará con Frontend y otros que instalaremos en la maquina que actuará como Backend.

## 2. Creación de una instancia EC2 en AWS

Para empezar a crear nuestras maquinas deberemos primero crear dos grupos de seguridad diferenciados
-El grupo de seguidad para el <ins>*Frontend*</ins> , que llamaremos por ejemplo <ins>*gs_Frontend*</ins> , con las siguientes reglas de entrada: 

  ![nEXNnoDtX0](https://github.com/user-attachments/assets/6c9b5957-657f-4546-bcca-74f3a7a5163d)


-El grupo de seguidad para el <ins>*Backend*</ins> , que llamaremos por ejemplo <ins>*gs_Backend*</ins> , con las siguientes reglas de entrada: 

  ![rgdoo0bIyy](https://github.com/user-attachments/assets/9af7db71-59ee-45eb-8605-5496bb20d09c)

A continuacion, lanzaremos las instancias y seleccionaremos para cada una el grupo de seguridad que hemos creado para ellas.

Tambien crearemos y asociaremos dos IPs elásticas a cada una de ellas.

- la IP de la maquina <ins>*Frontend*</ins> es la siguiente

  ![TWXoA6P5Op](https://github.com/user-attachments/assets/a5aec8b3-bd36-4085-9615-9babb266c538)

- la IP de la maquina <ins>*Backend*</ins> es la siguiente

  ![zHjLAoEvzB](https://github.com/user-attachments/assets/fcf52f0f-20a1-402c-98ba-4de8ff2c6747)
