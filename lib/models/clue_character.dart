import 'package:flutter/material.dart';

/// Modelo de datos inmutable que representa a un personaje del juego Clue.
/// Asocia el nombre del sospechoso con su color característico dentro de la app.
class ClueCharacter {
  final String name;  // Nombre visible del personaje
  final Color color;  // Color temático asociado para resaltar la UI.

  // Constructor constante para permitir instanciar objetos inmutables en tiempo de compilación.
  const ClueCharacter(this.name, this.color);
}

/// Paleta de colores y personajes predeterminados del Clue clásico.
/// Se utiliza globalmente para la selección de personaje activo y la temática de color.
const List<ClueCharacter> cluePalette = [
  ClueCharacter("Sr. Verduzco", Color(0xFF4CAF50)),    // Verde
  ClueCharacter("Coronel Mostaza", Color(0xFFFFD700)), // Amarillo
  ClueCharacter("Sra. Marlene", Color(0xFF2196F3)),    // Azul
  ClueCharacter("Prof. Moradillo", Color(0xFFD15DFF)), // Morado
  ClueCharacter("Srta. Escarlata", Color(0xFFFF5252)), // Rojo
  ClueCharacter("Sra. Blanca", Color(0xFFFFFFFF)),    // Blanco
];