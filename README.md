# Politécnico Open World (POW) - Flutter Edition

Este repositorio contiene la implementación en Flutter del proyecto Politécnico Open World. El sistema simula un entorno de mundo abierto en 2D, y esta versión está orientada principalmente al despliegue y ejecución en dispositivos iOS.

## Arquitectura del Proyecto

El desarrollo se enfoca en una arquitectura modular y escalable. El objetivo principal es mantener una separación estricta entre la interfaz de usuario, la lógica de simulación del mapa/entorno y el acceso a los datos. 

La estructura del código base prioriza:
* **Separación de responsabilidades:** Para aislar la lógica de los NPCs, el renderizado del mapa y los controles del jugador.
* **Gestión de estado predecible:** Para manejar los eventos de la interfaz y la sincronización de la simulación en tiempo real sin acoplamiento fuerte.

## Requisitos Previos

* [Flutter SDK](https://docs.flutter.dev/get-started/install)
* Xcode (obligatorio para la compilación y simulación en iOS)
* CocoaPods (para la gestión de dependencias nativas de iOS)

## Configuración y Ejecución

1. Clona el repositorio:
   ```bash
   git clone <URL_DEL_REPOSITORIO>