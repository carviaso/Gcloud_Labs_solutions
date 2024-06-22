# Replace placeholders with your project ID and desired bucket name
PROJECT_ID="your-project-id"
BUCKET_NAME="your-bucket-name"
REGION="us-central1"  # Replace with your desired region

if [ -z "$DEVSHELL_PROJECT_ID" ]; then
  echo "El nombre del DEVSHELL_PROJECT_ID no puede estar vacío."
  exit 1
fi

gcloud config set compute/region $REGION

# Create the bucket
gsutil mb gs://$DEVSHELL_PROJECT_ID

# 2. Upload Objects to the Bucket
Echo "2. Upload Objects to the Bucket"
curl https://upload.wikimedia.org/wikipedia/commons/thumb/a/a4/Ada_Lovelace_portrait.jpg/800px-Ada_Lovelace_portrait.jpg --output ada.jpg
mv ada.jpg kitten.png

# Upload a single object
gsutil cp kitten.png gs://$DEVSHELL_PROJECT_ID

# Upload multiple objects
gsutil cp -r gs://$DEVSHELL_PROJECT_ID/kitten.png .

# 3. Create Folders and Subfolders in the Bucket
# Upload files to create folders/subfolders
gsutil cp gs://$DEVSHELL_PROJECT_ID/kitten.png gs://$DEVSHELL_PROJECT_ID/image-folder/

# 4. Make Objects Publicly Accessible
gsutil iam ch allUsers:objectViewer gs://$DEVSHELL_PROJECT_ID
