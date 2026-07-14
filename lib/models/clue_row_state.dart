import 'package:flutter/foundation.dart';

class ClueRowState extends ChangeNotifier {
  final String name;
  final int numOpponents;
  
  int _nameStatus = 0;
  late List<int> _playerStates;

  ClueRowState(this.name, this.numOpponents) {
    _nameStatus = 0;
    _playerStates = List<int>.filled(numOpponents, 0);
  }

  int get nameStatus => _nameStatus;
  List<int> get playerStates => _playerStates;

  bool get isHighProbability {
    final countTwos = _playerStates.where((state) => state == 2).length;
    return countTwos >= (numOpponents - 1) && _nameStatus == 0;
  }

  void setNameStatus(int status) {
    _nameStatus = status;
    notifyListeners();
  }

  void setPlayerState(int index, int state) {
    _playerStates[index] = state;
    notifyListeners();
  }

  void toggleStatus() {
    if (isHighProbability && _nameStatus == 0) {
      _nameStatus = 3;
    } else {
      _nameStatus = (_nameStatus + 1) % 4;
    }

    if (_nameStatus == 3) {
      for (int i = 0; i < numOpponents; i++) {
        _playerStates[i] = 2;
      }
    } else if (_nameStatus == 0) {
      for (int i = 0; i < numOpponents; i++) {
        _playerStates[i] = 0;
      }
    }
    notifyListeners();
  }

  void updatePlayerState(int index) {
    _playerStates[index] = (_playerStates[index] + 1) % 4;
    
    if (_playerStates[index] == 3) {
      _nameStatus = 2;
    } else if (_playerStates.every((state) => state == 2)) {
      _nameStatus = 3;
    } else if (_nameStatus == 3 || (_nameStatus == 2 && !_playerStates.contains(3))) {
      _nameStatus = 0;
    }
    notifyListeners();
  }
}
