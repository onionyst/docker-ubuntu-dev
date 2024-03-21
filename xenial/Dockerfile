ARG PYTHON_VERSION=3.9

FROM ubuntu:xenial AS base

# Avoid warnings by switching to noninteractive
ENV DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash", "-c"]

RUN apt-get update && \
    apt-get install -y \
        apt-transport-https \
        ca-certificates \
        curl \
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
ARG GCC_VERSION=9
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

# Install Git
RUN add-apt-repository -y ppa:git-core/ppa && \
    apt-get update && \
    apt-get install -y git

# Add library path
RUN echo "/usr/local/ulib/lib" > /etc/ld.so.conf.d/ulib.conf


FROM base AS builder

# Install dependencies
RUN sed -i "s/# deb-src/deb-src/g" /etc/apt/sources.list && \
    apt-get update && \
    apt-get build-dep -y python3 && \
    apt-get install -y \
        autoconf \
        bison \
        blt-dev \
        build-essential \
        bzip2 \
        debhelper \
        devscripts \
        dpkg-dev \
        equivs \
        git-buildpackage \
        gnupg2 \
        libbluetooth-dev \
        libbz2-dev \
        libdb-dev \
        libexpat1-dev \
        libffi-dev \
        libgdbm-dev \
        libgpm2 \
        liblzma-dev \
        libmpdec-dev \
        libncurses-dev \
        libreadline-dev \
        libsqlite3-dev \
        libssl-dev \
        locales \
        lsb-release \
        mime-support \
        net-tools \
        netbase \
        pristine-tar \
        python3-sphinx \
        python3 \
        quilt \
        sharutils \
        texinfo \
        time \
        tk-dev \
        xauth \
        xvfb \
        zlib1g-dev && \
    sed -i "s/deb-src/# deb-src/g" /etc/apt/sources.list

# Install CMake
ARG CMAKE_VERSION=3.28.3
ARG CMAKE_SHA256=1276929b8a73a284652b42f449e2f29efe759ee18105f5bc3175a8a636c754c0
RUN mkdir -p /install/cmake && \
    cd /install/cmake && \
    curl -fsSOL https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}-linux-x86_64.sh && \
    echo "${CMAKE_SHA256}  cmake-${CMAKE_VERSION}-linux-x86_64.sh" | sha256sum -c && \
    mkdir -p /usr/local/ulib && \
    sh cmake-${CMAKE_VERSION}-linux-x86_64.sh --prefix=/usr/local/ulib --skip-license && \
    ldconfig

# Install Libgpg-error
ARG LIBGPG_ERROR_VERSION=1.48
RUN mkdir -p /install/libgpg-error && \
    cd /install/libgpg-error && \
    curl -fsSOL https://www.gnupg.org/ftp/gcrypt/libgpg-error/libgpg-error-${LIBGPG_ERROR_VERSION}.tar.bz2 && \
    curl -fsSOL https://www.gnupg.org/ftp/gcrypt/libgpg-error/libgpg-error-${LIBGPG_ERROR_VERSION}.tar.bz2.sig && \
    curl -fsSL https://gnupg.org/signature_key.asc | gpg2 --import && \
    gpg2 --verify libgpg-error-${LIBGPG_ERROR_VERSION}.tar.bz2.sig && \
    tar xjf libgpg-error-${LIBGPG_ERROR_VERSION}.tar.bz2 && \
    cd libgpg-error-${LIBGPG_ERROR_VERSION} && \
    ./configure \
        --prefix=/usr/local/ulib && \
    make && \
    make install && \
    ldconfig

# Install Libgcrypt
ARG LIBGCRYPT_VERSION=1.10.3
RUN mkdir -p /install/libgcrypt && \
    cd /install/libgcrypt && \
    curl -fsSOL https://gnupg.org/ftp/gcrypt/libgcrypt/libgcrypt-${LIBGCRYPT_VERSION}.tar.bz2 && \
    curl -fsSOL https://gnupg.org/ftp/gcrypt/libgcrypt/libgcrypt-${LIBGCRYPT_VERSION}.tar.bz2.sig && \
    gpg2 --verify libgcrypt-${LIBGCRYPT_VERSION}.tar.bz2.sig && \
    tar xjf libgcrypt-${LIBGCRYPT_VERSION}.tar.bz2 && \
    cd libgcrypt-${LIBGCRYPT_VERSION} && \
    ./configure \
        --prefix=/usr/local/ulib && \
    make && \
    make install && \
    ldconfig

