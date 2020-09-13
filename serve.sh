apt-get update
apt-get -y install git

git clone https://github.com/AlexeyAB/darknet.git

sed -i '1s/.*/GPU=1/' darknet/Makefile
sed -i '2s/.*/CUDNN=1/' darknet/Makefile
sed -i '7s/.*/LIBSO=1/' darknet/Makefile
sed -i '35s/.*/ARCH= -gencode arch=compute_75,code=[sm_75,compute_75]/' darknet/Makefile
cd darknet && make

sed -i "212s/.*/filters=$((($NUM_CLASSES + 5) * 3))/" cfg/yolov4-tiny-custom.cfg
sed -i "220s/.*/classes=$NUM_CLASSES/" cfg/yolov4-tiny-custom.cfg
sed -i "263s/.*/filters=$((($NUM_CLASSES + 5) * 3))/" cfg/yolov4-tiny-custom.cfg
sed -i "269s/.*/classes=$NUM_CLASSES/" cfg/yolov4-tiny-custom.cfg

sed -i "223s/.*/    print(os.environ.get('DARKNET_PATH', './'))\n    lib = CDLL(os.path.join(" darknet.py

apt-get -y install wget
wget https://github.com/AlexeyAB/darknet/releases/download/darknet_yolo_v4_pre/yolov4-tiny.conv.29

# Disable the following if using aws-production environment
wget --load-cookies /tmp/cookies.txt "https://docs.google.com/uc?export=download&confirm=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate "https://docs.google.com/uc?export=download&id=$GOOGLE_FILE_ID" -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')&id=$GOOGLE_FILE_ID" -O yolo_data.zip && rm -rf /tmp/cookies.txt
apt-get -y install unzip
unzip yolo_data.zip

apt-get -y install libgl1-mesa-glx
apt-get -y install nvidia-driver-390

cd ..

apt-get -y install python3-pip
pip3 install --upgrade pip
pip3 install -r requirements-serve.txt
pip3 install dataclasses

cp ./darknet/libdarknet.so ./libdarknet.so

export PATH="$PATH:/usr/local/cuda-10.1/bin"
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/local/cuda-10.1/lib64:/usr/local/cuda/lib64"

echo $PATH
echo $LD_LIBRARY_PATH
ls /usr/local/cuda/lib64

gunicorn --config gunicorn_config.py --bind=:${BEDROCK_SERVER_PORT:-8080} --worker-class=gthread --workers=${WORKERS} --timeout=300 --preload serve_http:app
