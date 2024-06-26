# Dataflow: Qwik Start - Templates

gcloud services disable dataflow.googleapis.com
gcloud services enable dataflow.googleapis.com
bq mk taxirides
bq mk \
--time_partitioning_field timestamp \
--schema ride_id:string,point_idx:integer,latitude:float,longitude:float,\
timestamp:timestamp,meter_reading:float,meter_increment:float,ride_status:string,\
passenger_count:integer -t taxirides.realtime


export BUCKET_NAME=$(gcloud config get-value project)
gsutil mb gs://$BUCKET_NAME/