# Install Libksba
ARG LIBKSBA_VERSION=1.6.6
RUN mkdir -p /install/libksba && \
    cd /install/libksba && \
    curl -fsSOL https://gnupg.org/ftp/gcrypt/libksba/libksba-${LIBKSBA_VERSION}.tar.bz2 && \
    curl -fsSOL https://gnupg.org/ftp/gcrypt/libksba/libksba-${LIBKSBA_VERSION}.tar.bz2.sig && \
    gpg2 --verify libksba-${LIBKSBA_VERSION}.tar.bz2.sig && \
    tar xjf libksba-${LIBKSBA_VERSION}.tar.bz2 && \
    cd libksba-${LIBKSBA_VERSION} && \
    ./configure \
        --prefix=/usr/local/ulib && \
    make && \
    make install && \
    ldconfig

# Install Libassuan
ARG LIBASSUAN_VERSION=2.5.7
RUN mkdir -p /install/libassuan && \
    cd /install/libassuan && \
    curl -fsSOL https://gnupg.org/ftp/gcrypt/libassuan/libassuan-${LIBASSUAN_VERSION}.tar.bz2 && \
    curl -fsSOL https://gnupg.org/ftp/gcrypt/libassuan/libassuan-${LIBASSUAN_VERSION}.tar.bz2.sig && \
    gpg2 --verify libassuan-${LIBASSUAN_VERSION}.tar.bz2.sig && \
    tar xjf libassuan-${LIBASSUAN_VERSION}.tar.bz2 && \
    cd libassuan-${LIBASSUAN_VERSION} && \
    PATH="/usr/local/ulib/bin:${PATH}" ./configure \
        --prefix=/usr/local/ulib \
        LDFLAGS="-L/usr/local/ulib/lib" && \
    make && \
    make install && \
    ldconfig

# Install npth
ARG NPTH_VERSION=1.7
RUN mkdir -p /install/npth && \
    cd /install/npth && \
    curl -fsSOL https://gnupg.org/ftp/gcrypt/npth/npth-${NPTH_VERSION}.tar.bz2 && \
    curl -fsSOL https://gnupg.org/ftp/gcrypt/npth/npth-${NPTH_VERSION}.tar.bz2.sig && \
    gpg2 --keyserver keyserver.ubuntu.com --recv-key 4F25E3B6 && \
    gpg2 --verify npth-${NPTH_VERSION}.tar.bz2.sig && \
    tar xjf npth-${NPTH_VERSION}.tar.bz2 && \
    cd npth-${NPTH_VERSION} && \
    ./configure \
        --prefix=/usr/local/ulib && \
    make && \
    make install && \
    ldconfig

# Install Pinentry
ARG PINENTRY_VERSION=1.3.0
RUN mkdir -p /install/pinentry && \
    cd /install/pinentry && \
    curl -fsSOL https://gnupg.org/ftp/gcrypt/pinentry/pinentry-${PINENTRY_VERSION}.tar.bz2 && \
    curl -fsSOL https://gnupg.org/ftp/gcrypt/pinentry/pinentry-${PINENTRY_VERSION}.tar.bz2.sig && \
    gpg2 --verify pinentry-${PINENTRY_VERSION}.tar.bz2.sig && \
    tar xjf pinentry-${PINENTRY_VERSION}.tar.bz2 && \
    cd pinentry-${PINENTRY_VERSION} && \
    ./configure \
        --prefix=/usr/local/ulib && \
    make && \
    make install && \
    ldconfig

# Install GnuPG
ARG GNUPG_VERSION=2.4.5
RUN mkdir -p /install/gnupg && \
    cd /install/gnupg && \
    curl -fsSOL https://gnupg.org/ftp/gcrypt/gnupg/gnupg-${GNUPG_VERSION}.tar.bz2 && \
    curl -fsSOL https://gnupg.org/ftp/gcrypt/gnupg/gnupg-${GNUPG_VERSION}.tar.bz2.sig && \
    gpg2 --verify gnupg-${GNUPG_VERSION}.tar.bz2.sig && \
    tar xjf gnupg-${GNUPG_VERSION}.tar.bz2 && \
    cd gnupg-${GNUPG_VERSION} && \
    PATH="/usr/local/ulib/bin:${PATH}" ./configure \
        --prefix=/usr/local/ulib \
        LDFLAGS="-L/usr/local/ulib/lib" && \
    make && \
    make install && \
    ldconfig

