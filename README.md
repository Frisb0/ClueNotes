# 🔍 Clue Notes - Detective Digital

**Clue Notes** es una aplicación de asistencia para el juego de mesa **Clue** (o Cluedo). Diseñada originalmente en Kotlin nativo y ahora reconstruida por completo en **Flutter**, esta herramienta reemplaza la libreta de papel tradicional, permitiéndote llevar un registro impecable de las pistas, sospechosos, armas y lugares de forma rápida, privada y eficiente.

¡Optimiza tus deducciones y conviértete en el mejor detective de la partida con un código base multiplataforma moderno!

<img width="200" height="600" alt="image" src="https://github.com/user-attachments/assets/231bf118-d1eb-4403-86b6-99367c04c8b7" />
<img width="200" height="600" alt="image" src="https://github.com/user-attachments/assets/06c9c2c2-d18c-4286-80c3-d0c51f318c88" />
<img width="200" height="600" alt="image" src="https://github.com/user-attachments/assets/1bc4baba-1aa7-4501-b41a-d8d8dd872fd8" />
<img width="200" height="600" alt="image" src="https://github.com/user-attachments/assets/63dd3468-88b7-427a-b290-e8bb6cc7a839" />

---

## ✨ Características Principales

* **Estructura Multiplataforma:** Reconstruida desde cero en **Flutter** para un rendimiento fluido y la posibilidad de desplegar en Android y iOS sin esfuerzo.
* **Gestión Dinámica:** Configuración rápida para partidas adaptables de **3 a 6 jugadores** (incluyéndote a ti).
* **Interfaz Inteligente y Colapsable:** Agrupa las secciones por acordeón (*¿Quién fue?, ¿Con qué?, ¿Dónde?*) para maximizar el espacio en pantalla.
* **Sistema de Descarte Avanzado:** Registra cartas propias en mano, marcas de descarte instantáneo (X), notas temporales de sospechas (?) y confirmaciones del veredicto (✔) representadas con iconos vectoriales dinámicos.
* **Lógica de Deducción (Alta Probabilidad):** Alertas con icono de rayo (⚡) cuando el sistema calcula que un ítem tiene una alta probabilidad de ser la carta oculta en el sobre del asesino.
* **Veredicto Rápido:** Consulta de inmediato el estado resumido del crimen usando el botón flotante del Mazo de Juez.
* **Estilo Inmersivo y Personalizado:** Interfaz adaptada a un elegante modo oscuro (Dark Mode). El color de acento de toda la interfaz y los botones cambia dinámicamente según el sospechoso clásico que elijas representar (Sr. Verduzco, Coronel Mostaza, Srta. Escarlata, etc.).
* **Mantener Pantalla Activa:** Integración a nivel de sistema para prevenir el bloqueo de pantalla mientras juegas, garantizando que el tablero táctico esté siempre visible.

---

## 🛠️ Tecnologías y Arquitectura

El proyecto sigue una arquitectura limpia que separa de forma ordenada los modelos lógicos, los componentes visuales y el flujo de estados reactivos.

* **SDK:** Flutter
* **Lenguaje:** Dart 
* **Compatibilidad:** Android API 21+ (Android 5.0 en adelante).
