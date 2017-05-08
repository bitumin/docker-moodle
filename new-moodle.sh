#!/bin/bash

# Colors
BLACK='\033[0;30m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'
OK="${GREEN}OK${NC}\n"
KO="${RED}ERROR${NC}\n"

# printf with padding
_printf () {
    printf "%-50s" "$1"
}

# Dependencies validation
DEPENDENCIES=(
    mkdir
    dirname
    git
    docker
    docker-compose
    node
    npm
    php
    composer
    sed
)
check_dependency () {
   command -v $1 >/dev/null 2>&1 || { echo "${RED}This script requires $1. Aborting.${NC}" >&2; exit 1; }
}
for dependency in "${DEPENDENCIES[@]}"; do
   check_dependency ${dependency}
done

# Get arguments
for i in "$@"; do
case ${i} in
    --version=*)
    VERSION="${i#*=}"
    shift
    ;;
    --prefix=*)
    PREFIX="${i#*=}"
    shift
    ;;
    *)
    ;;
esac
done

# Arguments validation
if ! [[ ${VERSION} =~ ^-?[0-9]+$ ]]; then
    echo "${RED}version (Moodle version) parameter is required and must be a numeric value. Example: --version=32${NC}"; exit 1
fi
if ! [[ ${PREFIX} =~ ^[-_0-9a-zA-Z]+$ ]]; then
    echo "${RED}prefix parameter is required and must be an alphanumeric value. Example: --prefix=mdl32_${NC}"; exit 1
fi
if [ -d "./public/${PREFIX}moodle" ]; then
    echo "${RED}To avoid conflicts between Moodle installation pick a new prefix (that has never been used before)${NC}"; exit 1
fi
if [ ${VERSION} -lt 29 ]; then
    echo "${RED}Moodle versions under 29 (2.9) are not supported yet by this script.${NC}"; exit 1
fi

# Main script
MOODLEDIR="${PREFIX}moodle"
WWWROOT="http://localhost:8080/${MOODLEDIR}"
DATAROOT="/application/${PREFIX}moodledata"
CHMOD=2777
ADMINUSER="admin"
ADMINPASS="1234Abcd."
ADMINEMAIL="admin@cvaconsulting.com"
LANG="es"
DBTYPE="mysqli"
DBHOST="mysql"
DBPORT=3306
DBNAME="moodle"
DBUSER="moodle"
DBPASS="moodle"
SITENAME="My Moodle site"
SITESHORTNAME="moodle"
SITEDESCRIPTION="My new Moodle site description."

cd "$(dirname "$0")"
echo "Initializing new Moodle ${VERSION} stable installation..."

_printf "Creating new Moodle dataroot..."; mkdir ${PREFIX}moodledata; chmod 0777 ${PREFIX}moodledata; printf "${OK}";
_printf "Creating new PHPUnit dataroot..."; mkdir ${PREFIX}phpu_moodledata; chmod 0777 ${PREFIX}phpu_moodledata; printf "${OK}";
_printf "Creating new Behat dataroot..."; mkdir ${PREFIX}bht_moodledata; chmod 0777 ${PREFIX}bht_moodledata; printf "${OK}";

_printf "Downloading Moodle...";
{
    cd public
    git clone --depth=1 -b MOODLE_${VERSION}_STABLE git://git.moodle.org/moodle.git ${PREFIX}moodle
} &> /dev/null
printf "${OK}";

_printf "Installing Moodle... (may take a while)";
docker-compose exec php-fpm php "/application/public/${MOODLEDIR}/admin/cli/install.php" \
    --chmod=${CHMOD} \
    --lang=${LANG}  \
    --wwwroot="${WWWROOT}" \
    --dataroot="${DATAROOT}" \
    --dbtype=${DBTYPE} \
    --dbhost=${DBHOST} \
    --dbname=${DBNAME} \
    --dbuser=${DBUSER} \
    --dbpass=${DBPASS} \
    --dbport=${DBPORT} \
    --prefix=${PREFIX} \
    --fullname="${SITENAME}" \
    --shortname="${SITESHORTNAME}" \
    --summary="${SITEDESCRIPTION}" \
    --adminuser=${ADMINUSER} \
    --adminpass=${ADMINPASS} \
    --adminemail=${ADMINEMAIL} \
    --non-interactive \
    --agree-license \
    --allow-unstable \
    &> /dev/null; (exit $?)
printf "${OK}"

cd ${PREFIX}moodle

_printf "config.php set default timezone..."
sed -i'' -e '/\$CFG->directorypermissions = 02777;/a\
\
date_default_timezone_set("Europe/Madrid");\
' config.php &> /dev/null
printf "${OK}"

_printf "config.php performance logging..."
sed -i'' -e '/\$CFG->directorypermissions = 02777;/a\
\
define("MDL_PERF", true);\
define("MDL_PERFDB", true);\
define("MDL_PERFTOLOG", true);\
define("MDL_PERFTOFOOT", true);\
' config.php &> /dev/null
printf "${OK}"

_printf "config.php debugging..."
sed -i'' -e '/\$CFG->directorypermissions = 02777;/a\
\
@error_reporting(E_ALL | E_STRICT);\
@ini_set("display_errors", "1");\
\$CFG->debug = (E_ALL | E_STRICT);\
\$CFG->debugdisplay = 1;\
\$CFG->cachejs = false;\
\$CFG->yuiloglevel = "debug";\
\$CFG->langstringcache = false;\
\$CFG->noemailever = true;\
\$CFG->showcronsql = true;\
\$CFG->showcrondebugging = true;\
' config.php &> /dev/null
printf "${OK}"

_printf "config.php PHPUnit..."
sed -i'' -e '/\$CFG->directorypermissions = 02777;/a\
\
\$CFG->phpunit_prefix = "'"${PREFIX}"'phpu_";\
\$CFG->phpunit_dataroot = "/application/'"${PREFIX}"'phpu_moodledata";\
\$CFG->phpunit_directorypermissions = 0777;\
\$CFG->phpunit_profilingenabled = true;\
' config.php &> /dev/null
printf "${OK}"

_printf "Installing Node.js packages..."
npm install &> /dev/null
printf "${OK}"

_printf "Installing composer dependencies..."
composer install &> /dev/null
printf "${OK}"

_printf "Installing Moodle-PHPUnit... (may take a while)"
docker-compose exec php-fpm php "/application/public/${MOODLEDIR}/admin/tool/phpunit/cli/init.php" \
    &> /dev/null; (exit $?);
printf "${OK}"

# todo: correct modified/created file's permissions by init.php script (change ownership to local user:group)

echo "${GREEN}Done.${NC}"
echo ""
echo "New site information:"
echo "${BLACK}Web access:${NC} ${WWWROOT}"
echo "${BLACK}Admin user:${NC} ${ADMINUSER}"
echo "${BLACK}Admin pass:${NC} ${ADMINPASS}"
echo "${BLACK}Mysql host:${NC} ${DBHOST}:${DBPORT}"
echo "${BLACK}Mysql user:${NC} ${DBUSER}"
echo "${BLACK}Mysql pass:${NC} ${DBPASS}"

exit 0
