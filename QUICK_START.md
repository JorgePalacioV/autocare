# ⚡ Guía de Inicio Rápido - AutoCare

Sigue estos pasos para ejecutar la app en **5 minutos** con Firebase Emulators.

---

## 1️⃣ Requisitos (instalar una sola vez)

```bash
# Instalar Firebase CLI globalmente
npm install -g firebase-tools

# Verificar que funciona
firebase --version
flutter --version
```

---

## 2️⃣ Preparar el proyecto

```bash
cd /Users/jorgepalacio/Documentos/autocare
flutter pub get
```

---

## 3️⃣ Abrir 3 terminales

### Terminal 1: Firebase Emulators
```bash
cd /Users/jorgepalacio/Documentos/autocare
firebase emulators:start --only auth,firestore
```

Espera a ver:
```
✓  Auth emulator started at http://127.0.0.1:9099
✓  Firestore emulator started at http://127.0.0.1:8080
✓  Emulator UI available at http://localhost:4000
```

### Terminal 2: Android Emulator
```bash
# Opción A: Desde línea de comandos
emulator -avd Pixel_4_API_31

# Opción B: Desde Android Studio
# Tools → Device Manager → Play
```

### Terminal 3: Ejecutar Flutter
```bash
cd /Users/jorgepalacio/Documentos/autocare
flutter run
```

---

## 4️⃣ Probar la app

1. Abre la app en el emulador
2. Toca **"Crear Cuenta"**
3. Completa el formulario:
   - **Nombre:** `juan`
   - **Email:** `test@demo.com`
   - **Contraseña:** `123456`
4. Toca **"Crear Cuenta"**

**¡Listo!** Deberías ver la HomeScreen con "¡Bienvenido, juan! 👋"

---

## 5️⃣ Ver datos en Firebase

Abre tu navegador en: **http://localhost:4000**

Verás:
- **Authentication** → El usuario que acabas de crear
- **Firestore** → Colección `users` con los datos

---

## 🛑 Detener todo

1. Cierra el emulador de Android (o presiona Ctrl+C en Terminal 2)
2. Presiona Ctrl+C en Terminal 3 (Flutter)
3. Presiona Ctrl+C en Terminal 1 (Firebase)

---

## 🔧 Problemas comunes

| Problema | Solución |
|----------|----------|
| "Cleartext HTTP traffic" | Ejecuta `flutter clean && flutter run` |
| "Firebase Emulator not running" | Verifica que Terminal 1 muestre los logs de emuladores |
| "Emulator won't start" | Abre Android Studio → Device Manager → Play |
| "Can't connect to localhost" | Asegúrate de estar en la misma red WiFi o usando localhost |

---

## 💡 Tips

- **Hot reload** funciona: Cambia código en `lib/` y presiona `r` en Terminal 3
- **Ver logs:** `adb logcat | grep flutter`
- **Resetear datos:** Detén los emuladores y ejecuta de nuevo
- **Ver Firebase UI:** http://localhost:4000 (mientras emulators esté corriendo)

---

## ✅ Checklist

- [ ] Firebase CLI instalado (`firebase --version`)
- [ ] Flutter instalado (`flutter --version`)
- [ ] Android SDK instalado (`flutter doctor`)
- [ ] Firebase emulators corriendo en Terminal 1
- [ ] Android emulador corriendo en Terminal 2
- [ ] App corriendo en Terminal 3
- [ ] Cuenta de prueba creada exitosamente
- [ ] HomeScreen visible en emulador

---

**Listo para desarrollar! 🚀**

Para más detalles, lee [README.md](./README.md)
