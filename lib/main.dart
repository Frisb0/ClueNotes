import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models/clue_character.dart';
import 'models/clue_row_state.dart';
import 'screens/clue_sheet_screen.dart';
import 'screens/step_select_count.dart';
import 'screens/step_enter_names.dart';
import 'screens/step_select_hand.dart';

// --- PALETA DE COLORES GLOBAL ---
// Colores constantes que definen la identidad visual de la app y los estados de las pistas.
const Color darkBackground = Color(0xFF000000); // Fondo principal ultra oscuro.
const Color surfaceColor = Color(0xFF1E1E1E);    // Color para tarjetas, modales y AppBars.
const Color textPrimary = Color(0xFFFFFFFF);     // Texto blanco principal.
const Color rowDivider = Color(0xFF444444);      // Líneas divisoras de la tabla.
const Color handOrange = Color(0xFFFF9800);      // Naranja: Cartas que el jugador tiene en su mano.
const Color strikeRed = Color(0xFFFF5252);       // Rojo: Cartas descartadas/marcadas con X.
const Color confirmGreen = Color(0xFF4CAF50);    // Verde: Cartas confirmadas o solución.
const Color probabilityGold = Color(0xFFFFD700); // Dorado: Alerta de alta probabilidad de sobre.
const Color infoBlue = Color(0xFF2196F3);        // Azul: Marcas temporales de sospecha (?).

/// Punto de entrada principal de la aplicación.
void main() {
  // Asegura que las vinculaciones del motor de Flutter estén listas antes de invocar código nativo.
  WidgetsFlutterBinding.ensureInitialized();
  
  // Bloquea la orientación de la pantalla únicamente en modo vertical (portrait) para evitar desconfigurar la tabla.
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]).then((_) {
    runApp(const ClueAppRoot());
  });
}

/// Widget Raíz (Sin Estado): Configura el tema oscuro y la navegación base de la app.
class ClueAppRoot extends StatelessWidget {
  const ClueAppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clue Notes',
      debugShowCheckedModeBanner: false, // Oculta la etiqueta "DEBUG" en desarrollo.
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: darkBackground,
        colorScheme: const ColorScheme.dark(
          primary: Colors.white,
          surface: surfaceColor,
        ),
      ),
      home: const ClueApp(), // Define la pantalla inicial ejecutable.
    );
  }
}

/// Widget Contenedor de Estado (Stateful): Administra el flujo de pantallas y los datos globales de la partida.
class ClueApp extends StatefulWidget {
  const ClueApp({super.key});

  @override
  State<ClueApp> createState() => _ClueAppState();
}

class _ClueAppState extends State<ClueApp> {
  // --- ESTADO GENERAL DE LA PARTIDA ---
  // Paso actual del onboarding/partida:
  // 0 = Selección de Personaje y Cantidad de Jugadores.
  // 1 = Ingreso de Nombres de Oponentes.
  // 2 = Selección de Mano Inicial.
  // 3 = Planilla/Tabla Principal de Deducción.
  int _currentStep = 0; 
  
  int _totalPlayers = 4; // Cantidad predeterminada de jugadores en la partida.
  ClueCharacter _selectedChar = cluePalette[0]; // Personaje elegido (define la temática de color de la UI).
  List<String> _opponentNames = []; // Arreglo que almacena los nombres de los oponentes ingresados.

  // --- MATRICES DE DEDUCCIÓN (SOSPECHOSOS, ARMAS, LUGARES) ---
  // Cada lista contiene objetos `ClueRowState` que gestionan las marcas (X, ?, ✔) por jugador.
  List<ClueRowState> _sos = []; // Tarjetas de Sospechosos (Who)
  List<ClueRowState> _arm = []; // Tarjetas de Armas (What)
  List<ClueRowState> _lug = []; // Tarjetas de Lugares (Where)

  /// Inicializa los arreglos de datos creando las filas para cada carta del Clue tradicional.
  /// Asigna a cada fila la cantidad de columnas correspondiente a la cantidad de oponentes.
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

  /// Despliega el modal flotante que contiene las instrucciones de uso y el significado de los símbolos.
  void _showTutorialDialog() {
    showDialog(
      context: context,
      builder: (context) => TutorialDialog(accentColor: _selectedChar.color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        // Retorna la vista correspondiente al paso de la partida activo de forma segura.
        child: _buildCurrentStepView(),
      ),
    );
  }

  /// Evaluador de flujo (Router interno): Renderiza la pantalla adecuada según `_currentStep`.
  Widget _buildCurrentStepView() {
    switch (_currentStep) {
      // PASO 0: Configuración inicial (Selección de Personaje y Cantidad de Jugadores).
      case 0:
        return StepSelectCount(
          selectedChar: _selectedChar,
          onCharChange: (char) {
            setState(() {
              _selectedChar = char; // Actualiza el color temático de la app.
            });
          },
          onNext: (players) {
            setState(() {
              _totalPlayers = players;
              _currentStep = 1; // Avanza al ingreso de nombres.
            });
          },
        );

      // PASO 1: Formulario para ingresar nombres de los rivales.
      case 1:
        return StepEnterNames(
          totalPlayers: _totalPlayers,
          selectedChar: _selectedChar,
          onBack: () {
            setState(() {
              _currentStep = 0; // Regresa al paso anterior.
            });
          },
          onNext: (names) {
            setState(() {
              _opponentNames = names;
              _initializeStates(names.length); // Construye las listas con el número correcto de columnas.
              _currentStep = 2; // Avanza a la selección de mano inicial.
            });
          },
        );

      // PASO 2: Selección de la Mano Inicial (Cartas propias que no están en el sobre ni tienen los rivales).
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
              _currentStep = 3; // Inicia la partida e ingresa a la planilla principal de notas.
            });
          },
        );

      // PASO 3: Planilla/Tabla de Juego activa.
      case 3:
        return ClueSheetScreen(
          opponents: _opponentNames,
          selectedChar: _selectedChar,
          sos: _sos,
          arm: _arm,
          lug: _lug,
          onOpenTutorial: _showTutorialDialog,
          onRestart: () {
            // Reinicia la partida limpiando nombres y regresando al paso inicial.
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

/// Modal que presenta la "Guía de Detective" para interpretar los colores y marcas de la tabla.
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
            onPressed: () => Navigator.pop(context), // Cierra la ventana emergente.
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

/// Componente visual reutilizable para renderizar cada línea con viñeta de color dentro del tutorial.
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
          // Viñeta o indicador circular de color
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
          // Texto explicativo con formato enriquecido (RichText/TextSpan)
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

/// Helper global para reutilizar bordes redondeados en botones y modales.
RoundedRectangleBorder roundedCornerShape(double radius) {
  return RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(radius),
  );
}