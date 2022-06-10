#------------------------------------------------------------------------------
# BUILD
#------------------------------------------------------------------------------
FROM alpine:latest as builder

# Default image build config passed to cmake. Configured by user if they want
ARG BUILD_TYPE=Release

# Get all needed dependencies for this thin alpine OS
RUN apk update && apk add --no-cache \ 
    autoconf build-base binutils cmake curl file gcc g++ git libgcc libtool linux-headers make musl-dev ninja tar zip unzip wget pkgconfig

# vcpkg to build our 3rd party dependencies
RUN git clone https://github.com/microsoft/vcpkg.git /tools/vcpkg \
    && cd /tools/vcpkg \
    && git checkout tags/2022.02.02 \ 
    && ./bootstrap-vcpkg.sh

# Lets keep it tidy and have dependencies produced by vcpkg here
RUN mkdir -p /app/3rd-party

# Needed to run vcpkg inside alpine. We could remove this step once vcpkg fixes it
# This would not be needed if we had used ubuntu as image, but resulting image would be x15 bigger
COPY cmake/x64-linux-musl.cmake /tools/vcpkg/triplets/

# Manifest mode for vcpkg. Will build all dependencies using the vcpkg.json found inside app/
COPY vcpkg.json /app/3rd-party/
ARG VCPKG_FORCE_SYSTEM_BINARIES=1
RUN cd /app/3rd-party && /tools/vcpkg/vcpkg install

# Normal cmake build. We must copy all the source code from the host machine
# The source changes often so we copy at this step to not invalidate the cache at prev layers
COPY . /app
RUN mkdir -p /app/build \
    && cd app/build \
    && cmake -DCMAKE_BUILD_TYPE=${BUILD_TYPE} \  
             -DCMAKE_TOOLCHAIN_FILE=/tools/vcpkg/scripts/buildsystems/vcpkg.cmake \
             .. \
    && cmake --build .

#------------------------------------------------------------------------------
# RUNTIME
#------------------------------------------------------------------------------
FROM alpine:latest as run

# Need at least the c++ libraries to run a c++ program
RUN apk update && apk add --no-cache libstdc++

# Copy from the previous step marked as 'build' all the produced binaries
COPY --from=builder /app/build/bin /usr/local/bin

# for aws-elastic-beanstalk
EXPOSE 8080

# Start the server
CMD ./usr/local/bin/simple-cpp-webserver