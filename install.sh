# tested on Ubuntu 20.04 / jetpack 5.1

set -x
set -e

sudo apt-get install -y build-essential
sudo apt install -y bzip2 fontconfig libfribidi{0,-dev} gmpc{,-dev} gnutls-bin lame libass{9,-dev} libavc1394-{0,dev} libbluray{2,-dev} libdrm{2,-dev} libfreetype6{,-dev} libmodplug{1,-dev} libraw1394-{11,dev} librsvg2{-2,-dev} libsoxr{0,-dev} libtheora{0,-dev} libva{2,-dev} libva-drm2 libva-x11-2 libvdpau{1,-dev} libvorbisenc2 libvorbis{0a,-dev} libvpx{6,-dev} libwebp{6,-dev} libx11{-6,-dev} libx264-{155,dev} libx265-{179,dev} libxcb1{,-dev} libxext{6,-dev} libxml2{,-dev} libxv{1,-dev} libxvidcore{4,-dev} libopencore-amr{nb0,nb-dev,wb0,wb-dev} opus-tools libsdl2-dev speex v4l-utils zlib1g{,-dev} libopenjp2-7{,-dev} libssh-{4,dev} libspeex{1,-dev}

rm -rf ~/temp_build_ffmpeg/
mkdir ~/temp_build_ffmpeg/
cd ~/temp_build_ffmpeg/

git clone https://github.com/fingul/jetson-ffmpeg.git
cd jetson-ffmpeg
sed -i '/find_library(LIB_NVBUF nvbuf_utils PATHS \/usr\/lib\/aarch64-linux-gnu\/tegra)/s/^/#/' CMakeLists.txt
mkdir build
cd build
cmake ..
make -j 8
sudo make install
sudo ldconfig

git clone git://source.ffmpeg.org/ffmpeg.git -b release/6.0 --depth=1
cd ffmpeg
wget -O ffmpeg_nvmpi.patch https://github.com/Keylost/jetson-ffmpeg/raw/master/ffmpeg_patches/ffmpeg6.0_nvmpi.patch
git apply ffmpeg_nvmpi.patch
./configure --enable-nvmpi --enable-libfreetype --enable-libfontconfig  
make -j 8
sudo make install
ffmpeg -codecs|grep h264


ffmpeg -codecs|grep h264

# test - drawtext, h264_nvmpi, avsynctest
ffmpeg -y -t 5 -f lavfi -i 'avsynctest=size=1920x1080:framerate=60:samplerate=48000[out0][out1]' -vf "drawtext=fontsize=20:fontcolor=yellow:text='%{localtime\:%Y-%m-%d_%H-%M-%S}.%{eif\:1000*mod(t\,1)\:d\:3}':x=(w-text_w)/2:y=(h-text_h)/3"  -g 15 -r 60 -c:v h264_nvmpi -b:v 10000k -c:a aac -b:a 128k -ar 48000 -pix_fmt yuv420p ~/5.mp4
