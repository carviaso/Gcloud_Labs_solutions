#!/bin/bash

# Variables
Name_bucket="nombre-del-bucket"
Project_ID="tu-id-de-proyecto"
Region="us-central1"  # Puedes cambiar la región según sea necesario

# Función para verificar el estado de la ejecución de una tarea
check_status() {
    if [ $? -eq 0 ]; then
        echo "✅ Tarea completada exitosamente."
    else
        echo "❌ Error: La tarea ha fallado. Saliendo del script."
        exit 1
    fi
}

# Tarea 1: Crear un bucket $Name_bucket en $Project_ID
echo "Creando el bucket $Name_bucket en el proyecto $Project_ID..."
gcloud config set project $Project_ID
gsutil mb -p $Project_ID -c regional -l $Region gs://$Name_bucket/
echo "Bucket $Name_bucket creado correctamente."

# Tarea 2: Subir un objeto kitten.png al bucket
echo "Subiendo el objeto kitten.png al bucket $Name_bucket..."
gsutil cp kitten.png gs://$Name_bucket/
echo "Objeto kitten.png subido correctamente."

# Tarea 3: Compartir el bucket públicamente
echo "Compartiendo el bucket $Name_bucket públicamente..."
gsutil iam ch allUsers:objectViewer gs://$Name_bucket
echo "Bucket $Name_bucket compartido públicamente."

# Tarea 4: Crear las carpetas folder1 y folder2
echo "Creando las carpetas folder1 y folder2 en el bucket $Name_bucket..."
gsutil mkdir gs://$Name_bucket/folder1
gsutil mkdir gs://$Name_bucket/folder2
echo "Carpetas folder1 y folder2 creadas correctamente."

# Tarea 5: Eliminar las carpetas folder1 y folder2
echo "Eliminando las carpetas folder1 y folder2 del bucket $Name_bucket..."
gsutil -m rm -r gs://$Name_bucket/folder1
gsutil -m rm -r gs://$Name_bucket/folder2
echo "Carpetas folder1 y folder2 eliminadas correctamente."

echo "Tareas completadas."
