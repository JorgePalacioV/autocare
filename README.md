# 🚗 AutoCare - Sistema de Gestión de Mantenimiento Vehicular

> Una aplicación Flutter completa para gestionar el mantenimiento de vehículos, conductores y generar reportes profesionales.

[![Flutter](https://img.shields.io/badge/Flutter-3.13+-blue.svg)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Latest-orange.svg)](https://firebase.google.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## 📱 Características Principales

### 🚙 Gestión de Vehículos
- ✅ Crear, editar y eliminar múltiples vehículos
- ✅ Almacenar foto de cada vehículo
- ✅ Rastrear año, placa y kilometraje actual
- ✅ Estadísticas personalizadas por vehículo
- ✅ Búsqueda en tiempo real

### 🔧 Registro de Mantenimientos
- ✅ Registrar mantenimientos por tipo
- ✅ Rastrear km, costo, taller y notas
- ✅ Historial completo con filtros
- ✅ Búsqueda avanzada por fecha, costo y tipo
- ✅ Ver detalles de cada mantenimiento

### 👨‍✔️ Gestión de Conductores
- ✅ Crear perfiles de conductores
- ✅ Foto del conductor y licencia
- ✅ Rastrear vencimiento de licencia
- ✅ Alertas de licencia expirada
- ✅ Asignar conductores a vehículos

### ⏰ Alertas y Recordatorios
- ✅ Configurar intervalos de mantenimiento (km/días)
- ✅ Monitorear estado de alertas
- ✅ Indicadores visuales (verde/amarillo/rojo)
- ✅ Notificaciones automáticas

### 📊 Dashboard y Reportes
- ✅ Estadísticas agregadas de toda la flota
- ✅ Generar reportes PDF personalizados
- ✅ Filtrar por período de tiempo
- ✅ Compartir e imprimir reportes
- ✅ Visualización de costos por tipo

### 👤 Gestión de Perfil
- ✅ Editar datos personales
- ✅ Ver información de membresía
- ✅ Teléfono y email configurables
- ✅ Sesión segura con Firebase Auth

---

## 🚀 Inicio Rápido

### Requisitos Previos
```bash
- Flutter 3.13+
- Dart 3.1+
- Firebase CLI
- Android Studio / Xcode (para emulador)
```

### Instalación

1. **Clonar el repositorio**
```bash
git clone https://github.com/JorgePalacioV/autocare.git
cd autocare
```

2. **Instalar dependencias**
```bash
flutter pub get
```

3. **Configurar Firebase**
- Crear proyecto en Firebase Console
- Descargar google-services.json para Android
- Configurar Firestore, Auth y Storage

4. **Ejecutar la aplicación**
```bash
flutter run
```

---

## 📁 Estructura del Proyecto

```
autocare/
├── lib/
│   ├── models/              # Modelos de datos
│   ├── screens/            # Pantallas de la app
│   ├── services/           # Servicios (Firebase)
│   ├── widgets/            # Componentes reutilizables
│   ├── utils/              # Utilidades
│   └── main.dart
├── pubspec.yaml
└── README.md
```

---

## 🛠️ Tecnologías Usadas

- **Flutter** - Framework UI multiplataforma
- **Firebase** - Backend y autenticación
- **Firestore** - Base de datos en tiempo real
- **PDF** - Generación de reportes

---

## 📧 Contacto

**Jorge Palacios**
- GitHub: [@JorgePalacioV](https://github.com/JorgePalacioV)
- Email: jpalaciovillamizar@gmail.com

---

**Desarrollado con ❤️ por Jorge Palacios**
