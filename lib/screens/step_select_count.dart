import 'package:flutter/material.dart';
import '../models/clue_character.dart';
import '../main.dart';

class StepSelectCount extends StatefulWidget {
  final ClueCharacter selectedChar;
  final ValueChanged<ClueCharacter> onCharChange;
  final ValueChanged<int> onNext;

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
  int _count = 4;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight, 
            ),
            child: IntrinsicHeight(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center, 
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
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
                  Text(
                    widget.selectedChar.name,
                    style: TextStyle(
                      color: widget.selectedChar.color,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 15),
                  ..._buildPaletteRows(),
                  const SizedBox(height: 50),
                  const Text(
                    "¿CUÁNTOS JUGADORES?",
                    style: TextStyle(color: textPrimary, fontSize: 20, fontWeight: FontWeight.w900),
                  ),
                  const Text(
                    "(Incluyéndote a ti)",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton.filled(
                        style: IconButton.styleFrom(
                          backgroundColor: surfaceColor,
                          shape: roundedCornerShape(15),
                          fixedSize: const Size(60, 60),
                        ),
                        icon: Text("-", style: TextStyle(fontSize: 30, color: widget.selectedChar.color)),
                        onPressed: () {
                          if (_count > 3) setState(() => _count--);
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40.0),
                        child: Text(
                          "$_count",
                          style: const TextStyle(color: Colors.white, fontSize: 56, fontWeight: FontWeight.w900),
                        ),
                      ),
                      IconButton.filled(
                        style: IconButton.styleFrom(
                          backgroundColor: surfaceColor,
                          shape: roundedCornerShape(15),
                          fixedSize: const Size(60, 60),
                        ),
                        icon: Text("+", style: TextStyle(fontSize: 30, color: widget.selectedChar.color)),
                        onPressed: () {
                          if (_count < 6) setState(() => _count++);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 50),
                  SizedBox(
                    width: double.infinity,
                    height: 70,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.selectedChar.color,
                        shape: roundedCornerShape(20),
                      ),
                      onPressed: () => widget.onNext(_count),
                      child: Text(
                        "CONTINUAR",
                        style: TextStyle(
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

  List<Widget> _buildPaletteRows() {
    List<Widget> rows = [];
    for (int i = 0; i < cluePalette.length; i += 3) {
      final chunk = cluePalette.sublist(i, i + 3 > cluePalette.length ? cluePalette.length : i + 3);
      rows.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: chunk.map((char) {
            final isSelected = widget.selectedChar == char;
            return GestureDetector(
              onTap: () => widget.onCharChange(char),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: char.color,
                    shape: BoxShape.circle,
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