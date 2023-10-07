FROM cm2network/steamcmd
# this finishes some steamcmd first time setup things, so that we don't have to run them everytime we start the container
# ,originally done by old init parent container
RUN /home/steam/steamcmd/steamcmd.sh +quit

USER root
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install -y perl-modules \
    curl \
    lsof \
    libc6-i386 \
    libgcc1 \
    bzip2 \
    dos2unix \
    sudo \
    findutils \
    perl\
    rsync\
    sed\
    tar\
    cron

# added dos2unix for compatibility when starting docker with wsl2

RUN curl -sL "https://raw.githubusercontent.com/FezVrasta/ark-server-tools/v1.6.62/netinstall.sh" | bash -s steam && \
    ln -s /usr/local/bin/arkmanager /usr/bin/arkmanager &&\
    ln -s   /home/steam/steamcmd /usr/local/bin

COPY arkmanager/arkmanager.cfg /etc/arkmanager/arkmanager.cfg
RUN dos2unix  /etc/arkmanager/arkmanager.cfg

COPY arkmanager/instance.cfg /etc/arkmanager/instances/main.cfg
RUN dos2unix /etc/arkmanager/instances/main.cfg

COPY run.sh /home/steam/run.sh
RUN dos2unix /home/steam/run.sh

COPY log.sh /home/steam/log.sh
RUN dos2unix /home/steam/log.sh

RUN mkdir /ark && \
    chown -R steam:steam /home/steam/ /ark

RUN echo "%sudo   ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers && \
    usermod -a -G sudo steam && \
    touch /home/steam/.sudo_as_admin_successful

WORKDIR /home/steam
USER steam

ENV am_ark_SessionName="Ark Server" \
    am_serverMap="TheIsland" \
    am_ark_ServerAdminPassword="k3yb04rdc4t" \
    am_ark_MaxPlayers=70 \
    am_ark_QueryPort=27015 \
    am_ark_Port=7778 \
    am_ark_RCONPort=32330 \
    am_arkwarnminutes=15

VOLUME /ark

CMD [ "./run.sh" ]
