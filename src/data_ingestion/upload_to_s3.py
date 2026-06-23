import os
import boto3
from botocore.exceptions import NoCredentialsError

# Dynamically calculates the exact absolute directory path of this file
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
LOCAL_DATA_DIR = os.path.join(SCRIPT_DIR, 'raw_data')

# !!! CHANGE THIS TO YOUR EXACT AWS BUCKET NAME !!!
BUCKET_NAME = 'amaz-s3-zomato-raw-data-landing'  
LOCAL_DATA_DIR = 'raw_data/'

# Initialize the S3 Client
s3 = boto3.client('s3')

def upload_json_files():
    """Sweeps through raw_data, grabs json files, and pushes them to S3."""
    if not os.path.exists(LOCAL_DATA_DIR):
        print(f"❌ Error: {LOCAL_DATA_DIR} directory not found.")
        return

    # Filter out only the JSON files to process
    json_files = [f for f in os.listdir(LOCAL_DATA_DIR) if f.endswith('.json')]
    
    if not json_files:
        print("⚠️ No JSON files discovered to upload.")
        return

    print(f"📂 Found {len(json_files)} JSON files. Starting S3 stream...")

    for file_name in json_files:
        local_path = os.path.join(LOCAL_DATA_DIR, file_name)
        # Group them inside a dedicated directory in your bucket
        s3_key = f"raw_landing/zomato_historical/{file_name}"
        
        try:
            print(f"📤 Uploading {file_name} -> s3://{BUCKET_NAME}/{s3_key}...")
            s3.upload_file(local_path, BUCKET_NAME, s3_key)
            print(f"🚀 Success: {file_name} is live in Oregon!")
        except NoCredentialsError:
            print("❌ AWS Credentials missing. Please run 'aws configure' in terminal.")
            return
        except Exception as e:
            print(f"❌ Upload failed for {file_name}: {str(e)}")

if __name__ == "__main__":
    upload_json_files()
