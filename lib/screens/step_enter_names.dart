import 'package:flutter/material.dart';
import '../models/clue_character.dart';
import '../main.dart';

/// PASO 1 DE SETUP: Formulario dinámico para ingresar el nombre de los rivales.
class StepEnterNames extends StatefulWidget {
  final int totalPlayers;                 // Cantidad total de jugadores ingresada en el paso 0.
  final ClueCharacter selectedChar;       // Personaje seleccionado (aporta la identidad de color).
  final VoidCallback onBack;              // Callback para regresar al paso 0.
  final ValueChanged<List<String>> onNext; // Callback que envía la lista de nombres válidos al main.dart.

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
  late int opponentsCount;                        // Número de oponentes (Total de jugadores - 1).
  late List<TextEditingController> _controllers;  // Controladores de texto para leer lo que escribe el usuario.

  @override
  void initState() {
    super.initState();
    // LÓGICA DE NEGOCIO: Si hay N jugadores totales, el usuario enfrentará a (N - 1) oponentes.
    opponentsCount = widget.totalPlayers - 1;

    // Inicializa una lista dinámica de controladores según la cantidad de oponentes.
    _controllers = List.generate(opponentsCount, (_) => TextEditingController());

    // Agrega un listener a cada campo de texto para reevaluar la UI cada vez que el usuario escribe.
    for (var controller in _controllers) {
      controller.addListener(_updateState);
    }
  }

  /// Forza el rediseño de la pantalla al escribir en cualquier casilla (actualiza el estado del botón "SIGUIENTE").
  void _updateState() {
    setState(() {});
  }

  @override
  void dispose() {
    // LIMPIEZA DE MEMORIA: Libera los recursos de hardware consumidos por cada controlador de texto.
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  /// VALIDACIÓN EN TIEMPO REAL: Retorna `true` únicamente si TODOS los campos de texto tienen al menos un carácter.
  bool get _isAllFilled => _controllers.every((c) => c.text.trim().isNotEmpty);

  @override
  Widget build(BuildContext context) {
    // `LayoutBuilder` permite calcular el espacio vertical disponible en la pantalla del dispositivo.
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: ConstrainedBox(
            // Previene errores de maquetación y asegura que el formulario se ajuste aunque se despliegue el teclado.
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: IntrinsicHeight(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center, 
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  // Título principal
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

                  // LISTADO DINÁMICO DE CAMPOS DE TEXTO
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: Column(
                      children: List.generate(opponentsCount, (index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: TextField(
                            controller: _controllers[index], // Vincula el controlador correspondiente.
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                            decoration: InputDecoration(
                              labelText: "Jugador #${index + 1}",
                              labelStyle: TextStyle(color: widget.selectedChar.color),
                              // Borde activo (enfocado) con el color del personaje seleccionado:
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: widget.selectedChar.color, width: 2),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              // Borde inactivo estándar:
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

                  // BOTONES DE NAVEGACIÓN (ATRÁS / SIGUIENTE)
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: Row(
                      children: [
                        // Botón Volver
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

                        // Botón Avanzar (Solo interactivo si `_isAllFilled` es verdadero)
                        Expanded(
                          flex: 1,
                          child: SizedBox(
                            height: 65,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                // Si falta algún nombre, desactiva visualmente el botón con color gris.
                                backgroundColor: _isAllFilled ? widget.selectedChar.color : Colors.grey[800],
                                shape: roundedCornerShape(20),
                              ),
                              // Si todos los campos están llenos, pasa la lista limpia de texto al callback `onNext`.
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