FROM debian:bullseye
WORKDIR /opt
ENV DEBIAN_FRONTEND=noninteractive

RUN sed -i 's/# deb-src/deb-src/' /etc/apt/sources.list &&\
    apt-get update &&\
    apt-get install --yes --no-install-recommends auto-apt-proxy &&\
    echo "192.168.0.100 apt-proxy" >> /etc/hosts &&\
    apt-get install --yes --no-install-recommends  \
    apt-transport-https\
    autoconf \
    build-essential \
    ca-certificates\
    git \
    libacl1-dev \
    libasound2-dev \
    libdbus-1-dev \
    libgccjit-10-dev \
    libgif-dev \
    libgnutls28-dev \
    libgpm-dev \
    libgtk-3-dev \
    libwebkit2gtk-4.0-dev \
    libjansson-dev \
    libjbig-dev \
    libjpeg-dev \
    libjpeg62-turbo-dev \
    liblcms2-dev\
    liblockfile-dev \
    libm17n-dev \
    libncurses-dev\
    libotf-dev \
    libpng-dev \
    librsvg2-dev  \
    libsystemd-dev \
    libtiff-dev \
    libxml2-dev \
    libxpm-dev \
    pkg-config \
    texinfo

RUN update-ca-certificates

# Clone emacs
COPY emacs emacs

# Build
ENV CC="gcc-10"
RUN cd emacs &&\
    ./autogen.sh &&\
    ./configure \
    --prefix "/usr" \
    --with-native-compilation \
    --with-pgtk \
    --with-xwidgets \
    --with-json \
    --with-gnutls \
    --with-dbus \
    --with-gif \
    --with-jpeg \
    --with-png \
    --with-rsvg \
    --with-tiff \
    --with-xft \
    --with-xpm \
    --with-modules \
    --with-mailutils \
    --without-xaw3d \
    --with-xinput2 \
    CFLAGS="-O2 -pipe -fomit-frame-pointer"

RUN make -C emacs NATIVE_FULL_AOT=1 -j $(nproc)

# Create package
RUN EMACS_GIT_VERSION=$(git -C ./emacs rev-parse --short HEAD) \
    EMACS_VERSION=$(sed -ne 's/AC_INIT(\[GNU Emacs\], \[\([0-9.]\+\)\], .*/\1/p' ./emacs/configure.ac) \
    PKG_NAME=/opt/emacs-pgtk_${EMACS_VERSION}.${EMACS_GIT_VERSION} \
    BINARIES=${PKG_NAME}/usr/bin \
    SHLIBS=${PKG_NAME}/usr/lib/emacs/${EMACS_VERSION}/native-lisp &&\
    cd emacs &&\
    make install prefix=${PKG_NAME}/usr &&\
    for i in ${BINARIES}/*; do strip --strip-unneeded --remove-section=.comment --remove-section=.note ${i}; done &&\
    for i in ${SHLIBS}/*/*.eln; do strip --strip-unneeded --remove-section=.comment --remove-section=.note ${i}; done &&\
    strip --strip-unneeded --remove-section=.comment --remove-section=.note ${PKG_NAME}/usr/libexec/emacs/${EMACS_VERSION}/x86_64-pc-linux-gnu/hexl &&\
    mkdir ${PKG_NAME}/DEBIAN &&\
    rm ${PKG_NAME}/usr/share/glib-2.0/schemas/gschemas.compiled &&\
    rm ${PKG_NAME}/usr/share/info/dir &&\
    echo "Format: http://www.debian.org/doc/packaging-manuals/copyright-format/1.0/\n\
Upstream-Name: Emacs\n\
Source: https://www.gnu.org/software/emacs/\n\n\
Files: *\n\
Copyright: Copyright Free Software Foundation, Inc.\n\
License: GPL-3" \
    > ${PKG_NAME}/DEBIAN/copyright &&\
    echo "Package: emacs-pgtk\n\
Source: emacs\n\
Version: ${EMACS_VERSION}.${EMACS_GIT_VERSION}-1\n\
Architecture: amd64\n\
Maintainer: ndrvtl <7734025+ndrvtl@users.noreply.github.com>\n\
Depends: libacl1, libc6, libdbus-1-3, libgccjit0, libgif7, libgtk-3-0, libjansson4, libjpeg62-turbo, libm17n-0, libotf0, librsvg2-2, libtiff5\n\
Section: editors\n\
Priority: optional\n\
Homepage: https://www.gnu.org/software/emacs/\n\
Description: Emacs with pure GTK support.\n\
 Compilation options:\n\
 --with-native-compilation \n\
 --with-pgtk \n\
 --with-xwidgets \n\
 --with-json \n\
 --with-gnutls \n\
 --with-dbus \n\
 --with-gif \n\
 --with-jpeg \n\
 --with-png \n\
 --with-rsvg \n\
 --with-tiff \n\
 --with-xft \n\
 --with-xpm \n\
 --with-modules \n\
 --with-mailutils \n\
 --without-xaw3d \n\
 CFLAGS=\"-O2 -pipe -fomit-frame-pointer\"" > ${PKG_NAME}/DEBIAN/control &&\
    dpkg-deb --build ${PKG_NAME} &&\
    mkdir /opt/packages &&\
    mv ${PKG_NAME}.deb /opt/packages/emacs-pgtk_${EMACS_VERSION}.${EMACS_GIT_VERSION}-1.deb
