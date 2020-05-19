# Download the latest Ubuntu version
FROM ubuntu:latest

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
libncurses5

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
COPY JLink_Linux_V672d_x86_64.deb JLink.deb
RUN dpkg -i ./JLink.deb

# Clean up the image and set the working directory.
RUN rm -rf JLink.deb \
&& rm -rf gcc_arm.tar.bz2 \
&& rm -rf /var/lib/apt/lists/ \
&& mkdir -p /home/dev \
&& echo $PATH

VOLUME [ "/home/dev" ]
WORKDIR /home/dev