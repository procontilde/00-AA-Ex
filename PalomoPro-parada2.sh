# !/bin/bash

# Variables
PHP_CONTAINER_PREFIX="palomopro-web"
NUM_CONTAINERS=$1

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

# Contar los contenedores docker en ejecución
num_containers=$(docker ps -q | wc -l)

# Si no hay contenedores en ejecución, detengo haproxy
if [ "$num_containers" -eq 0 ]; then
    systemctl stop haproxy
    echo "haproxy detenido porque no hay contenedores docker en ejecución"
else
    echo "Hay contenedores docker en ejecución: haproxy no se detendrá"
fi

# Muestro el estado haproxy
echo "Muestro el estado del servicio haproxy apagado"
systemctl status haproxy

echo "El script ha finalizado con éxito"