# 📚 Índice de Documentación - AutoCare

## Para principiantes
1. **[README.md](../README.md)** - Comienza aquí. Visión general del proyecto
2. **[DEVELOPMENT.md](./DEVELOPMENT.md)** - Guía paso a paso para desarrolladores

## Para entender la arquitectura
3. **[ARCHITECTURE.md](./ARCHITECTURE.md)** - Patrones, capas, flujo de datos
4. **[MODELS.md](./MODELS.md)** - Especificación detallada de modelos

## Para usar la API
5. **[FIREBASE_API.md](./FIREBASE_API.md)** - Documentación de cada método del FirebaseService

---

## 📖 Lectura rápida

### "¿Qué hace esta app?"
→ [README.md](../README.md) - Sección Características

### "¿Cómo está estructurada?"
→ [ARCHITECTURE.md](./ARCHITECTURE.md) - Sección Visión General

### "¿Cuáles son los modelos?"
→ [MODELS.md](./MODELS.md) - Tablas de campos y validaciones

### "¿Cómo uso FirebaseService?"
→ [FIREBASE_API.md](./FIREBASE_API.md) - Ejemplos de código

### "¿Cómo agrego una pantalla nueva?"
→ [DEVELOPMENT.md](./DEVELOPMENT.md) - Sección Estructura para nueva pantalla

### "¿Cómo arreglo un error?"
→ [DEVELOPMENT.md](./DEVELOPMENT.md) - Sección Debugging

---

## 📁 Estructura de archivos documentados

```
/Users/jorgepalacio/Documentos/autocare/
├── README.md                 ← EMPIEZA AQUÍ
├── docs/
│   ├── INDEX.md             ← ESTÁS AQUÍ
│   ├── ARCHITECTURE.md       ← Cómo está hecha
│   ├── MODELS.md            ← Qué datos hay
│   ├── FIREBASE_API.md      ← Cómo usar Firebase
│   └── DEVELOPMENT.md       ← Cómo desarrollar
├── lib/
│   ├── main.dart            ← App + UI inicial
│   ├── models/
│   │   ├── user.dart        ← Modelo AppUser
│   │   ├── vehicle.dart     ← Modelo Vehicle
│   │   ├── maintenance.dart ← Modelo Maintenance
│   │   └── models.dart      ← Exports
│   ├── services/
│   │   ├── firebase_service.dart  ← 30+ métodos
│   │   └── logger.dart            ← Sistema de logs
│   ├── screens/             ← (Por llenar Fase 2+)
│   ├── widgets/             ← (Por llenar)
│   └── utils/               ← (Por llenar)
└── pubspec.yaml             ← Dependencias
```

---

## 🎓 Learning Path

### Nivel 1: Usuario Final
1. Lee README.md
2. Ejecuta la app
3. Prueba el login (Fase 2)

### Nivel 2: Principiante Developer
1. Lee DEVELOPMENT.md
2. Lee ARCHITECTURE.md
3. Crea una pantalla simple

### Nivel 3: Intermediate
1. Estudia MODELS.md
2. Estudia FIREBASE_API.md
3. Agrega nuevos métodos al FirebaseService

### Nivel 4: Advanced
1. Implementa caché local
2. Agrega sincronización offline
3. Optimiza performance

---

## 🔍 Buscar por tema

