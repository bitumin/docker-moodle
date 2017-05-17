# Entorno docker para instalaciones de Moodle

## Resumen

Todo lo necesario para ejecutar Moodle (php, mysql, nginx, memcached, redis...) corre en contenedores docker. Gestionamos las distintas instalaciones de Moodle desde nuestro entorno local para flexibilizar el testeo de nuevas versiones de Moodle y el mantenimiento de instalaciones con distintas configuraciones.

## Requerimientos del entorno local

* git: gestionar los repositorios de moodle
* docker y docker-compose: gestionar las imágenes y contenedores docker
* docker-sync: opcional, sólo en OSX, mejorar el rendimiento de docker
* node y npm: opcional, frontend dev, gestionar módulos AMD de Moodle
* php y composer: opcional, testing, instalar dependencias PHP necesarias para los testing frameworks

## Preparación del entorno docker

```
git clone https://github.com/bitumin/docker-moodle.git docker-moodle
cd docker-moodle
docker-compose up -d # prepare images and start all containers
```

Comprueba que el servidor web funciona correctamente visitando `http://localhost:8080`

## Realizar nueva instalación de Moodle (automáticamente)

Puedes utilizar el script new-moodle.sh parar crear una nueva instalación de Moodle. 
El script require de dos parámetros:
* --version=`[MOODLE_VERSION]`: Versión de Moodle que deseas instalar, ej.: 29, 30, 31... (instalará la última versión estable de la version indicada)
* --prefix=`[PREFIX]`: Prefijo para las tablas de base de datos y nuevos directorios (es importante utilizar un prefijo único para cada nueva instalación)

Ejemplo:
```
sh new-moodle.sh --version=32 --prefix=mdl32_
```

## Realizar nueva instalación de Moodle (manualmente)

```
cd public
# Versión estable
git clone --depth=1 -b MOODLE_[VERSION]_STABLE git://git.moodle.org/moodle.git [MOODLE_PATH] 
# Última versión de Moodle
git clone --depth=1 -b master git://git.moodle.org/moodle.git [MOODLE_PATH] 
```

0. Visitar http://localhost:8080/MOODLE_PATH para terminar la instalación de Moodle
1. Elegir idioma deseado
2. Elegir directorio de datos (si vamos a trabajar con múltiples instalaciones crear un nuevo moodledata para cada una)
3. Controlador de base de datos: MySQL mejorado (native/mysqli)
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

Modifica el fichero `config.php` generado durante la instalación. Puedes utilizar como referencia el fichero `config-dev.php` (en la raíz de este proyecto), con ejemplos de configuraciones típicas para un entorno de desarrollo. 

## Servicios disponibles

Service|Hostname|Port number
------|---------|-----------
Webserver|[localhost](http://localhost:8080)|8080
php-fpm|php-fpm|9000
MySQL|mysql|3306
Memcached|memcached|11211
Redis|redis|6379

## Docker compose: cheatsheet

  * Start containers in the background: `docker-compose up -d`
  * Start containers on the foreground: `docker-compose up`. You will see a stream of logs for every container running.
  * Stop containers: `docker-compose stop`
  * Kill containers: `docker-compose kill`
  * Remove containers: `docker-compose rm`
  * Stop and remove container: `docker-compose down`
  * Rebuild images after updating dockerfiles: `docker-compose build --no-cache`
  * View container logs: `docker-compose logs`
  * Execute command inside of container: `docker-compose exec SERVICE_NAME COMMAND` where `COMMAND` is whatever you want to run. Examples:
    * Shell into the PHP container, `docker-compose exec php-fpm bash`
    * Open a mysql shell, `docker-compose exec mysql mysql -uroot -pCHOSEN_ROOT_PASSWORD`

## Docker: cheatsheet

  * Stop all containers, `docker stop $(docker ps -a -q)`
  * Delete all containers `docker rm $(docker ps -a -q)`
  * Delete all images `docker rmi $(docker images -q)`

## Recomendaciones de uso de docker

* Run composer outside of the php container, as doing so would install all your dependencies owned by `root` within your vendor folder.
* Run cli apps (ie Symfony's console, or Laravel's artisan) straight inside of your container. You can easily open a shell as described above and do your thing from there.

## Por hacer

* Configucación docker-sync para máquinas osx
* Configuración behat
* Configuración memchaced
* Configuración redis

## Créditos

Ficheros originales pregenerados con [https://phpdocker.io/generator](https://phpdocker.io/generator)
