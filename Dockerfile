FROM rust:latest

ARG DEBIAN_FRONTEND=noninteractive
ARG DEBCONF_NONINTERACTIVE_SEEN=true

RUN apt-get update
RUN apt-get -y dist-upgrade
RUN apt-get -y install mingw-w64 wine64-development p7zip-full msitools
RUN rustup update
RUN rustup target add x86_64-unknown-linux-gnu
RUN rustup target add x86_64-pc-windows-gnu
RUN rustup toolchain install stable-x86_64-unknown-linux-gnu

# see https://gist.github.com/est31/7235ab253554d33046873dfb64e7ecdc
RUN git clone https://github.com/est31/msvc-wine-rust.git
WORKDIR /msvc-wine-rust
RUN chmod +x get.sh
RUN ./get.sh licenses-accepted

RUN echo [target.x86_64-pc-windows-msvc] > /usr/local/cargo/config.toml
RUN echo linker = "/msvc-wine-rust/linker-scripts/linkx64.sh" >> /usr/local/cargo/config.toml
