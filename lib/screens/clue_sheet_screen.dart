import 'package:flutter/material.dart';
import '../models/clue_character.dart';
import '../models/clue_row_state.dart';
import '../main.dart';

class ClueSheetScreen extends StatefulWidget {
  final List<String> opponents;
  final ClueCharacter selectedChar;
  final List<ClueRowState> sos;
  final List<ClueRowState> arm;
  final List<ClueRowState> lug;
  final VoidCallback onOpenTutorial;
  final VoidCallback onRestart;

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
  bool _expandedWho = true;
  bool _expandedWhat = true;
  bool _expandedWhere = true;

  @override
  void initState() {
    super.initState();
    for (var row in [...widget.sos, ...widget.arm, ...widget.lug]) {
      row.addListener(_onRowChanged);
    }
  }

  void _onRowChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    for (var row in [...widget.sos, ...widget.arm, ...widget.lug]) {
      row.removeListener(_onRowChanged);
    }
    super.dispose();
  }

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
              widget.onRestart();
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
            onPressed: widget.onOpenTutorial,
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
              onPressed: _showResetDialog,
            ),
          ],
        ),
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
            // Header de la tabla
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
            // Secciones Colapsables
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(left: 4, right: 4, bottom: 100),
                children: [
                  _buildAccordionHeader("¿QUIÉN FUE?", _expandedWho, () {
                    setState(() => _expandedWho = !_expandedWho);
                  }),
                  if (_expandedWho) ...widget.sos.map((state) => _buildClueRowView(state)),
                  _buildAccordionHeader("¿CON QUÉ?", _expandedWhat, () {
                    setState(() => _expandedWhat = !_expandedWhat);
                  }),
                  if (_expandedWhat) ...widget.arm.map((state) => _buildClueRowView(state)),
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

  Widget _buildClueRowView(ClueRowState state) {
    final bool isHandCard = state.nameStatus == 1; // 👈 Identifica si es carta de tu mano

    Color rowOverlay = Colors.transparent;
    if (isHandCard) {
      rowOverlay = handOrange.withValues(alpha: 0.2);
    } else if (state.nameStatus == 2) {
      rowOverlay = strikeRed.withValues(alpha: 0.2);
    } else if (state.nameStatus == 3) {
      rowOverlay = confirmGreen.withValues(alpha: 0.2);
    } else if (state.isHighProbability) {
      rowOverlay = probabilityGold.withValues(alpha: 0.2);
    }

    return Container(
      decoration: BoxDecoration(
        color: rowOverlay,
        border: const Border(bottom: BorderSide(color: rowDivider, width: 0.5)),
      ),
      height: 60,
      child: Row(
        children: [
          // Nombre del ítem (Bloqueado para edición desde la tabla)
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
          // Casillas de descarte de los oponentes
          ...List.generate(state.playerStates.length, (i) {
            Widget cellContent = const SizedBox();

            if (state.playerStates[i] == 1) {
              cellContent = const Text(
                "?",
                style: TextStyle(
                  color: infoBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              );
            } else if (state.playerStates[i] == 2) {
              cellContent = const Text(
                "X",
                style: TextStyle(
                  color: strikeRed,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              );
            } else if (state.playerStates[i] == 3) {
              cellContent = const Icon(
                Icons.check,
                color: confirmGreen,
                size: 26,
              );
            }

            return Expanded(
              child: InkWell(
                // 👈 Si es carta de tu mano, deshabilitamos la interacción por completo (onTap: null)
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

  Color _getRowTextColor(ClueRowState state) {
    if (state.nameStatus == 1) return handOrange;
    if (state.nameStatus == 2) return strikeRed;
    if (state.nameStatus == 3) return confirmGreen;
    if (state.isHighProbability) return probabilityGold;
    return textPrimary;
  }

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