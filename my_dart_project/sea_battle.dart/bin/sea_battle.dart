import 'dart:io';
import 'dart:math';

class Point<T> {
  final T x, y;
  const Point(this.x, this.y);
}

class SeaBattle {
  static const int size = 6;
  static const List<int> ships = [3, 2, 2, 1, 1, 1, 1];
  static const int totalShipCells = 11;

  late List<List<String>> playerBoard;
  late List<List<String>> computerBoard;
  late List<List<bool>> playerShips;
  late List<List<bool>> computerShips;

  int playerHits = 0;
  int playerMisses = 0;
  int computerHits = 0;
  int computerMisses = 0;

  Random random = Random();

  Future<void> startGame() async {
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
        await _saveStatistics(winner: 'Игрок');
        gameOver = true;
        continue;
      }

      _computerTurn();
      if (_checkWin(playerShips)) {
        _printBoards();
        print('💻 КОМПЬЮТЕР ПОБЕДИЛ! Попробуй еще раз! 💻');
        await _saveStatistics(winner: 'Компьютер');
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
        }
        attempts++;
      }
    }
  }

  bool _canPlaceShip(List<List<bool>> board, int row, int col, int size, bool horizontal) {
    if (horizontal ? col + size > SeaBattle.size : row + size > SeaBattle.size) return false;
    for (int i = 0; i < size; i++) {
      int r = horizontal ? row : row + i;
      int c = horizontal ? col + i : col;
      if (r >= SeaBattle.size || c >= SeaBattle.size || board[r][c]) return false;
      for (int dr = -1; dr <= 1; dr++) {
        for (int dc = -1; dc <= 1; dc++) {
          int nr = r + dr, nc = c + dc;
          if (nr >= 0 && nr < SeaBattle.size && nc >= 0 && nc < SeaBattle.size && board[nr][nc]) {
            return false;
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
    final sep = '=' * 50;
    print('\n$sep');
    print('ТВОЕ ПОЛЕ\t\t\tПОЛЕ КОМПЬЮТЕРА');
    print('  A B C D E F\t\t  A B C D E F');

    for (int i = 0; i < size; i++) {
      String playerLine = '${i + 1} ';
      String computerLine = '${i + 1} ';
      for (int j = 0; j < size; j++) {
        playerLine += '${playerBoard[i][j]} ';
        computerLine += '${computerBoard[i][j]} ';
      }
      print('$playerLine\t$computerLine');
    }
    print(sep);
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
        playerHits++;
      } else {
        print('💦 МИМО! Попробуй еще раз.');
        computerBoard[row][col] = 'O';
        playerMisses++;
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
      computerHits++;
    } else {
      print('💧 Компьютер промахнулся в ${_numberToLetter(col)}${row + 1}');
      playerBoard[row][col] = 'O';
      computerMisses++;
    }
  }

  bool _checkWin(List<List<bool>> ships) {
    return ships.expand((row) => row).every((cell) => !cell);
  }

  int _letterToNumber(String letter) {
    const letters = {'A': 0, 'B': 1, 'C': 2, 'D': 3, 'E': 4, 'F': 5};
    return letters[letter] ?? -1;
  }

  String _numberToLetter(int number) {
    const letters = ['A', 'B', 'C', 'D', 'E', 'F'];
    return number >= 0 && number < letters.length ? letters[number] : '?';
  }

  int _countRemainingCells(List<List<bool>> ships) {
    return ships.expand((row) => row).where((cell) => cell).length;
  }

  Future<void> _saveStatistics({required String winner}) async {
    final dir = Directory('stats');
    if (!await dir.exists()) await dir.create(recursive: true);

    final now = DateTime.now();
    final fileName = 'game_${now.year}'
        '${now.month.toString().padLeft(2, '0')}'
        '${now.day.toString().padLeft(2, '0')}_'
        '${now.hour.toString().padLeft(2, '0')}'
        '${now.minute.toString().padLeft(2, '0')}.txt';
    final filePath = '${dir.path}/$fileName';

    final playerRemaining = _countRemainingCells(playerShips);
    final computerRemaining = _countRemainingCells(computerShips);
    final totalPlayerShots = playerHits + playerMisses;
    final totalComputerShots = computerHits + computerMisses;

    String stats = '''
=== СТАТИСТИКА ИГРЫ ===
Дата и время: ${now.toIso8601String()}
Победитель: $winner

Игрок:
  Попаданий: $playerHits
  Промахов: $playerMisses
  Осталось клеток кораблей: $playerRemaining / $totalShipCells

Компьютер:
  Попаданий: $computerHits
  Промахов: $computerMisses
  Осталось клеток кораблей: $computerRemaining / $totalShipCells

Общее число выстрелов игрока: $totalPlayerShots
Общее число выстрелов компьютера: $totalComputerShots
========================================
''';

    await File(filePath).writeAsString(stats);
    print('\n📊 Статистика сохранена в файл: $filePath');
  }
}

void main() async {
  try {
    SeaBattle game = SeaBattle();
    await game.startGame();
  } catch (e) {
    print('Произошла ошибка: $e');
    print('Перезапустите игру.');
  }
}