### Autenticación
- Flujo → [ARCHITECTURE.md - Flujo de Datos](./ARCHITECTURE.md#-flujo-de-datos)
- Métodos → [FIREBASE_API.md - Autenticación](./FIREBASE_API.md#-autenticación)
- Screens → [DEVELOPMENT.md - Checklist Fase 2](./DEVELOPMENT.md#-checklist-para-fase-2-autenticación)

### Vehículos
- Modelo → [MODELS.md - Vehicle](./MODELS.md#vehicle-vehículo)
- API → [FIREBASE_API.md - Vehículos](./FIREBASE_API.md#-vehículos)
- Relaciones → [MODELS.md - Relaciones](./MODELS.md#relaciones)

### Mantenimientos
- Modelo → [MODELS.md - Maintenance](./MODELS.md#maintenance-mantenimiento)
- API → [FIREBASE_API.md - Mantenimientos](./FIREBASE_API.md#-mantenimientos)
- Estadísticas → [FIREBASE_API.md - Estadísticas](./FIREBASE_API.md#-estadísticas)

### Errores y Debugging
- Manejo → [FIREBASE_API.md - Manejo de Errores](./FIREBASE_API.md#-manejo-de-errores)
- Debugging → [DEVELOPMENT.md - Debugging](./DEVELOPMENT.md#-debugging)
- Logger → [FIREBASE_API.md - Logging](./FIREBASE_API.md#-logging)

### Performance y Escalabilidad
- Decisiones → [ARCHITECTURE.md - Decisiones de Diseño](./ARCHITECTURE.md#-decisiones-de-diseño)
- Mejoras → [DEVELOPMENT.md - Performance](./DEVELOPMENT.md#-performance)

---

## 🚀 Flujos comunes de trabajo

### "Voy a hacer la pantalla de Login"
1. Lee [DEVELOPMENT.md - Estructura para nueva pantalla](./DEVELOPMENT.md#-estructura-para-nueva-pantalla)
2. Consulta [FIREBASE_API.md - signIn()](./FIREBASE_API.md#signin)
3. Revisa [DEVELOPMENT.md - Componentes reutilizables](./DEVELOPMENT.md#-componentes-reutilizables)

### "Necesito agregar un nuevo modelo"
1. Lee [MODELS.md - Crear Nuevo Modelo](./MODELS.md#crear-nuevo-modelo)
2. Revisa ejemplos en [MODELS.md - AppUser](./MODELS.md#appuser-usuario)
3. Documenta en [MODELS.md](./MODELS.md) y [FIREBASE_API.md](./FIREBASE_API.md)

### "Quiero agregar datos en tiempo real"
1. Lee [ARCHITECTURE.md - Flujo de Datos](./ARCHITECTURE.md#-flujo-de-datos)
2. Busca método Stream en [FIREBASE_API.md](./FIREBASE_API.md)
3. Revisa ejemplo de StreamBuilder en [DEVELOPMENT.md](./DEVELOPMENT.md#-buenas-prácticas)

### "Tengo un error"
1. Lee el mensaje de error cuidadosamente
2. Revisa [FIREBASE_API.md - Manejo de Errores](./FIREBASE_API.md#-manejo-de-errores)
3. Mira los logs: [DEVELOPMENT.md - Debugging](./DEVELOPMENT.md#-debugging)
4. Revisa ejemplos en [FIREBASE_API.md](./FIREBASE_API.md)

---

## 📊 Estado de la documentación

| Documento | Completitud | Última actualización |
|-----------|-------------|-------------------|
| README.md | 100% | 2026-09-10 |
| ARCHITECTURE.md | 100% | 2026-09-10 |
| MODELS.md | 100% | 2026-09-10 |
| FIREBASE_API.md | 100% | 2026-09-10 |
| DEVELOPMENT.md | 90% | 2026-09-10 |
| INDEX.md | 100% | 2026-09-10 |

### Qué falta documentar (después de Fase 2)
- Screens de vehículos
- Screens de mantenimientos
- Sistema de reportes
- Sincronización offline

---

## 💡 Tips para usar esta documentación

### Busca por problema
- "¿Cómo obtengo un vehículo?" → Busca "getVehicle" en FIREBASE_API.md
- "¿Cuáles son los errores posibles?" → Revisa FIREBASE_API.md sección Errores
- "¿Cómo agrego un getter al modelo?" → Revisa MODELS.md sección Getters

### Usa el Ctrl+F (Find)
- Busca: `class NombreModelo`
- Busca: `def nombreMetodo()`
- Busca: `Ejemplo:` para ver ejemplos de código

### Links internos
- Todos los títulos son clickeables
- `[Link](./archivo.md#sección)` para ir a sección específica

---

## ❓ Preguntas frecuentes

**P: ¿Por dónde empiezo?**  
R: Lee [README.md](../README.md), luego [DEVELOPMENT.md](./DEVELOPMENT.md)

**P: ¿Dónde veo los métodos disponibles?**  
R: [FIREBASE_API.md](./FIREBASE_API.md) - Cada sección tiene los métodos

**P: ¿Cómo defino un modelo nuevo?**  
R: [MODELS.md - Crear Nuevo Modelo](./MODELS.md#crear-nuevo-modelo)

**P: ¿Qué errores puedo esperar?**  
R: [FIREBASE_API.md - Errores comunes](./FIREBASE_API.md#errores-comunes) en cada sección

**P: ¿Cómo debuggeo?**  
R: [DEVELOPMENT.md - Debugging](./DEVELOPMENT.md#-debugging)

---

## 📞 Contacto

**Desarrollador:** Jorge Palacio  
**Email:** jpalaciovillamizar@gmail.com  

Para preguntas sobre la documentación o el código, revisar primero:
1. [INDEX.md](./INDEX.md) (buscar por tema)
2. Ctrl+F en el documento relevante
3. Revisar ejemplos de código

---

**Última actualización:** 2026-09-10  
**Versión del proyecto:** 1.0.0 (Fase 1)
