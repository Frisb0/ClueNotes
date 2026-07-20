import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models/clue_character.dart';
import 'models/clue_row_state.dart';
import 'screens/clue_sheet_screen.dart';
import 'screens/step_select_count.dart';
import 'screens/step_enter_names.dart';
import 'screens/step_select_hand.dart';

// --- COLORES ---
const Color darkBackground = Color(0xFF000000);
const Color surfaceColor = Color(0xFF1E1E1E);
const Color textPrimary = Color(0xFFFFFFFF);
const Color rowDivider = Color(0xFF444444);
const Color handOrange = Color(0xFFFF9800);
const Color strikeRed = Color(0xFFFF5252);
const Color confirmGreen = Color(0xFF4CAF50);
const Color probabilityGold = Color(0xFFFFD700);
const Color infoBlue = Color(0xFF2196F3);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]).then((_) {
    runApp(const ClueAppRoot());
  });
}

class ClueAppRoot extends StatelessWidget {
  const ClueAppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clue Notes',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: darkBackground,
        colorScheme: const ColorScheme.dark(
          primary: Colors.white,
          surface: surfaceColor,
        ),
      ),
      home: const ClueApp(),
    );
  }
}

class ClueApp extends StatefulWidget {
  const ClueApp({super.key});

  @override
  State<ClueApp> createState() => _ClueAppState();
}

class _ClueAppState extends State<ClueApp> {
  int _currentStep = 0; 
  int _totalPlayers = 4;
  ClueCharacter _selectedChar = cluePalette[0];
  List<String> _opponentNames = [];

  List<ClueRowState> _sos = [];
  List<ClueRowState> _arm = [];
  List<ClueRowState> _lug = [];

  void _initializeStates(int opponentsCount) {
    _sos = ["Verduzco", "Mostaza", "Marlene", "Moradillo", "Escarlata", "Blanca"]
        .map((name) => ClueRowState(name, opponentsCount))
        .toList();
    _arm = ["Candelabro", "Daga", "Tubo plomo", "Revólver", "Soga", "Llave"]
        .map((name) => ClueRowState(name, opponentsCount))
        .toList();
    _lug = [
      "Salón baile", "Sala billar", "Terraza", "Comedor", "Pasillo",
      "Cocina", "Biblioteca", "Sala", "Estudio"
    ].map((name) => ClueRowState(name, opponentsCount)).toList();
  }

