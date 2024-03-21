ARG PYTHON_VERSION=3.12

FROM ubuntu:focal AS base

# Avoid warnings by switching to noninteractive
ENV DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash", "-c"]

# Install dependencies
RUN apt-get update && \
    apt-get install -y \
        ca-certificates \
        curl \
        gnupg \
        htop \
        locales \
        make \
        openssh-server \
        software-properties-common \
        sudo \
        tree \
        wget \
        zip \
        zsh

# Install GCC
ARG GCC_VERSION=13
RUN add-apt-repository -y ppa:ubuntu-toolchain-r/test && \
    apt-get update && \
    apt-get install -y \
        gcc-${GCC_VERSION} \
        gcc-${GCC_VERSION}-multilib \
        gcc-${GCC_VERSION}-plugin-dev \
        g++-${GCC_VERSION} \
        g++-${GCC_VERSION}-multilib && \
    update-alternatives \
        --install /usr/bin/gcc gcc /usr/bin/gcc-${GCC_VERSION} ${GCC_VERSION} \
        --slave /usr/bin/g++ g++ /usr/bin/g++-${GCC_VERSION} \
        --slave /usr/bin/gcov gcov /usr/bin/gcov-${GCC_VERSION}

# Install Python
ARG PYTHON_VERSION
RUN add-apt-repository -y ppa:deadsnakes/ppa && \
    apt-get update && \
    apt-get install -y \
        python${PYTHON_VERSION} \
        python${PYTHON_VERSION}-dev \
        libpython${PYTHON_VERSION} \
        libpython${PYTHON_VERSION}-dev \
        python${PYTHON_VERSION}-distutils \
        python${PYTHON_VERSION}-venv

# Install Git
RUN add-apt-repository -y ppa:git-core/ppa && \
    apt-get update && \
    apt-get install -y git

# Install CMake
RUN wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | \
        gpg --dearmor - | \
        tee /usr/share/keyrings/kitware-archive-keyring.gpg >/dev/null && \
    echo "deb [signed-by=/usr/share/keyrings/kitware-archive-keyring.gpg] https://apt.kitware.com/ubuntu/ focal main" | \
        tee /etc/apt/sources.list.d/kitware.list >/dev/null && \
    apt-get update && \
    rm /usr/share/keyrings/kitware-archive-keyring.gpg && \
    apt-get install -y kitware-archive-keyring && \
    apt-get install -y \
        cmake \
        ninja-build

# Add library path
RUN echo "/usr/local/ulib/lib" > /etc/ld.so.conf.d/ulib.conf


FROM base AS builder

# Install dependencies
RUN apt-get install -y \
        bison \
        libssl-dev \
        zlib1g-dev

# Install ncurses
ARG NCURSES_VERSION=6.4
ARG NCRUSES_SHA256=39893846139518e6c2d00ac1d354d4889f0f394acd44885d70b14eaef4e23e8e
RUN mkdir -p /install/ncurses && \
    cd /install/ncurses && \
    curl -fsSOL https://github.com/mirror/ncurses/archive/refs/tags/v${NCURSES_VERSION}.tar.gz && \
    echo "${NCRUSES_SHA256}  v${NCURSES_VERSION}.tar.gz" | sha256sum -c && \
    tar xzf v${NCURSES_VERSION}.tar.gz && \
    cd ncurses-${NCURSES_VERSION} && \
    ./configure \
        --prefix=/usr/local/ulib && \
    make && \
    make install && \
    ldconfig

# Install libevent
ARG LIBEVENT_VERSION=2.1.12-stable
RUN mkdir -p /install/libevent && \
    cd /install/libevent && \
    curl -fsSOL https://github.com/libevent/libevent/releases/download/release-${LIBEVENT_VERSION}/libevent-${LIBEVENT_VERSION}.tar.gz && \
    curl -fsSOL https://github.com/libevent/libevent/releases/download/release-${LIBEVENT_VERSION}/libevent-${LIBEVENT_VERSION}.tar.gz.asc && \
    curl -fsSL https://azat.sh/azatpub.asc | gpg --import && \
    gpg --verify libevent-${LIBEVENT_VERSION}.tar.gz.asc && \
    tar xzf libevent-${LIBEVENT_VERSION}.tar.gz && \
    cd libevent-${LIBEVENT_VERSION} && \
    mkdir build && \
    cd build && \
    cmake -DCMAKE_INSTALL_PREFIX=/usr/local/ulib .. && \
    make && \
    # make verify && \
    make install && \
    ldconfig

