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




























