# 🌙 Dark Mode

AutoCare soporta **Dark Mode** completo con sincronización automática.

## Características

✅ Tema claro y oscuro
✅ Persistencia de preferencias
✅ Cambio de tema en tiempo de ejecución
✅ Colores optimizados para OLED
✅ Botón de alternancia en AppBar

## Estructura

```
lib/
├── services/
│   └── theme_service.dart       # Gestión de temas
├── providers/
│   └── theme_provider.dart      # Estado del tema
└── themes/
    └── app_themes.dart          # Definición de temas
```

## Cómo Usar

### Cambiar Tema Programáticamente

```dart
// Acceder al ThemeProvider
final themeProvider = widget.themeProvider;

// Cambiar a Oscuro
await themeProvider.setTheme(ThemeMode.dark);

// Cambiar a Claro
await themeProvider.setTheme(ThemeMode.light);

// Alternar
themeProvider.toggleTheme();
```

### En Widgets

```dart
// Verificar si está en modo oscuro
if (widget.themeProvider?.isDarkMode ?? false) {
  // Usa colores para tema oscuro
}

// Usar el tema actual automáticamente
Text(context.l10n.appName) // Usa colores del tema actual
```

## Colores del Tema

### Light Theme
- **Fondo:** Blanco (#FFFFFF)
- **Primario:** Azul (#1A73E8)
- **Tarjetas:** Blanco (#FFFFFF)
- **Texto:** Gris oscuro (#202124)

### Dark Theme
- **Fondo:** Casi negro (#121212)
- **Primario:** Azul (#1A73E8)
- **Tarjetas:** Gris oscuro (#1E1E1E)
- **Texto:** Blanco (#FFFFFF)

## Persistencia

El tema seleccionado se guarda automáticamente en `SharedPreferences` con la clave `theme_mode`.

```dart
// Automáticamente guardado
await themeProvider.setTheme(ThemeMode.dark);

// Restaurado al iniciar la app
```

## Modos Disponibles

| Modo | Código | Comportamiento |
|------|--------|----------------|
| **Claro** | `ThemeMode.light` | Siempre claro |
| **Oscuro** | `ThemeMode.dark` | Siempre oscuro |
| **Sistema** | `ThemeMode.system` | Sigue configuración del dispositivo |

## Botón de Tema

El AppBar en HomeScreen incluye un botón para cambiar el tema:

```dart
IconButton(
  icon: isDarkMode ? Icon(Icons.light_mode) : Icon(Icons.dark_mode),
  onPressed: themeProvider.toggleTheme,
  tooltip: 'Cambiar Tema',
)
```

## Accesibilidad

- ✅ Alto contraste en ambos temas
- ✅ Legible en diferentes condiciones de luz
- ✅ Transiciones suaves entre temas
- ✅ Iconos claros y consistentes

## Personalización

Para modificar los colores del tema, edita `lib/themes/app_themes.dart`:

```dart
static const Color _primaryColor = Color(0xFF1A73E8); // Cambiar color primario

static ThemeData get lightTheme {
  return ThemeData(
    // Personalizar colores
  );
}
```

## Próximas Mejoras

- [ ] Selector de temas en Settings
- [ ] Temas personalizados (user-defined colors)
- [ ] Animaciones de transición suaves
- [ ] Tema "Automático" basado en hora del día

EOF
