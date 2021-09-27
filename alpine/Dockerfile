FROM jrottenberg/ffmpeg:4.0-alpine

ENV ISPY_URL https://ispyfiles.azureedge.net/downloads
ENV ISPY_FILENAME Agent_Linux64_3_5_9_0.zip

ENV DOTNET_URL https://download.visualstudio.microsoft.com/download/pr/57d5859a-f302-408d-95b0-8ab2cbcdb431/db0a869ce50247ca92cdc03a52d4a8a7
ENV DOTNET_FILE dotnet-sdk-3.1.413-linux-musl-x64.tar.gz

RUN apk add --no-cache linux-headers libevent libevent-dev openssl openssl-dev build-base pkgconf make ca-certificates bash icu-libs krb5-libs libgcc libintl libssl1.1 libstdc++ zlib unzip curl && update-ca-certificates

RUN apk add libgdiplus --repository https://dl-3.alpinelinux.org/alpine/edge/testing/

RUN mkdir -p /opt/dotnet \
  && curl -O "${DOTNET_URL}/${DOTNET_FILE}" \
  && tar -xf ${DOTNET_FILE} -C /opt/dotnet
RUN mkdir -p /opt/agent \
  && curl -O "${ISPY_URL}/${ISPY_FILENAME}" \
  && unzip "${ISPY_FILENAME}" -d /opt/agent
RUN mkdir -p build/coturn \
  && curl -O http://turnserver.open-sys.org/downloads/v4.5.2/turnserver-4.5.2.tar.gz \
  && tar -xf turnserver-4.5.2.tar.gz -C build/coturn

RUN cd build/coturn/turnserver-4.5.2 && ./configure && make && make install

ENV PATH /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
#ENV LD_LIBRARYPATH

# Main UI port
EXPOSE 8090

# TURN server port
EXPOSE 3478/udp

# TURN server UDP port range
EXPOSE 50000-50010/udp


ENTRYPOINT ["/opt/dotnet/dotnet", "/opt/agent/Agent.dll"]
