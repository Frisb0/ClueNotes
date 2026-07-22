import 'package:flutter/material.dart';
import '../models/clue_character.dart';
import '../models/clue_row_state.dart';
import '../main.dart';

/// Pantalla Principal de la Partida: Dibuja la matriz interactiva de deducción.
class ClueSheetScreen extends StatefulWidget {
  final List<String> opponents;       // Lista con los nombres de los rivales (encabezados de columna).
  final ClueCharacter selectedChar;   // Personaje activo (aporta el color temático de la UI).
  final List<ClueRowState> sos;       // Filas de Sospechosos.
  final List<ClueRowState> arm;       // Filas de Armas.
  final List<ClueRowState> lug;       // Filas de Lugares.
  final VoidCallback onOpenTutorial;  // Callback para invocar el tutorial desde la AppBar.
  final VoidCallback onRestart;       // Callback para reiniciar la partida y volver al setup.

  const ClueSheetScreen({
    super.key,
    required this.opponents,
    required this.selectedChar,
    required this.sos,
    required this.arm,
    required this.lug,
    required this.onOpenTutorial,
    required this.onRestart,
  });

  @override
  State<ClueSheetScreen> createState() => _ClueSheetScreenState();
}

class _ClueSheetScreenState extends State<ClueSheetScreen> {
  // --- ESTADO LOCAL DE ACORDEONES ---
  // Controla si cada sección de la tabla está desplegada (true) o colapsada (false).
  bool _expandedWho = true;
  bool _expandedWhat = true;
  bool _expandedWhere = true;

  @override
  void initState() {
    super.initState();
    // CICLO DE VIDA: Escucha cambios en los modelos `ClueRowState`.
    // Cuando un modelo ejecuta `notifyListeners()`, invocamos `_onRowChanged` para actualizar la vista.
    for (var row in [...widget.sos, ...widget.arm, ...widget.lug]) {
      row.addListener(_onRowChanged);
    }
  }

