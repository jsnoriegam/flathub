FROM fedora:39

# Instalar flatpak-builder y dependencias
RUN dnf install -y \
    flatpak flatpak-builder \
    git \
    wget \
    ostree \
    appstream \
    desktop-file-utils \
    libappstream-glib \
    && dnf clean all

# Configurar Flatpak
ENV XDG_DATA_HOME=/var/lib/flatpak
RUN mkdir -p $XDG_DATA_HOME

# Añadir repositorio de Flathub
RUN flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Instalar SDKs y Runtimes necesarios
# IMPORTANTE: Estos deben coincidir con tu manifest
RUN flatpak install -y --noninteractive flathub \
    org.gnome.Platform//48 \
    org.gnome.Sdk//48 \
    org.freedesktop.Sdk.Extension.rust-stable//23.08

# Crear usuario no-root para el build (más seguro)
RUN useradd -m -u 1000 builder && \
    mkdir -p /build /output && \
    chown -R builder:builder /build /output /var/lib/flatpak

USER builder
WORKDIR /build

# Script de construcción
COPY --chown=builder:builder docker/build_flatpak.sh /build/
RUN chmod +x /build/build_flatpak.sh

ENTRYPOINT ["/build/build_flatpak.sh"]