# Install OpenSSL
ARG OPENSSL_VERSION=3.2.1
RUN mkdir -p /install/openssl && \
    cd /install/openssl && \
    curl -fsSOL https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz && \
    tar xzf openssl-${OPENSSL_VERSION}.tar.gz && \
    cd openssl-${OPENSSL_VERSION} && \
    ./config \
        --prefix=/usr/local/ulib \
        --libdir=lib \
        shared zlib && \
    make && \
    make install_sw && \
    ldconfig

# Install Python
ARG PYTHON_VERSION
ARG PYTHON_PATCH_VERSION=19
RUN mkdir -p /install/python && \
    cd /install/python && \
    curl -fsSOL https://www.python.org/ftp/python/${PYTHON_VERSION}.${PYTHON_PATCH_VERSION}/Python-${PYTHON_VERSION}.${PYTHON_PATCH_VERSION}.tar.xz && \
    curl -fsSOL https://www.python.org/ftp/python/${PYTHON_VERSION}.${PYTHON_PATCH_VERSION}/Python-${PYTHON_VERSION}.${PYTHON_PATCH_VERSION}.tar.xz.asc && \
    curl -fsSL https://keybase.io/ambv/pgp_keys.asc?fingerprint=e3ff2839c048b25c084debe9b26995e310250568 | /usr/local/ulib/bin/gpg --import && \
    /usr/local/ulib/bin/gpg --verify Python-${PYTHON_VERSION}.${PYTHON_PATCH_VERSION}.tar.xz.asc && \
    curl -fsSOL https://bootstrap.pypa.io/get-pip.py && \
    tar xf Python-${PYTHON_VERSION}.${PYTHON_PATCH_VERSION}.tar.xz && \
    cd Python-${PYTHON_VERSION}.${PYTHON_PATCH_VERSION} && \
    ./configure \
        --prefix=/usr/local/ulib \
        --with-openssl=/usr/local/ulib \
        --enable-shared \
        --enable-optimizations \
        --with-lto && \
    make clean && \
    make && \
    make install && \
    ldconfig

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

# Install Vim
ARG VIM_VERSION=9.1.0193
ARG VIM_SHA256=895833fa1b5a08cc7c33589c00b5e0c3198d525768944e729d3b89574bebc727
RUN mkdir -p /install/vim && \
    cd /install/vim && \
    curl -fsSOL https://github.com/vim/vim/archive/refs/tags/v${VIM_VERSION}.tar.gz && \
    echo "${VIM_SHA256}  v${VIM_VERSION}.tar.gz" | sha256sum -c && \
    tar xzf v${VIM_VERSION}.tar.gz && \
    cd vim-${VIM_VERSION} && \
    ./configure \
        --prefix=/usr/local/ulib \
        --with-features=huge \
        --with-python3-command=/usr/local/ulib/bin/python${PYTHON_VERSION} \
        --enable-multibyte \
        --enable-luainterp=yes \
        --enable-perlinterp=yes \
        --enable-python3interp=yes \
        --enable-rubyinterp=yes \
        --enable-cscope \
        LDFLAGS="-L/usr/local/ulib/lib" && \
    make && \
    make install && \
    ldconfig

# Install libevent
ARG LIBEVENT_VERSION=2.1.12-stable
RUN mkdir -p /install/libevent && \
    cd /install/libevent && \
    curl -fsSOL https://github.com/libevent/libevent/releases/download/release-${LIBEVENT_VERSION}/libevent-${LIBEVENT_VERSION}.tar.gz && \
    curl -fsSOL https://github.com/libevent/libevent/releases/download/release-${LIBEVENT_VERSION}/libevent-${LIBEVENT_VERSION}.tar.gz.asc && \
    curl -fsSL https://azat.sh/azatpub.asc | /usr/local/ulib/bin/gpg --import && \
    /usr/local/ulib/bin/gpg --verify libevent-${LIBEVENT_VERSION}.tar.gz.asc && \
    tar xzf libevent-${LIBEVENT_VERSION}.tar.gz && \
    cd libevent-${LIBEVENT_VERSION} && \
    mkdir build && \
    cd build && \
    /usr/local/ulib/bin/cmake -DCMAKE_INSTALL_PREFIX=/usr/local/ulib .. && \
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
    /usr/local/ulib/bin/gpg --verify --keyring ./gnu-keyring.gpg gdb-${GDB_VERSION}.tar.xz.sig && \
    tar xf gdb-${GDB_VERSION}.tar.xz && \
    cd gdb-${GDB_VERSION} && \
    ./configure \
        --prefix=/usr/local/ulib \
        --with-python=/usr/local/ulib/bin/python${PYTHON_VERSION} \
        --enable-lto \
        LDFLAGS="-L/usr/local/ulib/lib" && \
    make && \
    make install && \
    ldconfig


