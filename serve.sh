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

apt-get -y install wget
wget https://github.com/AlexeyAB/darknet/releases/download/darknet_yolo_v4_pre/yolov4-tiny.conv.29

# Disable the following if using aws-production environment
wget --load-cookies /tmp/cookies.txt "https://docs.google.com/uc?export=download&confirm=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate "https://docs.google.com/uc?export=download&id=$GOOGLE_FILE_ID" -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')&id=$GOOGLE_FILE_ID" -O yolo_data.zip && rm -rf /tmp/cookies.txt
apt-get -y install unzip
unzip yolo_data.zip

apt-get -y install python3-pip
# pip3 install -r requirements-serve.txt
pip3 install bdrk[model-monitoring]==0.4.0
pip3 install flask==1.1.2
pip3 install gunicorn==20.0.4
pip3 install opencv-python==4.4.0.40
pip3 install Pillow==7.2.0

gunicorn --config gunicorn_config.py --bind=:${BEDROCK_SERVER_PORT:-8080} --worker-class=gthread --workers=${WORKERS} --timeout=300 --preload serve_http:app
