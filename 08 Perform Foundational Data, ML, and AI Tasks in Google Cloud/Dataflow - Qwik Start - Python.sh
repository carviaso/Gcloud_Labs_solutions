# Dataflow: Qwik Start - Python

export PROJECT_ID=



export BUCKET_NAME=$PROJECT_ID


gcloud auth list

gcloud config list project

gcloud config set compute/region us-central1

gcloud services disable dataflow.googleapis.com

gcloud services enable dataflow.googleapis.com

gcloud storage buckets create gs://$BUCKET_NAME --project=$PROJECT_ID --location=us

docker run -it -e DEVSHELL_PROJECT_ID=$DEVSHELL_PROJECT_ID python:3.9 /bin/bash


# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



pip install 'apache-beam[gcp]'==2.42.0

python -m apache_beam.examples.wordcount --output OUTPUT_FILE

cat $(ls)


# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

BUCKET=gs://<bucket name provided earlier>

python -m apache_beam.examples.wordcount --project $DEVSHELL_PROJECT_ID \
  --runner DataflowRunner \
  --staging_location $BUCKET/staging \
  --temp_location $BUCKET/temp \
  --output $BUCKET/results/output \
  --region us-central1
