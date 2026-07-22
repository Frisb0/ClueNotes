import 'package:flutter/foundation.dart';

/// Clase que gestiona el estado lógico y deductivo de una fila (una carta específica).
/// Extiende `ChangeNotifier` para notificar a la vista cuando ocurre un cambio y forzar su redibujado.
class ClueRowState extends ChangeNotifier {
  final String name;        // Nombre de la carta (ej: "Verduzco", "Daga", "Biblioteca").
  final int numOpponents;   // Cantidad de oponentes en la partida (define el número de columnas).
  
  // --- ESTADOS PRIVADOS ---
  // Estado global de la fila/nombre (0: Normal, 1: Mano en Naranja, 2: Tached/Rojo, 3: Confirmado en Verde).
  int _nameStatus = 0;
  
  // Arreglo con el estado individual de cada casilla por oponente.
  // Valores por casilla: 0: Vacío, 1: Sospecha (?), 2: Descartado (X), 3: Confirmado (✔).
  late List<int> _playerStates;

  /// Constructor: Inicializa la fila limpia (estado 0) y crea las casillas según el número de oponentes.
  ClueRowState(this.name, this.numOpponents) {
    _nameStatus = 0;
    _playerStates = List<int>.filled(numOpponents, 0); // Llena la lista con ceros.
  }

  // --- GETTERS ---
  int get nameStatus => _nameStatus;
  List<int> get playerStates => _playerStates;

  /// REGLA DEDUCTIVA: Determina si la carta tiene alta probabilidad de estar en el sobre del crimen.
  /// Si casi todos los oponentes (numOpponents - 1) tienen un '2' (X / Descartado) y la carta sigue libre (estado 0),
  /// la app la resalta visualmente con el icono del rayo ⚡.
  bool get isHighProbability {
    final countTwos = _playerStates.where((state) => state == 2).length;
    return countTwos >= (numOpponents - 1) && _nameStatus == 0;
  }

  /// Establece explícitamente el estado de la fila (usado principalmente al configurar la Mano Inicial).
  void setNameStatus(int status) {
    _nameStatus = status;
    notifyListeners(); // Avisa a la UI para que se redibuje con el nuevo color.
  }

  /// Establece manualmente el estado de la casilla de un jugador específico por índice.
  void setPlayerState(int index, int state) {
    _playerStates[index] = state;
    notifyListeners();
  }

  /// Alterna en ciclo el estado global de la fila (Normal -> Mano -> Descarte -> Confirmado).
  void toggleStatus() {
    // Si la carta era altamente probable y está limpia, salta directo a Confirmada (3/Verde).
    if (isHighProbability && _nameStatus == 0) {
      _nameStatus = 3;
    } else {
      _nameStatus = (_nameStatus + 1) % 4; // Cicla de 0 a 3.
    }

    // Regla en cascada: Si la carta se confirma como la solución del crimen (Estado 3),
    // automáticamente descartamos (X / Estado 2) la posibilidad en todos los oponentes.
    if (_nameStatus == 3) {
      for (int i = 0; i < numOpponents; i++) {
        _playerStates[i] = 2;
      }
    } else if (_nameStatus == 0) {
      // Si la fila regresa a estado normal, limpia las casillas de los oponentes.
      for (int i = 0; i < numOpponents; i++) {
        _playerStates[i] = 0;
      }
    }
    notifyListeners();
  }

  /// REGLA INTERACTIVA: Se ejecuta al tocar una casilla de un oponente en la tabla de juego.
  /// Cicla el símbolo de la casilla: [Vacío] -> [?] -> [X] -> [✔] -> [Vacío]
  void updatePlayerState(int index) {
    _playerStates[index] = (_playerStates[index] + 1) % 4; // Avanza el estado de la casilla (0, 1, 2, 3).
    
    // --- LÓGICA AUTO-DEDUCTIVA ---
    if (_playerStates[index] == 3) {
      // Si confirmas que UN oponente TIENE la carta (✔ / Estado 3), la carta ya no puede ser el sobre del crimen.
      // Por ende, la fila pasa automáticamente a estado descartado (2 / Rojo).
      _nameStatus = 2;
    } else if (_playerStates.every((state) => state == 2)) {
      // Si TODOS los oponentes tienen 'X' (Estado 2), nadie tiene la carta.
      // ¡Deducción automática!: La carta DEBE estar en el sobre del veredicto (Estado 3 / Verde).
      _nameStatus = 3;
    } else if (_nameStatus == 3 || (_nameStatus == 2 && !_playerStates.contains(3))) {
      // Si el estado de la fila cambia o se quita la confirmación, resetea el nombre a Normal (0).
      _nameStatus = 0;
    }
    notifyListeners(); // Notifica la actualización a la planilla.
  }
}