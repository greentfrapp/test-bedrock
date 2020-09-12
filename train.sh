apt-get update
apt-get -y install git

git clone https://github.com/AlexeyAB/darknet.git

sed -i '1s/.*/GPU=1/' darknet/Makefile
sed -i '2s/.*/CUDNN=1/' darknet/Makefile
sed -i '7s/.*/LIBSO=1/' darknet/Makefile
sed -i '35s/.*/ARCH= -gencode arch=compute_75,code=[sm_75,compute_75]/' darknet/Makefile
cd darknet && make

sed -i '20s/.*/max_batches=10/' cfg/yolov4-tiny-custom.cfg
sed -i '22s/.*/steps=8,9/' cfg/yolov4-tiny-custom.cfg
sed -i '212s/.*/filters=27/' cfg/yolov4-tiny-custom.cfg
sed -i '220s/.*/classes=4/' cfg/yolov4-tiny-custom.cfg
sed -i '263s/.*/filters=27/' cfg/yolov4-tiny-custom.cfg
sed -i '269s/.*/classes=4/' cfg/yolov4-tiny-custom.cfg

apt-get -y install wget
wget https://github.com/AlexeyAB/darknet/releases/download/darknet_yolo_v4_pre/yolov4-tiny.conv.29

# Disable the following if using aws-production environment
wget --load-cookies /tmp/cookies.txt "https://docs.google.com/uc?export=download&confirm=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate 'https://docs.google.com/uc?export=download&id=1dfD1k77WL_xFmYXUOZOAqTnRUrtF2FaR' -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')&id=1dfD1k77WL_xFmYXUOZOAqTnRUrtF2FaR" -O yolo_data.zip && rm -rf /tmp/cookies.txt
apt-get -y install unzip
unzip yolo_data.zip

# Enable the following if using aws-production environment
# pip install --upgrade pip
# pip install -r requirements.txt
# python download_data.py

./darknet detector train yolo_data/obj.data cfg/yolov4-tiny-custom.cfg yolov4-tiny.conv.29
