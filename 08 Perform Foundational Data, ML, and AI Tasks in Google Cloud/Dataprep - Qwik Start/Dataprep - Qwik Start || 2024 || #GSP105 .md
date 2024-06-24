# Dataprep: Qwik Start || 2024 || #GSP105
[Dataprep: Qwik Start || 2024 || GSP105](https://youtu.be/j5qv9GFlKxU?si=ZAX9h3_sRbY78p0H)

Commands:-
```bash
# =============================================================

gsutil mb gs://$DEVSHELL_PROJECT_ID

gcloud beta services identity create --service=dataprep.googleapis.com
# =============================================================
```


## Task 1. Create a Cloud Storage bucket in your project
```
gsutil mb gs://$DEVSHELL_PROJECT_ID
```
Para crear un bucket de Google Cloud Storage utilizando gsutil y asegurarte de que el comando se ejecute correctamente, puedes seguir estos pasos y usar el siguiente script:
### Paso a Paso

1.    Configura el entorno: Asegúrate de que tienes el entorno configurado con el proyecto correcto.
2.    Crea el bucket: Utiliza el comando gsutil mb para crear el bucket.

### Script de Shell

Aquí tienes un script en bash que incluye la creación del bucket y la validación de la ejecución:
```bash
#!/bin/bash

# Variables
PROJECT_ID=$(gcloud config get-value project)
BUCKET_NAME="gs://$PROJECT_ID"

# Función para verificar el estado de la ejecución de una tarea
check_status() {
    if [ $? -eq 0 ]; then
        echo "✅ Tarea completada exitosamente."
    else
        echo "❌ Error: La tarea ha fallado. Saliendo del script."
        exit 1
    fi
}

# Crear el bucket
echo "Creando el bucket $BUCKET_NAME..."
gsutil mb $BUCKET_NAME
check_status

echo "✨ Bucket $BUCKET_NAME creado exitosamente."
```
### Explicación del Script

1.    Variables:
-        PROJECT_ID: Obtiene el ID del proyecto actual configurado en gcloud.
-        BUCKET_NAME: Define el nombre del bucket utilizando el ID del proyecto. Esto asegura que el nombre del bucket es único a nivel global.

2.    Función check_status: Verifica si el comando anterior se ejecutó correctamente y termina el script con un mensaje de error si falla.

3.    Crear el Bucket:
-        Utiliza gsutil mb $BUCKET_NAME para crear el bucket.
-        Llama a check_status para validar la ejecución del comando y proporcionar retroalimentación.

4.    Mensajes de Confirmación: Muestra mensajes de confirmación después de completar cada tarea exitosamente.

### Uso del Script

1.    Guarda el script en un archivo, por ejemplo create_bucket.sh.
2.    Dale permisos de ejecución al script:

```bash
chmod +x create_bucket.sh
```

3.  Ejecuta el script:
```bash

    ./create_bucket.sh
```

### Notas Adicionales

-    Permisos Necesarios: Asegúrate de tener los permisos necesarios para crear buckets en el proyecto de Google Cloud.
-    Unicidad del Nombre del Bucket: Los nombres de los buckets deben ser únicos a nivel global. Este script usa el ID del proyecto para asegurar la unicidad.

Este script automatiza la creación de un bucket en Google Cloud Storage y valida que el comando se ejecute correctamente, proporcionando una forma fácil y confiable de realizar esta tarea.

-------------------

## Task 2. Initialize Cloud Dataprep

El comando que has proporcionado se utiliza para crear una identidad de servicio para el servicio Dataprep en Google Cloud. Aquí está el comando completo con una pequeña explicación:
```bash
gcloud beta services identity create --service=dataprep.googleapis.com
```

Explicación del Comando:

-    gcloud beta: Indica que estamos usando la versión beta del comando gcloud.
-    services identity create: Este comando crea una identidad de servicio para un servicio específico.
-    --service=dataprep.googleapis.com: Especifica el servicio para el cual se creará la identidad de servicio, en este caso, dataprep.googleapis.com.

Script de Shell Completo

Si deseas incluir este comando en un script de shell más grande que realiza varias configuraciones, puedes integrarlo como sigue:

```bash

#!/bin/bash

# Variables
PROJECT_ID=$(gcloud config get-value project)
SERVICE_NAME="dataprep.googleapis.com"

# Función para verificar el estado de la ejecución de una tarea
check_status() {
    if [ $? -eq 0 ]; then
        echo "✅ Tarea completada exitosamente."
    else
        echo "❌ Error: La tarea ha fallado. Saliendo del script."
        exit 1
    fi
}

# Crear una identidad de servicio para Dataprep
echo "Creando identidad de servicio para $SERVICE_NAME..."
gcloud beta services identity create --service=$SERVICE_NAME
check_status

echo "✨ Identidad de servicio creada exitosamente para $SERVICE_NAME en el proyecto $PROJECT_ID."

```

## Notas Adicionales

1.    Permisos Necesarios: Asegúrate de tener los permisos necesarios para crear identidades de servicio en tu proyecto de Google Cloud. Generalmente, necesitarás permisos de administrador de servicios (roles/serviceusage.serviceUsageAdmin).
2.    Proyecto Correcto: Asegúrate de que el proyecto de Google Cloud correcto esté configurado antes de ejecutar este script. Puedes establecer el proyecto utilizando: **gcloud config set project _PROJECT_ID_**.
3.    Identidad de Servicio: La identidad de servicio creada se puede usar para otorgar permisos específicos al servicio dataprep.googleapis.com, facilitando su integración con otros recursos de Google Cloud.

Este script automatiza la creación de una identidad de servicio para Dataprep, incluyendo validaciones para garantizar que el comando se ejecute correctamente.
