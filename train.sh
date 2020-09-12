git clone https://github.com/AlexeyAB/darknet.git

sed -i '1s/.*/GPU=1/' darknet/Makefile
sed -i '2s/.*/CUDNN=1/' darknet/Makefile
sed -i '7s/.*/LIBSO=1/' darknet/Makefile
sed -i '35s/.*/ARCH= -gencode arch=compute_75,code=[sm_75,compute_75]/' darknet/Makefile
cd darknet && make

./darknet