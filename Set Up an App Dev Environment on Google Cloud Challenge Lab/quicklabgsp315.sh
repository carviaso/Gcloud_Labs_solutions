
# Habilita el modo de depuración
set -x

# Verifica si la variable DEVSHELL_PROJECT_ID está vacía
if [ -z "$DEVSHELL_PROJECT_ID" ]; then
  echo "El nombre del DEVSHELL_PROJECT_ID no puede estar vacío."
  exit 1
fi

# Verifica si la variable TOPIC_NAME está vacía
if [ -z "$TOPIC_NAME" ]; then
  echo "El nombre del TOPIC_NAME no puede estar vacío."
  exit 1
fi

# Verifica si la variable PROJECT_NUMBER está vacía
if [ -z "$PROJECT_NUMBER" ]; then
  echo "El nombre del PROJECT_NUMBER no puede estar vacío."
  exit 1
fi

# Verifica si la variable REGION está vacía
if [ -z "$REGION" ]; then
  echo "El nombre del REGION no puede estar vacío."
  exit 1
fi

# Verifica si la variable FUNCTION_NAME está vacía
if [ -z "$FUNCTION_NAME" ]; then
  echo "El nombre del FUNCTION_NAME no puede estar vacío."
  exit 1
fi

# Verifica si la variable PROJECT_ID está vacía
if [ -z "$PROJECT_ID" ]; then
  echo "El nombre del PROJECT_ID no puede estar vacío."
  exit 1
fi

# Verifica si la variable BUCKET_SERVICE_ACCOUNT está vacía
if [ -z "$BUCKET_SERVICE_ACCOUNT" ]; then
  echo "El nombre del BUCKET_SERVICE_ACCOUNT no puede estar vacío."
  exit 1
fi

# Verifica si la variable BUCKET_NAME está vacía
if [ -z "$BUCKET_NAME" ]; then
  echo "El nombre del BUCKET_NAME no puede estar vacío."
  exit 1
fi

# Verifica si la variable USERNAME2 está vacía
if [ -z "$USERNAME2" ]; then
  echo "El nombre del USERNAME2 no puede estar vacío."
  exit 1
fi

# ----------------------------------------------------------------

export REGION="${ZONE%-*}"

gcloud services enable \
  artifactregistry.googleapis.com \
  cloudfunctions.googleapis.com \
  cloudbuild.googleapis.com \
  eventarc.googleapis.com \
  run.googleapis.com \
  logging.googleapis.com \
  pubsub.googleapis.com


sleep 70


PROJECT_NUMBER=$(gcloud projects describe $DEVSHELL_PROJECT_ID --format='value(projectNumber)')


gcloud projects add-iam-policy-binding $DEVSHELL_PROJECT_ID \
    --member=serviceAccount:$PROJECT_NUMBER-compute@developer.gserviceaccount.com \
    --role=roles/eventarc.eventReceiver


sleep 20

SERVICE_ACCOUNT="$(gsutil kms serviceaccount -p $DEVSHELL_PROJECT_ID)"

gcloud projects add-iam-policy-binding $DEVSHELL_PROJECT_ID \
    --member="serviceAccount:${SERVICE_ACCOUNT}" \
    --role='roles/pubsub.publisher'

sleep 20


gcloud projects add-iam-policy-binding $DEVSHELL_PROJECT_ID \
    --member=serviceAccount:service-$PROJECT_NUMBER@gcp-sa-pubsub.iam.gserviceaccount.com \
    --role=roles/iam.serviceAccountTokenCreator

sleep 20


gsutil mb -l $REGION gs://$DEVSHELL_PROJECT_ID-bucket

gcloud pubsub topics create $TOPIC_NAME

mkdir quicklab
cd quicklab

cat > index.js <<'EOF_END'
const functions = require('@google-cloud/functions-framework');
const crc32 = require("fast-crc32c");
const { Storage } = require('@google-cloud/storage');
const gcs = new Storage();
const { PubSub } = require('@google-cloud/pubsub');
const imagemagick = require("imagemagick-stream");

