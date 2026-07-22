import 'package:flutter/material.dart';
import '../models/clue_character.dart';
import '../main.dart';

/// PASO 0 DE SETUP: Configuración inicial de la partida (Personaje/Tema y Cantidad de Jugadores).
class StepSelectCount extends StatefulWidget {
  final ClueCharacter selectedChar;                // Personaje actualmente seleccionado.
  final ValueChanged<ClueCharacter> onCharChange; // Callback ejecutado al tocar un círculo de color.
  final ValueChanged<int> onNext;                  // Callback que pasa el total de jugadores al main.dart.

  const StepSelectCount({
    super.key,
    required this.selectedChar,
    required this.onCharChange,
    required this.onNext,
  });

  @override
  State<StepSelectCount> createState() => _StepSelectCountState();
}

class _StepSelectCountState extends State<StepSelectCount> {
  // LÓGICA DE NEGOCIO: Número predeterminado de jugadores (mínimo 3, máximo 6 en el Clue estándar).
  int _count = 4;

  @override
  Widget build(BuildContext context) {
    // `LayoutBuilder` calcula el alto/ancho de la pantalla para evitar que los elementos se corten.
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: ConstrainedBox(
            // Garantiza que la interfaz ocupe al menos el 100% de la altura disponible.
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight, 
            ),
            child: IntrinsicHeight(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center, 
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  // Título principal con el color del personaje activo:
                  Text(
                    "CLUE APP",
                    style: TextStyle(
                      color: widget.selectedChar.color,
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Text(
                    "Selecciona el color de tu personaje",
                    style: TextStyle(color: textPrimary, fontSize: 20),
                  ),
                  const SizedBox(height: 35),

                  // Muestra el nombre del personaje activo (ej: "Sr. Verduzco"):
                  Text(
                    widget.selectedChar.name,
                    style: TextStyle(
                      color: widget.selectedChar.color,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Renderiza la cuadrícula de círculos de colores dividida en filas:
                  ..._buildPaletteRows(),

                  const SizedBox(height: 50),

                  // SECCIÓN: SELECCIÓN DE JUGADORES
                  const Text(
                    "¿CUÁNTOS JUGADORES?",
                    style: TextStyle(color: textPrimary, fontSize: 20, fontWeight: FontWeight.w900),
                  ),
                  const Text(
                    "(Incluyéndote a ti)",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  const SizedBox(height: 15),

                  // CONTADOR INTERACTIVO (+ / -)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Botón Disminuir (-)
                      IconButton.filled(
                        style: IconButton.styleFrom(
                          backgroundColor: surfaceColor,
                          shape: roundedCornerShape(15),
                          fixedSize: const Size(60, 60),
                        ),
                        icon: Text("-", style: TextStyle(fontSize: 30, color: widget.selectedChar.color)),
                        onPressed: () {
                          // LÍMITE INFERIOR: El Clue requiere mínimo 3 jugadores.
                          if (_count > 3) setState(() => _count--);
                        },
                      ),

                      // Valor numérico actual
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40.0),
                        child: Text(
                          "$_count",
                          style: const TextStyle(color: Colors.white, fontSize: 56, fontWeight: FontWeight.w900),
                        ),
                      ),

                      // Botón Aumentar (+)
                      IconButton.filled(
                        style: IconButton.styleFrom(
                          backgroundColor: surfaceColor,
                          shape: roundedCornerShape(15),
                          fixedSize: const Size(60, 60),
                        ),
                        icon: Text("+", style: TextStyle(fontSize: 30, color: widget.selectedChar.color)),
                        onPressed: () {
                          // LÍMITE SUPERIOR: El Clue tradicional permite máximo 6 jugadores.
                          if (_count < 6) setState(() => _count++);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 50),

                  // BOTÓN CONTINUAR
                  SizedBox(
                    width: double.infinity,
                    height: 70,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.selectedChar.color,
                        shape: roundedCornerShape(20),
                      ),
                      // Avanza al paso 1 enviando el total de jugadores seleccionados (`_count`):
                      onPressed: () => widget.onNext(_count),
                      child: Text(
                        "CONTINUAR",
                        style: TextStyle(
                          // CÁLCULO DE CONTRASTE: Alterna el texto entre negro y blanco según la claridad del color del personaje.
                          color: widget.selectedChar.color.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 22,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// HELPER DE MAQUETACIÓN: Divide la paleta global de personajes (`cluePalette`) en filas de 3 columnas.
  List<Widget> _buildPaletteRows() {
    List<Widget> rows = [];
    
    // Recorre el arreglo en bloques de 3 en 3:
    for (int i = 0; i < cluePalette.length; i += 3) {
      final chunk = cluePalette.sublist(i, i + 3 > cluePalette.length ? cluePalette.length : i + 3);
      
      rows.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: chunk.map((char) {
            final isSelected = widget.selectedChar == char; // Comprueba si este círculo es el personaje activo.

            return GestureDetector(
              onTap: () => widget.onCharChange(char), // Notifica el cambio de personaje al padre.
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: char.color,
                    shape: BoxShape.circle,
                    // Si está seleccionado, dibuja un borde blanco grueso alrededor del círculo:
                    border: isSelected
                        ? Border.all(color: Colors.white, width: 4)
                        : null,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      );
    }
    return rows;
  }
}