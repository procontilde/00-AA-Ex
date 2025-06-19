¡Excelente pregunta! Es fundamental entender estas dos formas de interactuar con los contenedores Docker, ya que cada una tiene un propósito diferente.

Aquí te explico detalladamente ambas metodologías.

---

### 1. Gestión desde Fuera del Contenedor (La forma estándar)

Esta es la manera más común y recomendada de gestionar contenedores. Tratas al contenedor como una "caja negra" y utilizas los comandos de Docker desde la terminal de tu máquina anfitriona (tu propio ordenador) para controlarlo.

**Ventajas:**
*   **Automatizable:** Todos los comandos se pueden incluir en scripts.
*   **Seguro:** No modificas el estado interno del contenedor de forma manual y efímera.
*   **Coherente con la filosofía de Docker:** Los contenedores deben ser inmutables y predecibles.

#### Comandos Clave para la Gestión Externa:

Imagina que tenemos un contenedor corriendo llamado `mi_servidor_web`.

**A. Ciclo de Vida del Contenedor:**

*   **Ver contenedores en ejecución:**
    ```bash
    docker ps 
    ```
*   **Ver todos los contenedores (incluidos los detenidos):**
    ```bash
    docker ps -a
    ```
*   **Detener un contenedor:**
    ```bash
    docker stop mi_servidor_web
    ```
*   **Iniciar un contenedor detenido:**
    ```bash
    docker start mi_servidor_web
    ```
*   **Reiniciar un contenedor:**
    ```bash
    docker restart mi_servidor_web
    ```
*   **Eliminar un contenedor (debe estar detenido primero):**
    ```bash
    docker rm mi_servidor_web
    ```
*   **Eliminar un contenedor en ejecución (forzar eliminación):**
    ```bash
    docker rm -f mi_servidor_web
    ```

**B. Inspección y Logs:**

*   **Ver los logs (la salida estándar) de un contenedor:** Esto es crucial para la depuración.
    ```bash
    docker logs mi_servidor_web
    ```
*   **Ver los logs en tiempo real (como `tail -f`):**
    ```bash
    docker logs -f mi_servidor_web
    ```
*   **Ver el consumo de recursos (CPU, RAM, Red):**
    ```bash
    docker stats
    ```
*   **Obtener información detallada (IP, volúmenes, etc.) en formato JSON:**
    ```bash
    docker inspect mi_servidor_web
    ```

**C. Manejo de Archivos:**

*   **Copiar archivos desde tu máquina hacia el contenedor:**
    ```bash
    # Sintaxis: docker cp <ruta_local> <nombre_contenedor>:<ruta_en_contenedor>
    docker cp ./mi_archivo.html mi_servidor_web:/usr/share/nginx/html/
    ```
*   **Copiar archivos desde el contenedor hacia tu máquina:**
    ```bash
    # Sintaxis: docker cp <nombre_contenedor>:<ruta_en_contenedor> <ruta_local>
    docker cp mi_servidor_web:/var/log/nginx/access.log ./logs_del_servidor.log
    ```

**D. Ejecutar un Comando Único Dentro del Contenedor:**

*   Si solo necesitas ejecutar un comando rápido sin entrar en una sesión interactiva, usa `docker exec`.
    ```bash
    # Listar archivos dentro de una carpeta del contenedor
    docker exec mi_servidor_web ls -l /app

    # Ver el espacio en disco dentro del contenedor
    docker exec mi_servidor_web df -h
    ```

---

### 2. Gestión Entrando en el Contenedor (Para Depuración)

Esta metodología consiste en abrir una "shell" o terminal interactiva dentro de un contenedor que ya está en ejecución. Es el equivalente a hacer "SSH" a un servidor virtual.

**¿Cuándo se usa?**
*   **Depuración (Debugging):** Cuando los logs no son suficientes y necesitas explorar el estado interno del contenedor.
*   **Exploración:** Para entender la estructura de archivos de una imagen que no conoces.
*   **Pruebas rápidas:** Para probar la conectividad de red desde dentro del contenedor (`ping`, `curl`).

**Importante:** Evita usar este método para configurar tu aplicación. Cualquier cambio que hagas dentro del contenedor (instalar paquetes, modificar archivos de configuración) **se perderá si el contenedor se elimina y se vuelve a crear**. La configuración debe hacerse en el `Dockerfile` o a través de volúmenes y variables de entorno.

#### Comando Clave para Entrar en un Contenedor:

El comando es `docker exec` con las opciones `-it`.

*   `-i` (`--interactive`): Mantiene la entrada estándar (STDIN) abierta para que puedas escribir comandos.
*   `-t` (`--tty`): Asigna una pseudo-terminal, lo que te da un prompt de comandos interactivo.

**El comando final que se ejecuta suele ser un intérprete de comandos (shell):**
*   `/bin/bash` (el más común y con más funcionalidades).
*   `/bin/sh` (una shell más básica, presente en imágenes minimalistas como Alpine Linux).

**Ejemplo Práctico:**

1.  Asegúrate de que tu contenedor (`mi_servidor_web`) está en ejecución (`docker ps`).

2.  Ejecuta el siguiente comando para entrar:
    ```bash
    docker exec -it mi_servidor_web /bin/bash
    ```
    *Si `/bin/bash` no existe (común en imágenes Alpine), prueba con `/bin/sh`.*
    ```bash
    docker exec -it mi_servidor_web /bin/sh
    ```

3.  **¡Ya estás dentro!** Verás un nuevo prompt, por ejemplo `root@a1b2c3d4e5f6:/#`. Ahora estás operando dentro del entorno aislado del contenedor.

4.  **¿Qué puedes hacer dentro?**
    *   Navegar por el sistema de archivos: `ls -l`, `cd /app`, `pwd`.
    *   Ver procesos en ejecución *dentro* del contenedor: `ps aux`.
    *   Leer archivos: `cat /etc/hosts`.
    *   Probar la conexión de red: `ping google.com` (si la herramienta `ping` está instalada).

5.  **Para salir del contenedor** y volver a la terminal de tu máquina, simplemente escribe:
    ```bash
    exit
    ```
    o presiona `Ctrl + D`.

---

### Resumen Clave: ¿Cuándo Usar Cada Método?

| Situación                                    | Método Recomendado                                         | Comando Ejemplo                                    |
| -------------------------------------------- | ---------------------------------------------------------- | -------------------------------------------------- |
| **Operaciones diarias** (iniciar, parar, reiniciar) | **Gestión Externa**                                        | `docker start`, `docker stop`                      |
| **Ver logs de la aplicación**                | **Gestión Externa**                                        | `docker logs -f mi_contenedor`                     |
| **Copiar archivos**                          | **Gestión Externa**                                        | `docker cp archivo.txt mi_contenedor:/tmp/`        |
| **Automatizar tareas en scripts**            | **Gestión Externa**                                        | (Cualquier comando `docker ...` en un script)      |
| **Necesito depurar un problema complejo**    | **Gestión Interna (Entrar)**                               | `docker exec -it mi_contenedor /bin/bash`          |
| **Explorar el sistema de archivos**          | **Gestión Interna (Entrar)**                               | `docker exec -it mi_contenedor /bin/sh`            |
| **Configurar permanentemente el contenedor** | **¡Ninguno de los dos!** Usa el `Dockerfile` y vuelve a construir la imagen. | `docker build -t mi_nueva_imagen .`              |