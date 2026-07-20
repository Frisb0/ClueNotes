import 'package:flutter/material.dart';
import '../models/clue_character.dart';
import '../main.dart';

class StepEnterNames extends StatefulWidget {
  final int totalPlayers;
  final ClueCharacter selectedChar;
  final VoidCallback onBack;
  final ValueChanged<List<String>> onNext;

  const StepEnterNames({
    super.key,
    required this.totalPlayers,
    required this.selectedChar,
    required this.onBack,
    required this.onNext,
  });

  @override
  State<StepEnterNames> createState() => _StepEnterNamesState();
}

class _StepEnterNamesState extends State<StepEnterNames> {
  late int opponentsCount;
  late List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    opponentsCount = widget.totalPlayers - 1;
    _controllers = List.generate(opponentsCount, (_) => TextEditingController());
    for (var controller in _controllers) {
      controller.addListener(_updateState);
    }
  }

  void _updateState() {
    setState(() {});
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  bool get _isAllFilled => _controllers.every((c) => c.text.trim().isNotEmpty);

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
                    "OPONENTES",
                    style: TextStyle(
                      color: widget.selectedChar.color,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    "Ingresa el nombre de tus $opponentsCount oponentes",
                    style: TextStyle(color: widget.selectedChar.color, fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: Column(
                      children: List.generate(opponentsCount, (index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: TextField(
                            controller: _controllers[index],
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                            decoration: InputDecoration(
                              labelText: "Jugador #${index + 1}",
                              labelStyle: TextStyle(color: widget.selectedChar.color),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: widget.selectedChar.color, width: 2),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color: rowDivider),
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 40),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: widget.onBack,
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              height: 65,
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
                            height: 65,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _isAllFilled ? widget.selectedChar.color : Colors.grey[800],
                                shape: roundedCornerShape(20),
                              ),
                              onPressed: _isAllFilled
                                  ? () => widget.onNext(_controllers.map((c) => c.text.trim()).toList())
                                  : null,
                              child: Text(
                                "SIGUIENTE",
                                style: TextStyle(
                                  color: _isAllFilled 
                                      ? (widget.selectedChar.color.computeLuminance() > 0.5 ? Colors.black : Colors.white)
                                      : Colors.grey,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
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
}