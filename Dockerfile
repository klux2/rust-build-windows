FROM rust:latest

ARG DEBIAN_FRONTEND=noninteractive
ARG DEBCONF_NONINTERACTIVE_SEEN=true

RUN apt-get update
RUN apt-get -y dist-upgrade
RUN apt-get -y install mingw-w64 wine64-development p7zip-full msitools
RUN rustup update
RUN rustup target add x86_64-unknown-linux-gnu
RUN rustup target add x86_64-pc-windows-msvc
RUN rustup toolchain install stable-x86_64-unknown-linux-gnu

# see https://gist.github.com/est31/7235ab253554d33046873dfb64e7ecdc
WORKDIR /
RUN git clone https://github.com/est31/msvc-wine-rust.git
WORKDIR /msvc-wine-rust
RUN chmod +x get.sh
# it seems like the second call will not download an important file, so we'll call this script twice
RUN ./get.sh; ./get.sh licenses-accepted

RUN echo [target.x86_64-pc-windows-msvc] > /usr/local/cargo/config.toml
RUN echo 'linker = "/msvc-wine-rust/linker-scripts/linkx64.sh"' >> /usr/local/cargo/config.toml

WORKDIR /


RUN mkdir /openssl-win
WORKDIR /openssl-win
RUN wget -O openssl.7z https://www.npcglib.org/~stathis/downloads/openssl-1.1.0f-vs2017.7z
RUN p7zip -d openssl.7z
WORKDIR /openssl-win/openssl-1.1.0f-vs2017/lib64/
RUN find . \( -name '*MD.*' -o -name '*d.*' \) -exec rm {} \;
RUN mv libcryptoMT.lib libcrypto.lib
RUN mv libsslMT.lib libssl.lib
ENV X86_64_PC_WINDOWS_MSVC_OPENSSL_DIR=/openssl-win/openssl-1.1.0f-vs2017
ENV X86_64_PC_WINDOWS_MSVC_OPENSSL_LIB_DIR=/openssl-win/openssl-1.1.0f-vs2017/lib64
ENV X86_64_PC_WINDOWS_MSVC_OPENSSL_INCLUDE_DIR=/openssl-win/openssl-1.1.0f-vs2017/include64
ENV X86_64_PC_WINDOWS_MSVC_OPENSSL_STATIC=1

WORKDIR /