  /// Función que fuerza el rediseño de la pantalla si el widget sigue montado en el árbol de Flutter.
  void _onRowChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    // LIMPIEZA DE MEMORIA: Remueve los escuchadores cuando la pantalla se destruye para evitar memory leaks.
    for (var row in [...widget.sos, ...widget.arm, ...widget.lug]) {
      row.removeListener(_onRowChanged);
    }
    super.dispose();
  }

  /// Despliega el modal de confirmación antes de borrar la partida activa.
  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          "NUEVA PARTIDA", 
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        content: const Text("¿Seguro que quiere borrar todas las pistas?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("NO, VOLVER", style: TextStyle(color: textPrimary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onRestart(); // Ejecuta el reinicio enviado desde main.dart.
            },
            child: const Text(
              "SÍ, BORRAR", 
              style: TextStyle(color: strikeRed, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  /// REGLA DE VEREDICTO: Filtra qué elementos están marcados como solución (Estado 3 / Verde)
  /// y los presenta en un modal como la acusación final.
  void _showVeredictDialog() {
    final killer = widget.sos.firstWhere((e) => e.nameStatus == 3, orElse: () => ClueRowState("???", 0)).name;
    final weapon = widget.arm.firstWhere((e) => e.nameStatus == 3, orElse: () => ClueRowState("???", 0)).name;
    final room = widget.lug.firstWhere((e) => e.nameStatus == 3, orElse: () => ClueRowState("???", 0)).name;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: surfaceColor,
        title: Text(
          "VEREDICTO FINAL",
          style: TextStyle(
            color: widget.selectedChar.color, 
            fontWeight: FontWeight.w900,
            fontSize: 24,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            _buildVeredictRow("QUIÉN", killer),
            _buildVeredictRow("CON QUÉ", weapon),
            _buildVeredictRow("DÓNDE", room),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: widget.selectedChar.color),
            onPressed: () => Navigator.pop(context),
            child: Text(
              "ENTENDIDO",
              style: TextStyle(
                color: widget.selectedChar.color.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Helper visual para renderizar cada línea del Veredicto Final.
  Widget _buildVeredictRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text("$label: ", style: const TextStyle(color: Colors.grey, fontSize: 18)),
          Text(
            value.toUpperCase(),
            style: TextStyle(
              color: widget.selectedChar.color, 
              fontWeight: FontWeight.w900,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // `PopScope` intercepta el botón nativo de "Atrás" del teléfono para evitar salir por accidente.
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _showExitDialog();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: surfaceColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.help_outline, color: widget.selectedChar.color, size: 28),
            onPressed: widget.onOpenTutorial, // Abre la guía desde el ícono de la izquierda.
          ),
          centerTitle: true,
          title: Text(
            widget.selectedChar.name.toUpperCase(),
            style: TextStyle(
              color: widget.selectedChar.color, 
              fontWeight: FontWeight.w900,
              fontSize: 20,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.refresh, color: widget.selectedChar.color, size: 30),
              onPressed: _showResetDialog, // Botón de reinicio a la derecha.
            ),
          ],
        ),
        // Botón Flotante (Mazo de Juez) para desplegar la acusación/resumen de la partida.
        floatingActionButton: SizedBox(
          width: 70,
          height: 70,
          child: FloatingActionButton(
            backgroundColor: widget.selectedChar.color,
            onPressed: _showVeredictDialog,
            shape: const CircleBorder(),
            child: Icon(
              Icons.gavel,
              color: widget.selectedChar.color.computeLuminance() > 0.5 ? Colors.black : Colors.white,
              size: 35,
            ),
          ),
        ),
        body: Column(
          children: [
            // --- ENCABEZADO DE LA TABLA (Muestra los nombres de los oponentes) ---
            Container(
              color: surfaceColor,
              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 4.0),
              child: Row(
                children: [
                  const Expanded(
                    flex: 2,
                    child: Text(
                      "  NOTAS",
                      style: TextStyle(
                        color: Colors.grey, 
                        fontSize: 12, 
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  // Mapea la lista de oponentes para crear los títulos de las columnas:
                  ...widget.opponents.map((name) {
                    return Expanded(
                      child: Text(
                        name.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: widget.selectedChar.color,
                          fontWeight: FontWeight.w900,
                          fontSize: 10,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }),
                ],
              ),
            ),
            // --- LISTADO CON SECCIONES ACORDEÓN ---
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(left: 4, right: 4, bottom: 100),
                children: [
                  // Acordeón Sospechosos
                  _buildAccordionHeader("¿QUIÉN FUE?", _expandedWho, () {
                    setState(() => _expandedWho = !_expandedWho);
                  }),
                  if (_expandedWho) ...widget.sos.map((state) => _buildClueRowView(state)),

                  // Acordeón Armas
                  _buildAccordionHeader("¿CON QUÉ?", _expandedWhat, () {
                    setState(() => _expandedWhat = !_expandedWhat);
                  }),
                  if (_expandedWhat) ...widget.arm.map((state) => _buildClueRowView(state)),

                  // Acordeón Lugares
                  _buildAccordionHeader("¿DÓNDE?", _expandedWhere, () {
                    setState(() => _expandedWhere = !_expandedWhere);
                  }),
                  if (_expandedWhere) ...widget.lug.map((state) => _buildClueRowView(state)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construye los títulos interactivos que permiten colapsar y expandir secciones de la tabla.
  Widget _buildAccordionHeader(String title, bool isExpanded, VoidCallback onTap) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: widget.selectedChar.color,
                      fontSize: 18,
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

  /// RENDERIZADO DE FILA: Dibuja el nombre de la carta y las casillas interactivas para cada oponente.
  Widget _buildClueRowView(ClueRowState state) {
    final bool isHandCard = state.nameStatus == 1; // Verifica si es carta de tu mano inicial.

    // Determina el color de fondo de la fila según su estado lógico:
    Color rowOverlay = Colors.transparent;
    if (isHandCard) {
      rowOverlay = handOrange.withValues(alpha: 0.2); // Naranja (Mano)
    } else if (state.nameStatus == 2) {
      rowOverlay = strikeRed.withValues(alpha: 0.2);   // Rojo (Descarte)
    } else if (state.nameStatus == 3) {
      rowOverlay = confirmGreen.withValues(alpha: 0.2); // Verde (Veredicto)
    } else if (state.isHighProbability) {
      rowOverlay = probabilityGold.withValues(alpha: 0.2); // Dorado (Alta probabilidad)
    }

    return Container(
      decoration: BoxDecoration(
        color: rowOverlay,
        border: const Border(bottom: BorderSide(color: rowDivider, width: 0.5)),
      ),
      height: 60,
      child: Row(
        children: [
          // COLUMNA 1: Nombre de la carta (Modificación bloqueada desde la tabla).
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              alignment: Alignment.centerLeft,
              child: Text(
                state.name + (state.isHighProbability ? " ⚡" : ""),
                style: TextStyle(
                  decoration: (state.nameStatus == 1 || state.nameStatus == 2)
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                  color: _getRowTextColor(state),
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          // COLUMNAS RESTANTES: Casillas de descarte por cada oponente.
          ...List.generate(state.playerStates.length, (i) {
            Widget cellContent = const SizedBox();

            // Mapea el número de estado de la casilla a un símbolo visual:
            if (state.playerStates[i] == 1) {
              cellContent = const Text("?", style: TextStyle(color: infoBlue, fontWeight: FontWeight.bold, fontSize: 22));
            } else if (state.playerStates[i] == 2) {
              cellContent = const Text("X", style: TextStyle(color: strikeRed, fontWeight: FontWeight.bold, fontSize: 22));
            } else if (state.playerStates[i] == 3) {
              cellContent = const Icon(Icons.check, color: confirmGreen, size: 26);
            }

            return Expanded(
              child: InkWell(
                // BLOQUEO SEGURIDAD: Si es carta de la mano propia (`isHandCard`), deshabilita el click (`null`).
                // De lo contrario, ejecuta el avance de estado de la casilla (`updatePlayerState`).
                onTap: isHandCard ? null : () => state.updatePlayerState(i),
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(left: BorderSide(color: rowDivider, width: 0.2)),
                  ),
                  alignment: Alignment.center,
                  child: cellContent,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  /// Retorna el color adecuado para la tipografía según el estado de la fila.
  Color _getRowTextColor(ClueRowState state) {
    if (state.nameStatus == 1) return handOrange;
    if (state.nameStatus == 2) return strikeRed;
    if (state.nameStatus == 3) return confirmGreen;
    if (state.isHighProbability) return probabilityGold;
    return textPrimary;
  }

  /// Modal de advertencia cuando el usuario intenta retroceder con el botón nativo del teléfono.
  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          "¿SALIR DE LA PARTIDA?", 
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        content: const Text("Si sale ahora, perderá todas las notas actuales."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CANCELAR"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onRestart();
            },
            child: const Text(
              "SALIR", 
              style: TextStyle(color: strikeRed, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}