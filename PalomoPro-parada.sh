# !/bin/bash

# Variables
PHP_CONTAINER_PREFIX="palomopro-web"
NUM_CONTAINERS=5

# Paro contenedores PHP-apache
echo "Se eliminarán los $NUM_CONTAINERS contenedores de PHP-apache"
for j in $(seq 1 $NUM_CONTAINERS); do
    PHP_CONTAINER_NAME="${PHP_CONTAINER_PREFIX}${j}"

    echo "Parada del contenedor $PHP_CONTAINER_NAME${j} de PHP-apache"
    docker stop "palomopro-web${j}"
    echo ""
done

# Libero memoria eliminando los contenedores inactivos
echo "Libero memoria de contenedores inactivos"
docker container prune -f

# Paro el sevicio haproxy
echo "Paro el servicio haproxy"
systemctl stop haproxy

# Muestro el estado haproxy
echo "Muestro el estado del servicio haproxy apagado"
systemctl status haproxy

echo "El script ha finalizado con éxito"