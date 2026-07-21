# 🔍 Clue Notes - Detective Digital

**Clue Notes** es una aplicación de asistencia para el juego de mesa **Clue** (o Cluedo). Diseñada originalmente en Kotlin nativo y ahora reconstruida por completo en **Flutter**, esta herramienta reemplaza la libreta de papel tradicional, permitiéndote llevar un registro impecable de las pistas, sospechosos, armas y lugares de forma rápida, privada y eficiente.

¡Optimiza tus deducciones y conviértete en el mejor detective de la partida con un código base multiplataforma moderno!

<img width="200" height="400" alt="photo_2026-07-20_23-12-26" src="https://github.com/user-attachments/assets/4142dac7-89da-46e3-afa6-1b1286b31531" />
<img width="200" height="400" alt="photo_2026-07-20_23-12-28" src="https://github.com/user-attachments/assets/724bc9fa-b9fc-4868-8c0d-5f80644b9828" />
<img width="200" height="400" alt="photo_2026-07-20_23-12-29" src="https://github.com/user-attachments/assets/77acfb96-4593-426c-ae0c-6b2a6893a515" />
<img width="200" height="400" alt="photo_2026-07-20_23-12-31" src="https://github.com/user-attachments/assets/627ce0a9-108a-4ac3-a018-bfecbcad84ec" />

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
