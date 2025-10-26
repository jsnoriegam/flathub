[![Buy Me A Coffee](https://img.buymeacoffee.com/button-api/?text=Buy%20me%20a%20coffee&emoji=☕&slug=jsnoriegam&button_colour=FFDD00&font_colour=000000&font_family=Inter&outline_colour=000000&coffee_colour=ffffff)](https://www.buymeacoffee.com/jsnoriegam)

# 🖼️ MultiWall - Multi-Monitor Wallpaper Manager

Una aplicación GTK4 moderna para gestionar fondos de pantalla en configuraciones multi-monitor. Con MultiWall puedes establecer diferentes imágenes para cada monitor con vista previa en tiempo real.

## ✨ Características

- **🖥️ Soporte Multi-Monitor**: Configura fondos diferentes para cada pantalla
- **📁 Galería de Imágenes**: Sidebar con miniaturas para selección rápida
- **🎨 Formatos Soportados**: PNG, JPG, JPEG, BMP, WEBP, GIF, AVIF
- **👁️ Vista Previa en Tiempo Real**: Ve cómo quedará tu configuración antes de aplicarla
- **📐 Múltiples Modos de Visualización**: 
  - ⬜ Rellenar (Fill)
  - 📏 Ajustar (Fit)
  - ↔️ Estirar (Stretch)
  - 🎯 Centrar (Center)
  - 🔲 Mosaico (Tile)
- **🎨 Color de Fondo Personalizado**: Elige el color para áreas no cubiertas
- **💾 Auto-guardado**: Tu configuración se guarda automáticamente
- **🌍 Multi-idioma**: Soporta Español e Inglés

## 🚀 Uso

### Usando el Sidebar de Imágenes

1. El sidebar izquierdo muestra automáticamente las imágenes de tu carpeta de Imágenes/Pictures
2. Haz clic en cualquier miniatura
3. Selecciona el monitor donde quieres aplicar esa imagen
4. La imagen se asignará automáticamente y verás el preview actualizado

### Configuración Manual

1. Haz clic en "📁 Seleccionar imagen..." para cada monitor
2. Elige el modo de visualización que prefieras
3. Ajusta el color de fondo si es necesario
4. Haz clic en "🔄 Actualizar Vista" para ver el preview
5. Haz clic en "✅ Aplicar Fondo" para establecer el wallpaper

### Cambiar Carpeta de Imágenes

- Usa el botón 📁 en el header del sidebar para cambiar a otra carpeta
- Usa el botón 🔄 para refrescar las miniaturas

## 🐳 Ejecución con Docker

### Desarrollo

```bash
# Ejecutar con reconstrucción de imagen
./docker_run.sh --rebuild

# Ejecutar con imagen existente
./docker_run.sh
```

La aplicación se conectará automáticamente a tu entorno gráfico (X11 o Wayland) y tendrá acceso a:
- Tu carpeta de Imágenes/Pictures (solo lectura)
- Tu configuración en `~/.config/multiwall`
- Tu D-Bus session para aplicar el wallpaper

## 📦 Construcción de Paquetes

### Generar AppImage y Flatpak

```bash
# Generar ambos paquetes
./build-packages.sh

# Solo AppImage
./build-packages.sh appimage

# Solo Flatpak
./build-packages.sh flatpak

# Forzar reconstrucción de imágenes Docker
./build-packages.sh rebuild all
```

Los paquetes se generarán en el directorio `dist/`.

### Instalación

**AppImage:**
```bash
chmod +x dist/MultiWall-0.1.0-x86_64.AppImage
./dist/MultiWall-0.1.0-x86_64.AppImage
```

**Flatpak:**
```bash
flatpak install --user dist/MultiWall.flatpak
flatpak run me.latinosoft.MultiWall
```

## 🛠️ Desarrollo

### Requisitos

- Python 3.10+
- GTK4
- PyGObject
- Pillow
- pyyaml
- python-i18n

### Estructura del Proyecto

```
multiwall/
├── multiwall/
│   ├── __init__.py
│   ├── app.py              # Aplicación principal
│   ├── image_sidebar.py    # Sidebar con galería de imágenes
│   ├── monitor_row.py      # Widget de configuración por monitor
│   ├── composer.py         # Compositor de imagen final
│   ├── config.py           # Gestión de configuración
│   ├── utils.py            # Utilidades (conversión PIL->Pixbuf)
│   └── translations/       # Archivos de traducción
│       ├── en.json
│       └── es.json
├── docker/                 # Dockerfiles y scripts de build
├── flatpak/               # Manifiestos y recursos de Flatpak
├── main.py                # Punto de entrada
└── requirements.txt       # Dependencias Python
```

## 📝 Configuración

La configuración se guarda en `~/.config/multiwall/config.json`:

```json
{
  "monitors": {
    "0": {
      "file": "/ruta/a/imagen.jpg",
      "mode": "fill",
      "background": "#000000"
    },
    "1": {
      "file": "/ruta/a/otra_imagen.png",
      "mode": "fit",
      "background": "#1a1a1a"
    }
  },
  "last_directory": "/home/user/Pictures"
}
```

## 🌍 Añadir Nuevos Idiomas

1. Crea un nuevo archivo en `multiwall/translations/` (ej: `fr.json`)
2. Copia la estructura de `en.json` o `es.json`
3. Traduce todas las cadenas
4. La aplicación detectará automáticamente el idioma del sistema

## 🤝 Contribuir

Las contribuciones son bienvenidas! Por favor:

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📄 Licencia

MIT License - Ver el archivo LICENSE para más detalles

## 🙏 Agradecimientos

- GTK Team por el excelente toolkit
- GNOME Project por las librerías y herramientas
- Pillow por el procesamiento de imágenes
- La comunidad de Python

## 🐛 Reportar Problemas

Si encuentras algún problema, por favor abre un issue en GitHub con:
- Descripción del problema
- Pasos para reproducirlo
- Tu sistema operativo y versión
- Logs relevantes

---

Hecho con ❤️ usando GTK4 y Python

