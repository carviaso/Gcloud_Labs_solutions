#!/bin/bash
# Setup and requirements

# Variables
INSTANCE_NAME="lamp-1-vm"
REGION="us-central1"
ZONE="us-central1-c"
MACHINE_TYPE="e2-medium"
IMAGE_FAMILY="debian-12"
IMAGE_PROJECT="debian-cloud"

# Variables
PROJECT_ID=$(gcloud config get-value project)
ALERT_POLICY_NAME="High CPU Usage Alert"
NOTIFICATION_CHANNEL_NAME="Email Notification"
NOTIFICATION_EMAIL="tu-email@example.com"
DASHBOARD_NAME="Cloud Monitoring LAMP Qwik Start Dashboard"
WIDGET_TITLE="CPU Load"
WIDGET_TYPE="CPU load (1m)"
DEVSHELL_PROJECT_ID=$(gcloud config get-value project)

if [ -z "$DEVSHELL_PROJECT_ID" ]; then
  echo "El nombre del DEVSHELL_PROJECT_ID no puede estar vacío."
  exit 1
fi
# ===========================================
# Task 1. Create a Compute Engine instance
# ===========================================
echo "Task 1. Create a Compute Engine instance"

# Configuración de la zona y región
echo "Configurando la región: $REGION y zona: $ZONE ..."
gcloud config set compute/region $REGION
gcloud config set compute/zone $ZONE

# Task 1. Create a Compute Engine instance
echo "=== Task 1. Create a Compute Engine instance ==="
# Create the instance with the necessary metadata and tags
echo "Creando la instancia de Compute Engine $INSTANCE_NAME..."
gcloud compute instances create $INSTANCE_NAME \
    --zone=$ZONE \
    --machine-type=$MACHINE_TYPE \
    --image-family=$IMAGE_FAMILY \
    --image-project=$IMAGE_PROJECT \
    --tags=http-server

#gcloud compute instances create lamp-1-vm \
#    --project=$DEVSHELL_PROJECT_ID \
#    --zone=$ZONE \
#    --machine-type=e2-small \
#    --network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=default \
#    --metadata=enable-oslogin=true \
#    --maintenance-policy=MIGRATE \
#    --provisioning-model=STANDARD \
#    --tags=http-server \
#    --create-disk=auto-delete=yes,boot=yes,device-name=lamp-1-vm,image=projects/debian-cloud/global/images/debian-10-buster-v20230629,mode=rw,size=10,type=projects/$DEVSHELL_PROJECT_ID/zones/$ZONE/diskTypes/pd-balanced \
#    --no-shielded-secure-boot \
#    --shielded-vtpm \
#    --shielded-integrity-monitoring \
#    --labels=goog-ec-src=vm_add-gcloud \
#    --reservation-affinity=any

# Verificar si la instancia se creó correctamente
if [ $? -eq 0 ]; then
    echo "✅ La instancia $INSTANCE_NAME se ha creado exitosamente."
else
    echo "❌ Error: No se pudo crear la instancia $INSTANCE_NAME. Saliendo del script."
    exit 1
fi

# Create firewall rule to allow incoming HTTP traffic on port 80
# Configurar las reglas de firewall para permitir el tráfico HTTP
echo "Configurando reglas de firewall para permitir tráfico HTTP..."
gcloud compute firewall-rules create allow-http \
    --description="Allow HTTP traffic" \
    --project=$DEVSHELL_PROJECT_ID \
    --direction=INGRESS \
    --priority=1000 \
    --network=default \
    --action=ALLOW \
    --rules=tcp:80 \
    --source-ranges=0.0.0.0/0 \
    --target-tags=http-server

echo "✨ Todas las tareas han sido completadas exitosamente."

# Task 2. Add Apache2 HTTP Server to your instance
echo "=== Task 2. Add Apache2 HTTP Server to your instance ==="
# Generate SSH keys
#gcloud compute config-ssh --project "$DEVSHELL_PROJECT_ID" --quiet

# SSH into the instance and run commands
gcloud compute ssh $INSTANCE_NAME --project "$DEVSHELL_PROJECT_ID" --zone $ZONE --command "sudo apt-get update && sudo apt-get install -y apache2 php7.0 && sudo service apache2 restart"

