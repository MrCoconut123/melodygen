import firebase_admin
from firebase_admin import credentials, storage

class StorageManager:
    def __init__(self):
        self.bucket_name = 'melody-gen-f7d60.appspot.com'
        self.fb_cred = 'serviceaccount.json'
        cred = credentials.Certificate(self.fb_cred)
        firebase_admin.initialize_app(cred, {
            'storageBucket': self.bucket_name
        })
    
    def upload_file(self, file_name, local_path):
        """
        Uploads a file to the cloud storage bucket.

        Args:
            file_name (str): The name of the file to be uploaded.
            local_path (str): The local path of the file to be uploaded.

        Returns:
            str: The public URL of the uploaded file.
        """
        # Get the storage bucket
        bucket = storage.bucket()

        # Create a new blob (file) in the bucket
        blob = bucket.blob(file_name)

        # Set the local file path
        outfile = local_path

        # Upload the file from the local path
        blob.upload_from_filename(outfile)

        # Open the file in binary mode and upload it to the bucket
        with open(outfile, 'rb') as fp:
            blob.upload_from_file(fp)

        # Print a confirmation message
        print('This file is uploaded to cloud.')

        # Make the file publicly accessible
        blob.make_public()

        # Return the public URL of the uploaded file
        return blob.public_url
    
