import 'package:flutter/material.dart';
import '../models/clue_character.dart';
import '../models/clue_row_state.dart';
import '../main.dart';

class StepSelectHand extends StatefulWidget {
  final ClueCharacter selectedChar;
  final List<ClueRowState> sos;
  final List<ClueRowState> arm;
  final List<ClueRowState> lug;
  final VoidCallback onBack;
  final VoidCallback onNext;

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
  bool _expandedWho = true;
  bool _expandedWhat = true;
  bool _expandedWhere = true;

  @override
  Widget build(BuildContext context) {
    final totalSelected = [...widget.sos, ...widget.arm, ...widget.lug]
        .where((item) => item.nameStatus == 1)
        .length;

    return Scaffold(
      backgroundColor: darkBackground,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text(
              "TU MANO INICIAL",
              style: TextStyle(
                color: widget.selectedChar.color,
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Selecciona las cartas que TIENES en tu mano -> $totalSelected",
              style: TextStyle(color: widget.selectedChar.color, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                children: [
                  _buildAccordionHeader("SOSPECHOSOS", _expandedWho, () {
                    setState(() => _expandedWho = !_expandedWho);
                  }),
                  if (_expandedWho) ...widget.sos.map((item) => _buildHandTile(item)),
                  _buildAccordionHeader("ARMAS", _expandedWhat, () {
                    setState(() => _expandedWhat = !_expandedWhat);
                  }),
                  if (_expandedWhat) ...widget.arm.map((item) => _buildHandTile(item)),
                  _buildAccordionHeader("HABITACIONES", _expandedWhere, () {
                    setState(() => _expandedWhere = !_expandedWhere);
                  }),
                  if (_expandedWhere) ...widget.lug.map((item) => _buildHandTile(item)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Row(
                  children: [
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
                    Expanded(
                      flex: 1,
                      child: SizedBox(
                        height: 60,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: widget.selectedChar.color,
                            shape: roundedCornerShape(20),
                          ),
                          onPressed: widget.onNext,
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

  Widget _buildHandTile(ClueRowState item) {
    final bool isSelected = item.nameStatus == 1;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2.0),
      decoration: BoxDecoration(
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
        trailing: Checkbox(
          value: isSelected,
          activeColor: handOrange,
          checkColor: Colors.black,
          onChanged: (bool? value) {
            setState(() {
              // Solo modificamos nameStatus (1 para seleccionado en mano, 0 para desmarcado)
              item.setNameStatus(value == true ? 1 : 0);
            });
          },
        ),
        onTap: () {
          setState(() {
            item.setNameStatus(!isSelected ? 1 : 0);
          });
        },
      ),
    );
  }
}