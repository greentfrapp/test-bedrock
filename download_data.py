import boto3
from pathlib import Path
from tqdm import tqdm

def get_data():
    # Download data from S3
    local_data_folder = Path("darknet/yolo_data")
    local_data_folder.mkdir(parents=True, exist_ok=True)
    s3 = boto3.resource("s3")
    s3_client = boto3.client("s3")
    bucket_name = "broker-reports"
    my_bucket = s3.Bucket(bucket_name)
    for obj in tqdm(my_bucket.objects.all()):
        # There should be about 2000++ files
        if (local_data_folder / obj.key).suffix in [".png", ".txt"]:
            fp = obj.key.replace("labels-yolo/", "")
            (local_data_folder / fp).parent.mkdir(parents=True, exist_ok=True)
            s3_client.download_file(bucket_name, obj.key, str(local_data_folder / fp))
    # Update paths to input files
    for datalist in ["train.txt", "valid.txt", "test.txt"]:
        filenames = []
        with open(local_data_folder / datalist, 'r') as file:
            for line in file:
                path = local_data_folder / "data" / Path(line.strip()).name
                if path.exists(): filenames.append(str(path))
        with open(local_data_folder / datalist, 'w') as file:
            for path in filenames: file.write(path + '\n')


if __name__ == "__main__":
    get_data()