# Install tmux (requires libevent and ncurses)
ARG TMUX_VERSION=3.4
ARG TMUX_SHA256=551ab8dea0bf505c0ad6b7bb35ef567cdde0ccb84357df142c254f35a23e19aa
RUN mkdir -p /install/tmux && \
    cd /install/tmux && \
    curl -fsSOL https://github.com/tmux/tmux/releases/download/${TMUX_VERSION}/tmux-${TMUX_VERSION}.tar.gz && \
    echo "${TMUX_SHA256}  tmux-${TMUX_VERSION}.tar.gz" | sha256sum -c && \
    tar xzf tmux-${TMUX_VERSION}.tar.gz && \
    cd tmux-${TMUX_VERSION} && \
    ./configure \
        --prefix=/usr/local/ulib \
        CPPFLAGS="-I/usr/local/ulib/include -I/usr/local/ulib/include/ncurses" \
        LDFLAGS="-L/usr/local/ulib/lib" && \
    make && \
    make install && \
    ldconfig

# Install GDB
ARG GDB_VERSION=14.2
RUN mkdir -p /install/gdb && \
    cd /install/gdb && \
    curl -fsSOL https://ftp.gnu.org/gnu/gdb/gdb-${GDB_VERSION}.tar.xz && \
    curl -fsSOL https://ftp.gnu.org/gnu/gdb/gdb-${GDB_VERSION}.tar.xz.sig && \
    curl -fsSOL https://ftp.gnu.org/gnu/gnu-keyring.gpg && \
    gpg --verify --keyring ./gnu-keyring.gpg gdb-${GDB_VERSION}.tar.xz.sig && \
    tar xf gdb-${GDB_VERSION}.tar.xz && \
    cd gdb-${GDB_VERSION} && \
    ./configure \
        --prefix=/usr/local/ulib \
        --with-python=python${PYTHON_VERSION} \
        --enable-lto && \
    make && \
    make install && \
    ldconfig


FROM base

# Copy built software from builder
COPY --from=builder /usr/local/ulib /usr/local/ulib
RUN ldconfig

# Install Vim
RUN add-apt-repository -y ppa:jonathonf/vim && \
    apt-get update && \
    apt-get install -y vim

# Install Clang
ARG CLANG_VERSION=18
COPY common/clang.sh /tmp
RUN wget -O - https://apt.llvm.org/llvm.sh | bash -s -- ${CLANG_VERSION} && \
    chmod +x /tmp/clang.sh && \
    apt-get install -y clang-format-${CLANG_VERSION} && \
    /tmp/clang.sh && \
    update-alternatives --remove-all gcc && \
    update-alternatives \
        --install /usr/bin/gcc gcc /usr/bin/gcc-${GCC_VERSION} ${GCC_VERSION} \
        --slave /usr/bin/g++ g++ /usr/bin/g++-${GCC_VERSION} \
        --slave /usr/bin/gcov gcov /usr/bin/gcov-${GCC_VERSION} && \
    rm /tmp/clang.sh

# Install Docker client and Compose
RUN install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    chmod a+r /etc/apt/keyrings/docker.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] " \
        "https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo ${VERSION_CODENAME}) stable" | \
        tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update && \
    apt-get install -y docker-ce-cli docker-compose-plugin

# Install pip
ARG PYTHON_VERSION
RUN curl -fsSL https://bootstrap.pypa.io/get-pip.py -o /tmp/get-pip.py && \
    python${PYTHON_VERSION} /tmp/get-pip.py && \
    python${PYTHON_VERSION} -m pip install --upgrade pip setuptools wheel

# Setup sshd_config
COPY focal/sshd_config.patch .
RUN patch -p0 < sshd_config.patch && \
    rm sshd_config.patch

# Setup non-root user with sudo and docker
RUN adduser --gecos "" --disabled-password ubuntu && \
    echo "ubuntu ALL=(ALL:ALL) NOPASSWD:ALL" >> /etc/sudoers
USER ubuntu
WORKDIR /home/ubuntu

# Setup Locales
RUN sudo locale-gen en_US.UTF-8

# Install Python libraries
RUN python${PYTHON_VERSION} -m pip install --upgrade pip setuptools wheel && \
    python${PYTHON_VERSION} -m pip install powerline-status virtualenvwrapper

# Install Oh My Zsh
COPY --chown=ubuntu common/zsh/.zshrc .zshrc.bk
COPY --chown=ubuntu common/zsh/.p10k.zsh .
RUN echo -e "y" | sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" && \
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-.oh-my-zsh/custom}/plugins/zsh-autosuggestions && \
    git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:-.oh-my-zsh/custom}/plugins/zsh-completions && \
    git clone https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM:-.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting && \
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k && \
    echo "ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=60'" >> ${ZSH_CUSTOM:-.oh-my-zsh/custom}/zsh-autosuggestions_custom.zsh && \
    sed -i "s/\$PYTHON_VERSION/${PYTHON_VERSION}/g" .zshrc.bk && \
    mv .zshrc.bk .zshrc

# Swtich to Zsh
COPY common/.profile.patch .
RUN patch -p0 < .profile.patch && \
    rm .profile.patch