functions.cloudEvent('$FUNCTION_NAME', cloudEvent => {
  const event = cloudEvent.data;

  console.log(`Event: ${event}`);
  console.log(`Hello ${event.bucket}`);

  const fileName = event.name;
  const bucketName = event.bucket;
  const size = "64x64"
  const bucket = gcs.bucket(bucketName);
  const topicName = "$TOPIC_NAME";
  const pubsub = new PubSub();
  if ( fileName.search("64x64_thumbnail") == -1 ){
    // doesn't have a thumbnail, get the filename extension
    var filename_split = fileName.split('.');
    var filename_ext = filename_split[filename_split.length - 1];
    var filename_without_ext = fileName.substring(0, fileName.length - filename_ext.length );
    if (filename_ext.toLowerCase() == 'png' || filename_ext.toLowerCase() == 'jpg'){
      // only support png and jpg at this point
      console.log(`Processing Original: gs://${bucketName}/${fileName}`);
      const gcsObject = bucket.file(fileName);
      let newFilename = filename_without_ext + size + '_thumbnail.' + filename_ext;
      let gcsNewObject = bucket.file(newFilename);
      let srcStream = gcsObject.createReadStream();
      let dstStream = gcsNewObject.createWriteStream();
      let resize = imagemagick().resize(size).quality(90);
      srcStream.pipe(resize).pipe(dstStream);
      return new Promise((resolve, reject) => {
        dstStream
          .on("error", (err) => {
            console.log(`Error: ${err}`);
            reject(err);
          })
          .on("finish", () => {
            console.log(`Success: ${fileName} → ${newFilename}`);
              // set the content-type
              gcsNewObject.setMetadata(
              {
                contentType: 'image/'+ filename_ext.toLowerCase()
              }, function(err, apiResponse) {});
              pubsub
                .topic(topicName)
                .publisher()
                .publish(Buffer.from(newFilename))
                .then(messageId => {
                  console.log(`Message ${messageId} published.`);
                })
                .catch(err => {
                  console.error('ERROR:', err);
                });
          });
      });
    }
    else {
      console.log(`gs://${bucketName}/${fileName} is not an image I can handle`);
    }
  }
  else {
    console.log(`gs://${bucketName}/${fileName} already has a thumbnail`);
  }
});
EOF_END

sed -i "8c\functions.cloudEvent('$FUNCTION_NAME', cloudEvent => { " index.js

sed -i "18c\  const topicName = '$TOPIC_NAME';" index.js

cat > package.json <<EOF_END
{
    "name": "thumbnails",
    "version": "1.0.0",
    "description": "Create Thumbnail of uploaded image",
    "scripts": {
      "start": "node index.js"
    },
    "dependencies": {
      "@google-cloud/functions-framework": "^3.0.0",
      "@google-cloud/pubsub": "^2.0.0",
      "@google-cloud/storage": "^5.0.0",
      "fast-crc32c": "1.0.4",
      "imagemagick-stream": "4.1.1"
    },
    "devDependencies": {},
    "engines": {
      "node": ">=4.3.2"
    }
  }
EOF_END



PROJECT_ID=$(gcloud config get-value project)
BUCKET_SERVICE_ACCOUNT="${PROJECT_ID}@${PROJECT_ID}.iam.gserviceaccount.com"

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member=serviceAccount:$BUCKET_SERVICE_ACCOUNT \
  --role=roles/pubsub.publisher




# Your existing deployment command
deploy_function() {
    gcloud functions deploy $FUNCTION_NAME \
    --gen2 \
    --runtime nodejs20 \
    --trigger-resource $DEVSHELL_PROJECT_ID-bucket \
    --trigger-event google.storage.object.finalize \
    --entry-point $FUNCTION_NAME \
    --region=$REGION \
    --source . \
    --quiet
}

# Variables
SERVICE_NAME="$FUNCTION_NAME"

# Loop until the Cloud Run service is created
while true; do
  # Run the deployment command
  deploy_function

  # Check if Cloud Run service is created
  if gcloud run services describe $SERVICE_NAME --region $REGION &> /dev/null; then
    echo "Cloud Run service is created. Exiting the loop."
    break
  else
    echo "Waiting for Cloud Run service to be created..."
    echo "Meantime Subscribe to Quicklab[https://www.youtube.com/@quick_lab]."
    sleep 10
  fi
done




curl -o map.jpg https://storage.googleapis.com/cloud-training/gsp315/map.jpg

gsutil cp map.jpg gs://$DEVSHELL_PROJECT_ID-bucket/map.jpg

gcloud projects remove-iam-policy-binding $DEVSHELL_PROJECT_ID \
--member=user:$USERNAME2 \
--role=roles/viewer

# Desactiva el modo de depuración si no es necesario para el resto del script
set +x
