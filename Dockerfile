FROM golang:1.14-buster AS easy-novnc-build
WORKDIR /src
RUN go mod init build && \
    go get github.com/geek1011/easy-novnc@v1.1.0 && \
    go build -o /bin/easy-novnc github.com/geek1011/easy-novnc

FROM debian:buster

RUN apt-get update -y && \
    apt-get install -y --no-install-recommends openbox tigervnc-standalone-server supervisor gosu && \
    rm -rf /var/lib/apt/lists && \
    mkdir -p /usr/share/desktop-directories

RUN apt-get update -y && \
    apt-get install -y --no-install-recommends lxterminal nano wget openssh-client rsync ca-certificates xdg-utils htop tar xzip gzip bzip2 zip unzip git build-essential m4 libglu1-mesa locales && \
    rm -rf /var/lib/apt/lists

# RUN git clone https://github.com/supermerill/SuperSlicer.git 
RUN wget https://github.com/supermerill/SuperSlicer/releases/download/2.3.57.11/SuperSlicer_2.3.57.11_linux64_220213.tar.zip && \
    unzip SuperSlicer_2.3.57.11_linux64_220213.tar.zip && \
    tar xf SuperSlicer_2.3.57.11_linux64_220213.tar

COPY --from=easy-novnc-build /bin/easy-novnc /usr/local/bin/
COPY menu.xml /etc/xdg/openbox/
COPY supervisord.conf /etc/
EXPOSE 8080

RUN groupadd --gid 1000 app && \
    useradd --home-dir /data --shell /bin/bash --uid 1000 --gid 1000 app && \
    mkdir -p /data
VOLUME /data

RUN echo 'en_US ISO-8859-1' >> /etc/locale.gen && \
    echo 'en_US.ISO-8859-15 ISO-8859-15' >> /etc/locale.gen && \
    echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen && \
    locale-gen

CMD ["sh", "-c", "chown app:app /data /dev/stdout && exec gosu app supervisord"]