FROM base

# Copy built software from builder
COPY --from=builder /usr/local/ulib /usr/local/ulib
RUN ldconfig

RUN apt-get install -y \
        libfontconfig \
        libxt6 \
        ninja-build

RUN update-alternatives \
        --install /usr/bin/gcc gcc /usr/bin/gcc-${GCC_VERSION} ${GCC_VERSION} \
        --slave /usr/bin/g++ g++ /usr/bin/g++-${GCC_VERSION} \
        --slave /usr/bin/gcov gcov /usr/bin/gcov-${GCC_VERSION}

# Install Docker client
RUN install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | /usr/local/ulib/bin/gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    chmod a+r /etc/apt/keyrings/docker.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] " \
        "https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo ${VERSION_CODENAME}) stable" | \
        tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update && \
    apt-get install -y docker-ce-cli

# Install Docker Compose
ARG DOCKER_COMPOSE_VERSION=2.25.0
RUN mkdir -p /usr/local/lib/docker/cli-plugins && \
    curl -fsSL "https://github.com/docker/compose/releases/download/v$DOCKER_COMPOSE_VERSION/docker-compose-$(uname -s)-$(uname -m)" \
        -o /usr/local/lib/docker/cli-plugins/docker-compose && \
    chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

# Install pip
ARG PYTHON_VERSION
RUN curl -fsSL https://bootstrap.pypa.io/get-pip.py -o /tmp/get-pip.py && \
    /usr/local/ulib/bin/python${PYTHON_VERSION} /tmp/get-pip.py && \
    /usr/local/ulib/bin/python${PYTHON_VERSION} -m pip install --upgrade pip setuptools wheel

# Setup sshd_config
COPY xenial/sshd_config.patch .
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
RUN /usr/local/ulib/bin/python${PYTHON_VERSION} -m pip install --upgrade pip setuptools wheel && \
    /usr/local/ulib/bin/python${PYTHON_VERSION} -m pip install powerline-status virtualenvwrapper

# Install Oh My Zsh
COPY --chown=ubuntu common/zsh/.zshrc .zshrc.bk
COPY --chown=ubuntu common/zsh/.p10k.zsh .
RUN echo -e "y" | sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" && \
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-.oh-my-zsh/custom}/plugins/zsh-autosuggestions && \
    git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:-.oh-my-zsh/custom}/plugins/zsh-completions && \
    git clone https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM:-.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting && \
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k && \
    echo "ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=60'" >> ${ZSH_CUSTOM:-.oh-my-zsh/custom}/zsh-autosuggestions_custom.zsh && \
    sed -i "s/bin\/python\$PYTHON_VERSION/local\/ulib\/bin\/python${PYTHON_VERSION}/g" .zshrc.bk && \
    mv .zshrc.bk .zshrc

# Swtich to Zsh
COPY xenial/.profile.patch .
RUN patch -p0 < .profile.patch && \
    rm .profile.patch

# Configure Vim
RUN mkdir -p .vim/colors
COPY --chown=ubuntu common/vim/darcula.vim .vim/colors
COPY --chown=ubuntu common/vim/.vimrc .
RUN sed -i "s/lib\/python\$PYTHON_VERSION\/site/lib\/python${PYTHON_VERSION}\/site/g" .vimrc && \
    sed -i "s/bin\/python\$PYTHON_VERSION/local\/ulib\/bin\/python${PYTHON_VERSION}/g" .vimrc && \
    git clone https://github.com/VundleVim/Vundle.vim.git .vim/bundle/Vundle.vim && \
    /usr/local/ulib/bin/vim +PluginInstall +qall > /dev/null && \
    PATH="/usr/local/ulib/bin:${PATH}" python${PYTHON_VERSION} .vim/bundle/YouCompleteMe/install.py --clang-completer && \
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
    ln -s .config/v2ray/geosite.dat .config/v2ray/LoyalsoldierSite.dat

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
