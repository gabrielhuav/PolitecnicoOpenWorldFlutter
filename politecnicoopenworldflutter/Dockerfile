# Usar una imagen oficial de Ubuntu como base para instalar Flutter
FROM ubuntu:20.04

# Prevenir interacciones durante la instalación de paquetes
ENV DEBIAN_FRONTEND=noninteractive

# Instalar dependencias necesarias
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    openjdk-11-jdk \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Configurar variables de entorno para Flutter
ENV FLUTTER_HOME=/opt/flutter
ENV PATH=${FLUTTER_HOME}/bin:${PATH}

# Descargar e instalar Flutter (versión estable)
RUN git clone https://github.com/flutter/flutter.git -b stable ${FLUTTER_HOME}

# Ejecutar flutter doctor para descargar dependencias adicionales del SDK
RUN flutter doctor

# Crear el directorio de trabajo
WORKDIR /app

# Copiar los archivos del proyecto al contenedor
COPY . .

# Obtener las dependencias de Flutter
RUN flutter pub get

# Comando por defecto (puedes cambiarlo para construir web o apk)
CMD ["flutter", "test"]