# Configure Vim
RUN mkdir -p .vim/colors
COPY --chown=ubuntu common/vim/darcula.vim .vim/colors
COPY --chown=ubuntu common/vim/.vimrc .
RUN sed -i "s/\$PYTHON_VERSION/${PYTHON_VERSION}/g" .vimrc && \
    git clone https://github.com/VundleVim/Vundle.vim.git .vim/bundle/Vundle.vim && \
    vim +PluginInstall +qall > /dev/null && \
    python${PYTHON_VERSION} .vim/bundle/YouCompleteMe/install.py --clang-completer && \
    sed -i "s/\"ycm //g" .vimrc

# Install Oh My Tmux
COPY common/tmux/.tmux.conf.local.patch .
RUN git clone https://github.com/gpakosz/.tmux.git .tmux && \
    ln -s -f .tmux/.tmux.conf && \
    cp .tmux/.tmux.conf.local . && \
    patch -p0 < .tmux.conf.local.patch && \
    rm .tmux.conf.local.patch

# Install pwndbg
RUN mkdir -p .gdb && \
    git clone https://github.com/pwndbg/pwndbg .gdb/pwndbg && \
    (cd .gdb/pwndbg; PATH="/usr/local/ulib/bin:${PATH}" ./setup.sh)

# Install v2ray and v2rayA
ARG V2RAY_VERSION=5.14.1
ARG V2RAYA_VERSION=2.2.5.1
ARG LOYALSOLDIER_VERSION=202403202208
RUN mkdir -p v2ray && \
    pushd v2ray && \
    curl -fsSOL https://github.com/v2fly/v2ray-core/releases/download/v${V2RAY_VERSION}/v2ray-linux-64.zip && \
    curl -fsSOL https://github.com/v2fly/v2ray-core/releases/download/v${V2RAY_VERSION}/v2ray-linux-64.zip.dgst && \
    curl -fsSOL https://github.com/v2rayA/v2rayA/releases/download/v${V2RAYA_VERSION}/installer_debian_x64_${V2RAYA_VERSION}.deb && \
    curl -fsSOL https://github.com/v2rayA/v2rayA/releases/download/v${V2RAYA_VERSION}/installer_debian_x64_${V2RAYA_VERSION}.deb.sha256.txt && \
    curl -fsSOL https://github.com/Loyalsoldier/v2ray-rules-dat/releases/download/${LOYALSOLDIER_VERSION}/geoip.dat && \
    curl -fsSOL https://github.com/Loyalsoldier/v2ray-rules-dat/releases/download/${LOYALSOLDIER_VERSION}/geoip.dat.sha256sum && \
    curl -fsSOL https://github.com/Loyalsoldier/v2ray-rules-dat/releases/download/${LOYALSOLDIER_VERSION}/geosite.dat && \
    curl -fsSOL https://github.com/Loyalsoldier/v2ray-rules-dat/releases/download/${LOYALSOLDIER_VERSION}/geosite.dat.sha256sum && \
    echo "`cat v2ray-linux-64.zip.dgst | grep -e 'SHA2-512' | head -n 1 | cut -f 2 -d ' '`  v2ray-linux-64.zip" | sha512sum -c && \
    echo "`cat installer_debian_x64_${V2RAYA_VERSION}.deb.sha256.txt`  installer_debian_x64_${V2RAYA_VERSION}.deb" | sha256sum -c && \
    echo "`cat geoip.dat.sha256sum | cut -f 1 -d ' '`  geoip.dat" | sha256sum -c && \
    echo "`cat geosite.dat.sha256sum | cut -f 1 -d ' '`  geosite.dat" | sha256sum -c && \
    unzip v2ray-linux-64.zip -d v2ray-linux-64 && \
    sudo mv v2ray-linux-64/v2ray /usr/bin && \
    sudo apt-get install -y ./installer_debian_x64_${V2RAYA_VERSION}.deb && \
    popd && \
    mkdir -p .config/v2ray && \
    mv v2ray/geoip.dat .config/v2ray && \
    mv v2ray/geosite.dat .config/v2ray && \
    pushd .config/v2ray && \
    ln -s geosite.dat LoyalsoldierSite.dat

# Finally reset default gcc
RUN sudo update-alternatives --remove-all gcc && \
    sudo update-alternatives \
        --install /usr/bin/gcc gcc /usr/bin/gcc-${GCC_VERSION} ${GCC_VERSION} \
        --slave /usr/bin/g++ g++ /usr/bin/g++-${GCC_VERSION} \
        --slave /usr/bin/gcov gcov /usr/bin/gcov-${GCC_VERSION}

# Clean up
RUN sudo rm -rf /var/lib/apt/lists/* v2ray

COPY common/entrypoint.sh /

# Switch back to dialog for any ad-hoc use of apt-get
ENV DEBIAN_FRONTEND=dialog

ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "/usr/bin/zsh" ]
