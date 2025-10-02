import 'dart:io';
import 'dart:math';

class SeaBattle {
  static const int size = 6;
  static const ships = [3, 2, 2, 1, 1, 1, 1];
  late List<List<String>> playerBoard;
  late List<List<String>> computerBoard;
  late List<List<bool>> playerShips;
  late List<List<bool>> computerShips;
  Random random = Random();

  void startGame() {
    print('=== МОРСКОЙ БОЙ ===');
    print('Расставляем корабли...');
    
    playerBoard = List.generate(size, (_) => List.filled(size, '~'));
    computerBoard = List.generate(size, (_) => List.filled(size, '~'));
    playerShips = List.generate(size, (_) => List.filled(size, false));
    computerShips = List.generate(size, (_) => List.filled(size, false));
    
    print('Расставляем корабли игрока...');
    _placeShips(playerShips);
    print('Расставляем корабли компьютера...');
    _placeShips(computerShips);
    
    print('Корабли расставлены! Начинаем игру!\n');
    
    _printBoards();
    
    bool gameOver = false;
    while (!gameOver) {
      _playerTurn();
      
      if (_checkWin(computerShips)) {
        _printBoards();
        print('🎉 ПОЗДРАВЛЯЮ! ТЫ ПОБЕДИЛ! 🎉');
        gameOver = true;
        continue;
      }
      
      _computerTurn();
      if (_checkWin(playerShips)) {
        _printBoards();
        print('💻 КОМПЬЮТЕР ПОБЕДИЛ! Попробуй еще раз! 💻');
        gameOver = true;
      }
      
      _printBoards();
    }
  }

  void _placeShips(List<List<bool>> board) {
    for (int shipSize in ships) {
      bool placed = false;
      int attempts = 0;
      
      while (!placed && attempts < 100) {
        int row = random.nextInt(size);
        int col = random.nextInt(size);
        bool horizontal = random.nextBool();
        
        if (_canPlaceShip(board, row, col, shipSize, horizontal)) {
          _placeShip(board, row, col, shipSize, horizontal);
          placed = true;
          print('  Поставлен корабль размером $shipSize в ${_numberToLetter(col)}${row + 1}');
        }
        attempts++;
      }
      
      if (!placed) {
        print('  Не удалось поставить корабль размером $shipSize');
      }
    }
  }

  bool _canPlaceShip(List<List<bool>> board, int row, int col, int size, bool horizontal) {
    if (horizontal) {
      if (col + size > SeaBattle.size) return false;
    } else {
      if (row + size > SeaBattle.size) return false;
    }
    
    for (int i = 0; i < size; i++) {
      int r = horizontal ? row : row + i;
      int c = horizontal ? col + i : col;
      
      if (r >= SeaBattle.size || c >= SeaBattle.size) return false;
      if (board[r][c]) return false;
      
      for (int dr = -1; dr <= 1; dr++) {
        for (int dc = -1; dc <= 1; dc++) {
          int nr = r + dr;
          int nc = c + dc;
          if (nr >= 0 && nr < SeaBattle.size && nc >= 0 && nc < SeaBattle.size) {
            if (board[nr][nc]) return false;
          }
        }
      }
    }
    return true;
  }

  void _placeShip(List<List<bool>> board, int row, int col, int size, bool horizontal) {
    for (int i = 0; i < size; i++) {
      int r = horizontal ? row : row + i;
      int c = horizontal ? col + i : col;
      board[r][c] = true;
    }
  }

  void _printBoards() {
    print('\n' + '='*50);
    print('ТВОЕ ПОЛЕ\t\t\tПОЛЕ КОМПЬЮТЕРА');
    print('  A B C D E F\t\t  A B C D E F');
    
    for (int i = 0; i < size; i++) {
      String playerLine = '${i + 1} ';
      String computerLine = '${i + 1} ';
      
      for (int j = 0; j < size; j++) {
        playerLine += playerBoard[i][j] + ' ';
        computerLine += computerBoard[i][j] + ' ';
      }
      
      print('$playerLine\t$computerLine');
    }
    print('='*50);
  }

  void _playerTurn() {
    print('\n--- ТВОЙ ХОД! ---');
    
    while (true) {
      stdout.write('Введи координаты выстрела (например: A1): ');
      String? input = stdin.readLineSync();
      
      if (input == null || input.isEmpty) {
        print('❌ Пустой ввод! Попробуй еще раз.');
        continue;
      }
      
      String cleanInput = input.toUpperCase().trim();
      
      if (cleanInput.length < 2) {
        print('❌ Неверный формат! Пример: A1');
        continue;
      }
      
      String colChar = cleanInput[0];
      String rowChar = cleanInput.substring(1);
      
      int col = _letterToNumber(colChar);
      int row = int.tryParse(rowChar) ?? -1;
      
      if (col == -1) {
        print('❌ Неверная буква! Используй A, B, C, D, E, F');
        continue;
      }
      
      if (row < 1 || row > size) {
        print('❌ Неверная цифра! Используй числа от 1 до $size');
        continue;
      }
      
      row--;
      
      if (row < 0 || row >= size || col < 0 || col >= size) {
        print('❌ Координаты вне поля!');
        continue;
      }
      
      if (computerBoard[row][col] == 'X' || computerBoard[row][col] == 'O') {
        print('❌ Ты уже стрелял в эту клетку!');
        continue;
      }
      
      if (computerShips[row][col]) {
        print('🎯 ПОПАЛ! Отличный выстрел!');
        computerBoard[row][col] = 'X';
        computerShips[row][col] = false; 
        print('💦 МИМО! Попробуй еще раз.');
        computerBoard[row][col] = 'O';
      }
      break;
    }
  }

  void _computerTurn() {
    print('\n--- ХОД КОМПЬЮТЕРА ---');
    List<Point<int>> availableShots = [];
    for (int i = 0; i < size; i++) {
      for (int j = 0; j < size; j++) {
        if (playerBoard[i][j] != 'X' && playerBoard[i][j] != 'O') {
          availableShots.add(Point(i, j));
        }
      }
    }
    
    if (availableShots.isEmpty) {
      print('Не осталось клеток для выстрела!');
      return;
    }
    
    Point<int> shot = availableShots[random.nextInt(availableShots.length)];
    int row = shot.x;
    int col = shot.y;
    
    if (playerShips[row][col]) {
      print('💥 Компьютер попал в ${_numberToLetter(col)}${row + 1}!');
      playerBoard[row][col] = 'X';
      playerShips[row][col] = false;
    } else {
      print('💧 Компьютер промахнулся в ${_numberToLetter(col)}${row + 1}');
      playerBoard[row][col] = 'O';
    }
  }

  bool _checkWin(List<List<bool>> ships) {
    for (int i = 0; i < size; i++) {
      for (int j = 0; j < size; j++) {
        if (ships[i][j]) {
          return false; 
        }
      }
    }
    return true; 
  }

  int _letterToNumber(String letter) {
    const letters = {'A': 0, 'B': 1, 'C': 2, 'D': 3, 'E': 4, 'F': 5};
    return letters[letter] ?? -1;
  }

  String _numberToLetter(int number) {
    const letters = ['A', 'B', 'C', 'D', 'E', 'F'];
    return number >= 0 && number < letters.length ? letters[number] : '?';
  }
}

void main() {
  try {
    SeaBattle game = SeaBattle();
    game.startGame();
  } catch (e) {
    print('Произошла ошибка: $e');
    print('Перезапустите игру.');
  }
}