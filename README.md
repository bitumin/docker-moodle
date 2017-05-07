# Entorno docker para instalaciones de Moodle

## Resumen

Todo lo necesario para ejecutar Moodle (php, mysql, nginx, memcached, redis...) correrá en contenedores docker, pero gestionaremos las distintas instalaciones de Moodle en nuestro entorno local para ganar en flexibilidad a la hora de testear nuevas versiones de Moodle, mantener instalaciones con configuraciones distintas, etc.

## Requerimientos del entorno local

* git: para gestionar los repositorios de moodle
* docker y docker-compose: para gestionar las imágenes y contenedores docker
* docker-sync: opcional, sólo en OSX, para mejorar el rendimiento de docker
* node y npm: opcional, frontend dev, para para gestionar módulos amd en moodle
* php y composer: opcional, testing, para instalar dependencias PHP necesarias para phpunit, behat, etc.

## Preparación del entorno docker

```
git clone https://github.com/bitumin/docker-moodle.git docker-moodle
cd docker-moodle
docker-compose up -d # initialize and start all containers
```

Comprueba que el servidor web servidor por el contenedor docker funciona correctamente visitando con un browser `http://localhost`

## Realizar nueva instalación de Moodle

```
cd public
git clone --depth=1 -b MOODLE_[VERSION]_STABLE git://git.moodle.org/moodle.git [MOODLE_PATH] # Versión estable
# git clone --depth=1 -b master git://git.moodle.org/moodle.git [MOODLE_PATH] # Última versión de Moodle
```

0. Visitar http://localhost/\[MOODLE_PATH\] para terminar la instalación de Moodle
1. Elegir idioma deseado
2. Elegir directorio de datos (si vamos a trabajar con múltiples instalaciones crear un nuevo moodledata para cada una)
3. Controlador de base de datos: MySQL mejorado (natice/mysqli)
4. Configuración base de datos:
    * Servidor: mysql
    * Nombre: moodle
    * Usuario: moodle
    * Password: moodle
    * Prefijo: mdl_ (si vamos a trabajar con múltiples instalaciones usar un prefijo único para cada una)
    * Puerto: 3306
    * Socket: (dejar en blanco)
5. Aceptar términos y condiciones
6. Comprobaciones del servidor: debería aparecer todo en OK (testeado en Moodle 3.1 y Moodle 3.2)
7. Continuar y esperar que se acabe de realizar la instalación Moodle
8. Elegir nueva constraseña y dirección de correo para el usuario admin
9. Elegir nombre y nombre corto para el nuevo sitio Moodle. Elegir dirección de correo para noreply.

## Configuración adicional de la instalación Moodle

Modifica los ficheros `config.php` de tus instalaciones Moodle que habrán sido generados durante la instalación. Puedes utilizar como referencia el fichero `config-dev.php` (en la raíz de este proyecto), con ejemplos de configuraciones típicas para un entorno de desarrollo. 

## Servicios disponibles

Service|Hostname|Port number
------|---------|-----------
Webserver|[localhost](http://localhost)|80
php-fpm|php-fpm|9000
MySQL|mysql|3306
Memcached|memcached|11211
Redis|redis|6379

## Docker compose: cheatsheet

  * Start containers in the background: `docker-compose up -d`
  * Start containers on the foreground: `docker-compose up`. You will see a stream of logs for every container running.
  * Stop containers: `docker-compose stop`
  * Kill containers: `docker-compose kill`
  * View container logs: `docker-compose logs`
  * Execute command inside of container: `docker-compose exec SERVICE_NAME COMMAND` where `COMMAND` is whatever you want to run. Examples:
    * Shell into the PHP container, `docker-compose exec php-fpm bash`
    * Open a mysql shell, `docker-compose exec mysql mysql -uroot -pCHOSEN_ROOT_PASSWORD`

## Recomendaciones de uso de docker

* Run composer outside of the php container, as doing so would install all your dependencies owned by `root` within your vendor folder.
* Run cli apps (ie Symfony's console, or Laravel's artisan) straight inside of your container. You can easily open a shell as described above and do your thing from there.

## Por hacer

* Configuración ssh
* Configuración phpunit
* Configuración behat
* Configuración memchaced
* Configuración redis

## Créditos

Ficheros originales pre-generados usando [https://phpdocker.io/generator](https://phpdocker.io/generator)
