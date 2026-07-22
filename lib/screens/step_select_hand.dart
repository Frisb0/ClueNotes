import 'package:flutter/material.dart';
import '../models/clue_character.dart';
import '../models/clue_row_state.dart';
import '../main.dart';

/// PASO 2 DE SETUP: Pantalla para seleccionar las cartas de la mano inicial del jugador.
class StepSelectHand extends StatefulWidget {
  final ClueCharacter selectedChar; // Personaje activo (aporta el color temático de la UI).
  final List<ClueRowState> sos;     // Filas de Sospechosos.
  final List<ClueRowState> arm;     // Filas de Armas.
  final List<ClueRowState> lug;     // Filas de Lugares.
  final VoidCallback onBack;        // Callback para volver al paso 1 (Nombres de oponentes).
  final VoidCallback onNext;        // Callback para iniciar la partida e ingresar a la tabla.

  const StepSelectHand({
    super.key,
    required this.selectedChar,
    required this.sos,
    required this.arm,
    required this.lug,
    required this.onBack,
    required this.onNext,
  });

  @override
  State<StepSelectHand> createState() => _StepSelectHandState();
}

class _StepSelectHandState extends State<StepSelectHand> {
  // --- ESTADO LOCAL DE ACORDEONES ---
  // Permite colapsar/desplegar las secciones para facilitar la búsqueda visual de cartas.
  bool _expandedWho = true;
  bool _expandedWhat = true;
  bool _expandedWhere = true;

  @override
  Widget build(BuildContext context) {
    // CONTAGIO DE DATOS: Cuenta en tiempo real cuántas cartas han sido marcadas como "Mano Inicial" (Estado 1 / Naranja).
    final totalSelected = [...widget.sos, ...widget.arm, ...widget.lug]
        .where((item) => item.nameStatus == 1)
        .length;

    return Scaffold(
      backgroundColor: darkBackground,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Título Principal
            Text(
              "TU MANO INICIAL",
              style: TextStyle(
                color: widget.selectedChar.color,
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            // Contador dinámico que se actualiza al marcar o desmarcar elementos.
            Text(
              "Selecciona las cartas que TIENES en tu mano -> $totalSelected",
              style: TextStyle(color: widget.selectedChar.color, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // LISTADO CON ACORDEONES DE SELECCIÓN
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                children: [
                  // Acordeón Sospechosos
                  _buildAccordionHeader("SOSPECHOSOS", _expandedWho, () {
                    setState(() => _expandedWho = !_expandedWho);
                  }),
                  if (_expandedWho) ...widget.sos.map((item) => _buildHandTile(item)),

                  // Acordeón Armas
                  _buildAccordionHeader("ARMAS", _expandedWhat, () {
                    setState(() => _expandedWhat = !_expandedWhat);
                  }),
                  if (_expandedWhat) ...widget.arm.map((item) => _buildHandTile(item)),

                  // Acordeón Habitaciones / Lugares
                  _buildAccordionHeader("HABITACIONES", _expandedWhere, () {
                    setState(() => _expandedWhere = !_expandedWhere);
                  }),
                  if (_expandedWhere) ...widget.lug.map((item) => _buildHandTile(item)),
                ],
              ),
            ),

            // BOTONES DE NAVEGACIÓN (ATRÁS / COMENZAR)
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Row(
                  children: [
                    // Botón Regresar
                    Expanded(
                      child: InkWell(
                        onTap: widget.onBack,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          height: 60,
                          decoration: BoxDecoration(
                            border: Border.all(color: widget.selectedChar.color, width: 2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            "ATRÁS",
                            style: TextStyle(
                              color: widget.selectedChar.color,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Botón Iniciar Partida
                    Expanded(
                      flex: 1,
                      child: SizedBox(
                        height: 60,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: widget.selectedChar.color,
                            shape: roundedCornerShape(20),
                          ),
                          onPressed: widget.onNext, // Avanza al paso 3 (Planilla principal de juego).
                          child: Text(
                            "COMENZAR",
                            style: TextStyle(
                              color: widget.selectedChar.color.computeLuminance() > 0.5
                                  ? Colors.black
                                  : Colors.white,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Helper visual para construir los encabezados de sección que permiten colapsar contenido.
  Widget _buildAccordionHeader(String title, bool isExpanded, VoidCallback onTap) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: widget.selectedChar.color,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Icon(
                  isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: widget.selectedChar.color,
                ),
              ],
            ),
          ),
        ),
        const Divider(color: rowDivider, height: 1),
      ],
    );
  }

  /// TARJETA SELECCIONABLE: Renderiza una fila interactiva con checkbox para marcar la carta.
  Widget _buildHandTile(ClueRowState item) {
    // Revisa si la carta ya fue marcada como "Mano Inicial" (Estado 1 / Naranja).
    final bool isSelected = item.nameStatus == 1;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2.0),
      decoration: BoxDecoration(
        // Si está seleccionada, aplica un fondo naranja tenue y un borde naranja resaltado:
        color: isSelected ? handOrange.withValues(alpha: 0.2) : Colors.transparent,
        border: Border.all(
          color: isSelected ? handOrange : rowDivider,
          width: isSelected ? 1.5 : 0.5,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        dense: true,
        title: Text(
          item.name,
          style: TextStyle(
            color: isSelected ? handOrange : textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        // Checkbox interactivo
        trailing: Checkbox(
          value: isSelected,
          activeColor: handOrange,
          checkColor: Colors.black,
          onChanged: (bool? value) {
            setState(() {
              // Asigna estado 1 (Mano) si el valor es true, o 0 (Normal) si se desmarca.
              item.setNameStatus(value == true ? 1 : 0);
            });
          },
        ),
        // Permite tocar toda la fila (no solo la casilla pequeña del Checkbox) para marcar la carta.
        onTap: () {
          setState(() {
            item.setNameStatus(!isSelected ? 1 : 0);
          });
        },
      ),
    );
  }
}