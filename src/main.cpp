#include <restinio/all.hpp>
#include <iostream>

int main()
{
    std::cout << "simple-cpp-webserver listening on port 8080\n";

    restinio::run(
        restinio::on_this_thread()
        .port(8080)
        .address("0.0.0.0")
        .request_handler([](auto req) {
            std::cout << "\nreceived request\n";
            return req->create_response().set_body("Hello, World!").done();
        }));

    return 0;
}