  void _showTutorialDialog() {
    showDialog(
      context: context,
      builder: (context) => TutorialDialog(accentColor: _selectedChar.color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: _buildCurrentStepView(),
          ),
          if (_currentStep < 3)
            Positioned(
              top: 8,
              right: 8,
              child: SafeArea(
                child: IconButton(
                  icon: Icon(
                    Icons.help_outline,
                    color: _selectedChar.color,
                    size: 28,
                  ),
                  onPressed: _showTutorialDialog,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCurrentStepView() {
    switch (_currentStep) {
      case 0:
        return StepSelectCount(
          selectedChar: _selectedChar,
          onCharChange: (char) {
            setState(() {
              _selectedChar = char;
            });
          },
          onNext: (players) {
            setState(() {
              _totalPlayers = players;
              _currentStep = 1;
            });
          },
        );
      case 1:
        return StepEnterNames(
          totalPlayers: _totalPlayers,
          selectedChar: _selectedChar,
          onBack: () {
            setState(() {
              _currentStep = 0;
            });
          },
          onNext: (names) {
            setState(() {
              _opponentNames = names;
              _initializeStates(names.length);
              _currentStep = 2; // Avanza a la pantalla de Selección de Mano Inicial
            });
          },
        );
      case 2:
        return StepSelectHand(
          selectedChar: _selectedChar,
          sos: _sos,
          arm: _arm,
          lug: _lug,
          onBack: () {
            setState(() {
              _currentStep = 1;
            });
          },
          onNext: () {
            setState(() {
              _currentStep = 3; // Inicia la partida e ingresa a la planilla principal
            });
          },
        );
      case 3:
        return ClueSheetScreen(
          opponents: _opponentNames,
          selectedChar: _selectedChar,
          sos: _sos,
          arm: _arm,
          lug: _lug,
          onOpenTutorial: _showTutorialDialog,
          onRestart: () {
            setState(() {
              _opponentNames.clear();
              _currentStep = 0;
            });
          },
        );
      default:
        return Container();
    }
  }
}

class TutorialDialog extends StatelessWidget {
  final Color accentColor;
  const TutorialDialog({super.key, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: surfaceColor,
      title: Row(
        children: [
          Expanded(
            child: Text(
              "GUÍA DE DETECTIVE",
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: accentColor,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.grey),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      content: const SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "ELEMENTOS DE LA TABLA",
              style: TextStyle(fontWeight: FontWeight.bold, color: textPrimary, fontSize: 16),
            ),
            SizedBox(height: 8),
            TutorialItem(
              bulletColor: handOrange,
              spans: [
                TextSpan(text: "NARANJA", style: TextStyle(color: handOrange, fontWeight: FontWeight.bold)),
                TextSpan(text: ": Cartas que TÚ TIENES en tu mano."),
              ],
            ),
            TutorialItem(
              bulletColor: strikeRed,
              spans: [
                TextSpan(text: "ROJO", style: TextStyle(color: strikeRed, fontWeight: FontWeight.bold)),
                TextSpan(text: ": Cartas descartadas de OTROS jugadores."),
              ],
            ),
            TutorialItem(
              bulletColor: probabilityGold,
              spans: [
                TextSpan(text: "AMARILLO +⚡", style: TextStyle(color: probabilityGold, fontWeight: FontWeight.bold)),
                TextSpan(text: ": Alta probabilidad de carta del ASESINO."),
              ],
            ),
            TutorialItem(
              bulletColor: confirmGreen,
              spans: [
                TextSpan(text: "VERDE", style: TextStyle(color: confirmGreen, fontWeight: FontWeight.bold)),
                TextSpan(text: ": Cartas confirmadas del sobre/veredicto."),
              ],
            ),
            SizedBox(height: 16),
            Text(
              "SÍMBOLOS EN CASILLAS",
              style: TextStyle(fontWeight: FontWeight.bold, color: textPrimary, fontSize: 16),
            ),
            SizedBox(height: 8),
            TutorialItem(
              bulletColor: infoBlue,
              spans: [
                TextSpan(text: "? ", style: TextStyle(color: infoBlue, fontWeight: FontWeight.bold, fontSize: 16)),
                TextSpan(text: ": Úsalo para recordar qué cartas se preguntaron en el TURNO actual."),
              ],
            ),
            TutorialItem(
              bulletColor: strikeRed,
              spans: [
                TextSpan(text: "X ", style: TextStyle(color: strikeRed, fontWeight: FontWeight.bold, fontSize: 16)),
                TextSpan(text: ": Confirmas que el jugador NO TIENE la carta."),
              ],
            ),
            TutorialItem(
              bulletColor: confirmGreen,
              spans: [
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Icon(Icons.check, color: confirmGreen, size: 18),
                ),
                TextSpan(text: " : Confirmas que el jugador TIENE la carta."),
              ],
            ),
            SizedBox(height: 16),
            Text(
              "TIPS ADICIONALES",
              style: TextStyle(fontWeight: FontWeight.bold, color: textPrimary, fontSize: 16),
            ),
            SizedBox(height: 8),
            TutorialItem(
              bulletColor: Colors.white,
              spans: [
                TextSpan(text: "Acordeones", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                TextSpan(text: ": Toca los títulos para colapsar secciones."),
              ],
            ),
            TutorialItem(
              bulletColor: Colors.white,
              spans: [
                TextSpan(text: "Veredicto", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                TextSpan(text: ": Usa el botón del Mazo de Juez para ver el resumen."),
              ],
            ),
          ],
        ),
      ),
      actions: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              shape: roundedCornerShape(10),
            ),
            onPressed: () => Navigator.pop(context),
            child: Text(
              "¡ENTENDIDO!",
              style: TextStyle(
                color: accentColor.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class TutorialItem extends StatelessWidget {
  final Color bulletColor;
  final List<InlineSpan> spans;

  const TutorialItem({
    super.key,
    required this.bulletColor,
    required this.spans,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6.0),
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: bulletColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  height: 1.3,
                ),
                children: spans,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

RoundedRectangleBorder roundedCornerShape(double radius) {
  return RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(radius),
  );
}