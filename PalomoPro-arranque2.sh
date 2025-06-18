# Variables
PHP_APACHE_IMAGE="php:8.3-apache"
PHP_CONTAINER_PREFIX="palomopro-web"
START_PHP_PORT=8081
NUM_CONTAINERS=$1
NUM_CONTAINERS2=$1
HAPROXY_CONFIG="/etc/haproxy/haproxy.cfg"

# Inicio servicio de haproxy
systemctl start haproxy

# Creación de contenedores PHP-apache
echo "Se crean los $NUM_CONTAINERS contenedores de PHP-apache"
for j in $(seq 1 $NUM_CONTAINERS); do
    PHP_CONTAINER_NAME="${PHP_CONTAINER_PREFIX}${j}"
    PHP_PORT=$((START_PHP_PORT + J -1))

    echo "Starting PHP-apache container ${PHP_CONTAINER_NAME} en el puerto ${PHP_PORT}..."
    docker run -d --name "palomopro-web${j}" -e PUERTO=${PHP_PORT} -e NOMBRE_CONT=$"php-palomopro${j}" -p "${PHP_PORT}:80" \
    -v /home/mrpro/palomopro-hlc/palomopro-p4/:/var/www/html \
    $PHP_APACHE_IMAGE
    echo ""
done
# Se reescribe la configuración de haproxy con los servidores que acabamos de crear
echo "Escribo la configuración de haproxy"
# Escribimos la configuración de haproxy con sudo
echo "Escribo la configuración de haproxy"
sudo bash -c "cat > ${HAPROXY_CONFIG} <<EOL
defaults
    mode http
    timeout client 10s
    timeout connect 5s
    timeout server 10s
    timeout http-request 10s
    log global

frontend stats
    bind *:8404
    stats enable
    stats uri /haproxy_stats
    stats auth admin:password

backend php_servers
    balance roundrobin
    server web1 127.0.0.1:8081 check
    server web2 127.0.0.1:8082 check
    server web3 127.0.0.1:8083 check
EOL"

# Se reinicia el servicio de haproxy
echo "Reinicio el servicio de haproxy"
systemctl restart haproxy  

echo "El script ha finalizado con éxito"