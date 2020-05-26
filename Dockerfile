# Ubuntu version
FROM ubuntu:focal

# This is used to stop APT from throwing errors and warning when trying to install software without a term.
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update -qq
RUN apt-get upgrade -qq
RUN apt-get install --no-install-recommends -y software-properties-common build-essential git

# Install dependencies for hardware debugging
RUN apt-get install --no-install-recommends -y \
libhidapi-hidraw0 \
libusb-0.1-4 \
libusb-1.0-0 \
libhidapi-dev \
libusb-1.0-0-dev \
libusb-dev \
libftdi-dev \
libncurses5 \
texinfo

# Install General compilation tools
RUN apt-get install --no-install-recommends -y \
wget \
make \
cmake \
automake \
pkg-config \
libtool \
autoconf

# Download and install the ARM maintained GCC compiler and tools.
WORKDIR /home
RUN wget -O gcc_arm.tar.bz2 https://developer.arm.com/-/media/Files/downloads/gnu-rm/9-2019q4/gcc-arm-none-eabi-9-2019-q4-major-x86_64-linux.tar.bz2 \
&& tar xjf gcc_arm.tar.bz2 -C /opt \
&& chmod -R -w /opt/gcc-arm-none-eabi-9-2019-q4-major
ENV PATH /opt/gcc-arm-none-eabi-9-2019-q4-major/bin:$PATH

# Install J-Link software
RUN  wget -O JLink.deb https://github.com/magus517707/STM32-Docker-Env/raw/master/Jlink/JLink_Linux_V672d_x86_64.deb \
&& dpkg -i ./JLink.deb

# Install OpenOCD
RUN git clone git://git.code.sf.net/p/openocd/code openocd-code \
&& cd openocd-code \
&& ./bootstrap \
&& ./configure \
&& make -j"$(nproc)" \
&& make install \
&& cp /usr/local/share/openocd/contrib/60-openocd.rules /etc/udev/rules.d/60-openocd.rules

# Clean up the image and set the working directory.
RUN rm -rf JLink.deb \
&& rm -rf gcc_arm.tar.bz2 \
&& rm -rf openocd-code \
&& rm -rf /var/lib/apt/lists/ \
&& mkdir -p /home/dev \
&& echo $PATH

VOLUME [ "/home/dev" ]
WORKDIR /home/dev

# Expose the telnet OpenOCD connection
EXPOSE 4444