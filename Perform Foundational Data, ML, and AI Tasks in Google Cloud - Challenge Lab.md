# Perform Foundational Data, ML, and AI Tasks in Google Cloud: Challenge Lab
 
## Task 1:
 
```
bq mk DATASET_NAME

gsutil mb gs://BUCKET_NAME


gsutil cp gs://cloud-training/gsp323/lab.csv  .
  
gsutil cp gs://cloud-training/gsp323/lab.schema .
 
cat lab.schema
```


 
## Task 2:
 Need to perform manually
 
##Task 3:
  Need to perform manually


 
## Task 4:
 
Cloud Natural Language:
 
In cloud shell
``` 
export GOOGLE_CLOUD_PROJECT=$(gcloud config get-value core/project)
 
gcloud iam service-accounts create my-natlang-sa \
--display-name "my natural language service account"
 
gcloud iam service-accounts keys create ~/key.json \
--iam-account my-natlang-sa@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com
 
export GOOGLE_APPLICATION_CREDENTIALS="/home/USER/key.json"
 
gcloud ml language analyze-entities --content="Old Norse texts portray Odin as one-eyed and long-bearded, frequently wielding a spear named Gungnir and wearing a cloak and a broad hat." > result.json
 
gsutil cp result.json <Copy the url for the Cloud Natural Language API given in the lab>
```


