FROM mcr.microsoft.com/dotnet/core/aspnet:3.1.10-bionic

#Define download location variables
ARG FILE_LOCATION="https://ispyfiles.azureedge.net/downloads/Agent_Linux64_3_5_9_0.zip"
ENV FILE_LOCATION_SET=${FILE_LOCATION:+true}
ENV DEFAULT_FILE_LOCATION="https://www.ispyconnect.com/api/Agent/DownloadLocation2?productID=24&is64=true&platform=Linux"
ARG DEBIAN_FRONTEND=noninteractive
ARG TZ=America/Los_Angeles


# Download and install dependencies
RUN apt-get update \
    && apt-get install -y wget curl libtbb-dev libc6-dev unzip multiarch-support gss-ntlmssp software-properties-common \
    && wget http://security.ubuntu.com/ubuntu/pool/main/libj/libjpeg-turbo/libjpeg-turbo8_1.5.2-0ubuntu5.18.04.4_amd64.deb \
    && wget http://fr.archive.ubuntu.com/ubuntu/pool/main/libj/libjpeg8-empty/libjpeg8_8c-2ubuntu8_amd64.deb \
    && dpkg -i libjpeg-turbo8_1.5.2-0ubuntu5.18.04.4_amd64.deb \
    && dpkg -i libjpeg8_8c-2ubuntu8_amd64.deb \
    && rm libjpeg8_8c-2ubuntu8_amd64.deb \
    && rm libjpeg-turbo8_1.5.2-0ubuntu5.18.04.4_amd64.deb

ENV DOTNET_URL https://download.visualstudio.microsoft.com/download/pr/70d12135-d65f-4f4c-9d96-a6ac0251fb1b/57856b7654e338027cfb53552b2c4d46
ENV DOTNET_FILE dotnet-sdk-3.1.413-linux-x64.tar.gz

RUN mkdir -p /opt/dotnet \
  && curl -O "${DOTNET_URL}/${DOTNET_FILE}" \
  && tar -xf ${DOTNET_FILE} -C /opt/dotnet
RUN wget https://packages.microsoft.com/config/ubuntu/19.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb \
    && dpkg -i packages-microsoft-prod.deb \
    && rm packages-microsoft-prod.deb \
    && add-apt-repository -y ppa:jonathonf/ffmpeg-4 \
    && apt-get update && apt-get install -y ffmpeg aspnetcore-runtime-3.1 dotnet-sdk-3.1

# Download/Install iSpy Agent DVR:
# Check if we were given a specific version
RUN if [ "${FILE_LOCATION_SET}" = "true" ]; then \
    echo "Downloading from specific location: ${FILE_LOCATION}" && \
    wget -c ${FILE_LOCATION} -O agent.zip; \
    else \
    #Get latest instead
    echo "Downloading latest" && \
    wget -c $(wget -qO- "https://www.ispyconnect.com/api/Agent/DownloadLocation2?productID=24&is64=true&platform=Linux" | tr -d '"') -O agent.zip; \
    fi && \
    unzip agent.zip -d /agent && \
    rm agent.zip

# Install libgdiplus, used for smart detection
RUN apt-get install -y libgdiplus

# Install Time Zone
RUN apt-get install -y tzdata

# Clean up
RUN apt-get -y --purge remove unzip wget \
    && apt autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Docker needs to run a TURN server to get webrtc traffic to and from it over forwarded ports from the host
# These are the default ports. If the ports below are modified here you'll also need to set the ports in XML/Config.xml
# for example <TurnServerPort>3478</TurnServerPort><TurnServerMinPort>50000</TurnServerMinPort><TurnServerMaxPort>50010</TurnServerMaxPort>
# The main server port is overridden by creating a text file called port.txt in the root directory containing the port number, eg: 8090
# To access the UI you must use the local IP address of the host, NOT localhost - for example http://192.168.1.12:8090/

# Define default environment variables
ENV PATH /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Main UI port
EXPOSE 8090

# TURN server port
EXPOSE 3478/udp

# TURN server UDP port range
EXPOSE 50000-50010/udp

# Data volumes
VOLUME ["/agent/Media/XML", "/agent/Media/WebServerRoot/Media", "/agent/Commands"]

# Define service entrypoint
CMD ["/opt/dotnet/dotnet", "/agent/Agent.dll"]
