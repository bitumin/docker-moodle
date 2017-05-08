#!/bin/bash

# Colors
BLACK='\033[0;30m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'
OK="${GREEN}OK${NC}\n"
KO="${RED}ERROR${NC}\n"

# Dependencies validation
DEPENDENCIES=(
    mkdir
    dirname
    git
    docker
    docker-compose
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
echo "Creating new data directories..."
printf "Moodle dataroot...     "; mkdir ${PREFIX}moodledata; chmod 0777 ${PREFIX}moodledata; printf "${OK}";
printf "PHPUnit dataroot...    "; mkdir ${PREFIX}phpu_moodledata; chmod 0777 ${PREFIX}phpu_moodledata; printf "${OK}";
printf "Behat dataroot...      "; mkdir ${PREFIX}bht_moodledata; chmod 0777 ${PREFIX}bht_moodledata; printf "${OK}";
printf "Downloading Moodle...  ";
{
    cd public
    git clone --depth=1 -b MOODLE_${VERSION}_STABLE git://git.moodle.org/moodle.git ${PREFIX}moodle
    # cd ${PREFIX}moodle
    # rm -rf .git
} &> /dev/null
printf "${OK}";
printf "Installing Moodle...   ";
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
    &> /dev/null \
    && {
        printf "${OK}"
        echo "${BLACK}Web access:${NC} ${WWWROOT}"
        echo "${BLACK}Admin user:${NC} ${ADMINUSER}"
        echo "${BLACK}Admin pass:${NC} ${ADMINPASS}"
        echo "${BLACK}Mysql host:${NC} ${DBHOST}:${DBPORT}"
        echo "${BLACK}Mysql user:${NC} ${DBUSER}"
        echo "${BLACK}Mysql pass:${NC} ${DBPASS}"
        exit 0
    } \
    || printf "${KO}"; exit 1