echo "✨ Todas las tareas han sido completadas exitosamente."

# Create a Monitoring Metrics Scope
echo "Creando un Monitoring Metrics Scope para el proyecto $PROJECT_ID..."
gcloud services enable monitoring.googleapis.com

# Configurar el agente de monitoreo en la instancia
echo "Instalando el agente de monitoreo en la instancia $INSTANCE_NAME..."
gcloud compute ssh $INSTANCE_NAME --zone $ZONE --command 'curl -sSO https://dl.google.com/cloudagents/add-monitoring-agent-repo.sh && sudo bash add-monitoring-agent-repo.sh && sudo apt-get update && sudo apt-get install -y stackdriver-agent && sudo service stackdriver-agent start'

# Verificar si el agente de monitoreo se instaló correctamente
if [ $? -eq 0 ]; then
    echo "✅ Agente de monitoreo instalado y configurado exitosamente en la instancia $INSTANCE_NAME."
else
    echo "❌ Error: No se pudo instalar el agente de monitoreo en la instancia $INSTANCE_NAME. Saliendo del script."
    exit 1
fi

echo "✨ Todas las tareas han sido completadas exitosamente."

# Función para verificar el estado de la ejecución de una tarea
check_status() {
    if [ $? -eq 0 ]; then
        echo "✅ Tarea completada exitosamente."
    else
        echo "❌ Error: La tarea ha fallado. Saliendo del script."
        exit 1
    fi
}

# Install the Monitoring and Logging agents
echo "Install the Monitoring and Logging agents"
# Habilitar el servicio de monitoreo
echo "Habilitando el servicio de monitoreo..."
gcloud services enable monitoring.googleapis.com
check_status

# =======================================================
# Habilitar el servicio de registro
echo "Habilitando el servicio de registro..."
gcloud services enable logging.googleapis.com
check_status

# Instalar los agentes de monitoreo y registro en la instancia
echo "Instalando los agentes de monitoreo y registro en la instancia $INSTANCE_NAME..."
gcloud compute ssh $INSTANCE_NAME --zone $ZONE --command '
curl -sSO https://dl.google.com/cloudagents/add-monitoring-agent-repo.sh && \
sudo bash add-monitoring-agent-repo.sh && \
sudo apt-get update && sudo apt-get install -y stackdriver-agent && \
curl -sSO https://dl.google.com/cloudagents/add-logging-agent-repo.sh && sudo bash add-logging-agent-repo.sh &&\
sudo apt-get update && sudo apt-get install -y google-fluentd && sudo service google-fluentd start'
check_status

# Task 3. Create an uptime check
echo "Task 3. Create an uptime check"

# Crear una verificación de tiempo de actividad (uptime check)
echo "Creando una verificación de tiempo de actividad para la instancia $INSTANCE_NAME..."
INSTANCE_IP=$(gcloud compute instances describe $INSTANCE_NAME --zone $ZONE --format='get(networkInterfaces[0].accessConfigs[0].natIP)')
gcloud monitoring uptime-checks create http $INSTANCE_NAME-uptime-check \
    --host=$INSTANCE_IP \
    --path="/" \
    --display-name="Lamp Uptime Check" \
    --http-check=port=80 \
    --timeout=10s \
    --check-interval=1m
check_status

echo "✨ Todas las tareas han sido completadas exitosamente."


# ========================================================
cat > alert_config.json <<EOF
{
  "displayName": "Inbound Traffic Alert",
  "userLabels": {},
  "conditions": [
    {
      "displayName": "VM Instance - Network traffic",
      "conditionThreshold": {
        "filter": "resource.type = \"gce_instance\" AND metric.type = \"agent.googleapis.com/interface/traffic\"",
        "aggregations": [
          {
            "alignmentPeriod": "300s",
            "crossSeriesReducer": "REDUCE_NONE",
            "perSeriesAligner": "ALIGN_RATE"
          }
        ],
        "comparison": "COMPARISON_GT",
        "duration": "60s",
        "trigger": {
          "count": 1
        },
        "thresholdValue": 500
      }
    }
  ],
  "alertStrategy": {
    "autoClose": "604800s"
  },
  "combiner": "OR",
  "enabled": true
}
EOF

gcloud alpha monitoring policies create --policy-from-file=alert_config.json
