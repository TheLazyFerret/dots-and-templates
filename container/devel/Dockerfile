FROM alpine:latest

MAINTAINER TheLazyFerret

ARG DOTFILES_REPO="https://github.com/TheLazyFerret/dots-and-templates.git"

ARG USERNAME="user"
ARG USER_UID="1000"
ARG USER_GID="1000"

# System side configurations
USER root
RUN apk update && \
		apk upgrade && \
		apk add -l --no-interactive bash gcc g++ vim openssh curl git make cmake gdb

RUN addgroup -g $USER_GID $USERNAME
RUN adduser -G $USERNAME -u $USER_UID -D -s /bin/bash $USERNAME

# User side configurations

USER $USERNAME
WORKDIR /home/$USERNAME

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs -o rustup.sh && \
    bash rustup.sh -y && \
    rm rustup.sh

RUN git clone $DOTFILES_REPO dotfiles && \
    cp dotfiles/vim/vimrc .vimrc

RUN mkdir -p .ssh/
