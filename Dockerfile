FROM alpine:latest AS base

RUN apk --update add --no-cache --virtual .build-dependencies git g++ make cmake libx11 mesa-dev python freetype-dev sdl2-dev glu-dev build-base
RUN git clone https://github.com/teeworlds/teeworlds --recurse-submodules /opt/teeworlds_build
RUN mkdir /opt/teeworlds_build/build
RUN cd /opt/teeworlds_build/build && cmake ..
RUN cd /opt/teeworlds_build/build && make



FROM alpine:latest

ARG BUILD_DATE
ARG VCS_REF

ARG USER=teeworlduser
ENV HOME /home/$USER

# install sudo as root
RUN apk add --update sudo

# add new user
RUN adduser -D $USER

LABEL org.label-schema.build-date=$BUILD_DATE \
          org.label-schema.name="Teeworlds Docker Server" \
          org.label-schema.description="Basic alpine based Teeworlds server not using rootuser" \
          org.label-schema.url="https://hub.docker.com/r/mh03r932/teeworlds-docker-server" \
          org.label-schema.vcs-ref=$VCS_REF \
          org.label-schema.vcs-url="https://github.com/mh03r932/teeworlds-docker-server" \
          org.label-schema.vendor="mh03r932"

COPY --from=base /opt/teeworlds_build/build /opt/teeworlds
RUN apk --update add --no-cache libstdc++
COPY ./run.sh /opt/teeworlds/run.sh
RUN chown -R $USER:$USER $HOME && \
    chown -R $USER:$USER opt/teeworlds/

RUN chmod +x /opt/teeworlds/run.sh


USER $USER

EXPOSE 8303/udp

WORKDIR /opt/teeworlds

ENTRYPOINT ["./run.sh"]
