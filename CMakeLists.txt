#set(CMAKE_TOOLCHAIN_FILE ~/tools/vcpkg/scripts/buildsystems/vcpkg.cmake)
cmake_minimum_required(VERSION 3.16)
project(simple-cpp-webserver)

# setup
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

# 3rd party
find_package(restinio CONFIG REQUIRED)
find_package(fmt CONFIG REQUIRED)
find_package(unofficial-http-parser CONFIG REQUIRED)

# web server
add_executable(simple-cpp-webserver "src/main.cpp")
target_link_libraries(simple-cpp-webserver 
    PRIVATE 
        restinio::restinio
        fmt::fmt-header-only
        unofficial::http_parser::http_parser
)