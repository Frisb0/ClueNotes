import 'package:flutter/material.dart';

class ClueCharacter {
  final String name;
  final Color color;

  const ClueCharacter(this.name, this.color);
}

const List<ClueCharacter> cluePalette = [
  ClueCharacter("Sr. Verduzco", Color(0xFF4CAF50)),
  ClueCharacter("Coronel Mostaza", Color(0xFFFFD700)),
  ClueCharacter("Sra. Marlene", Color(0xFF2196F3)),
  ClueCharacter("Prof. Moradillo", Color(0xFFD15DFF)),
  ClueCharacter("Srta. Escarlata", Color(0xFFFF5252)),
  ClueCharacter("Sra. Blanca", Color(0xFFFFFFFF)),
];
