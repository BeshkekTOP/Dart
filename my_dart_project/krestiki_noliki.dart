import 'dart:io';
import 'dart:math';

void main() {
  print('=== Крестики-Нолики ===');
  
  while (true) {
    int size = 0;
    while (size < 3 || size > 9) {
      stdout.write('Введите размер поля (3-9): ');
      String input = stdin.readLineSync() ?? '';
      size = int.tryParse(input) ?? 0;
      if (size < 3 || size > 9) {
        print('Неверный размер!');
      }
    }
    
    int mode = 0;
    while (mode < 1 || mode > 2) {
      stdout.write('Выберите режим (1 - два игрока, 2 - против робота): ');
      String input = stdin.readLineSync() ?? '';
      mode = int.tryParse(input) ?? 0;
      if (mode < 1 || mode > 2) {
        print('Неверный режим!');
      }
    }
    
    bool vsRobot = (mode == 2);
    
    List<List<String>> board = [];
    for (int i = 0; i < size; i++) {
      List<String> row = [];
      for (int j = 0; j < size; j++) {
        row.add('.');
      }
      board.add(row);
    }
    
    Random random = Random();
    String currentPlayer = random.nextBool() ? 'X' : 'O';
    
    print('Первым ходит: $currentPlayer');
    if (vsRobot) {
      print('Вы играете за X, робот играет за O');
    }
    
    bool gameOver = false;
    
    while (!gameOver) {
      print('\nТекущее поле:');
      for (int i = 0; i < size; i++) {
        String row = '';
        for (int j = 0; j < size; j++) {
          row += board[i][j] + ' ';
        }
        print('${i + 1}: $row');
      }
      
      if (vsRobot && currentPlayer == 'O') {
        print('Робот думает...');
        List<List<int>> freeCells = [];
        for (int i = 0; i < size; i++) {
          for (int j = 0; j < size; j++) {
            if (board[i][j] == '.') {
              freeCells.add([i, j]);
            }
          }
        }
        
        if (freeCells.isNotEmpty) {
          List<int> cell = freeCells[random.nextInt(freeCells.length)];
          board[cell[0]][cell[1]] = 'O';
          print('Робот поставил O на ${cell[0] + 1} ${cell[1] + 1}');
        }
      } else {
        bool validMove = false;
        while (!validMove) {
          stdout.write('$currentPlayer, введите строку и столбец (например: 1 2): ');
          String input = stdin.readLineSync() ?? '';
          List<String> parts = input.split(' ');
          
          if (parts.length == 2) {
            int row = int.tryParse(parts[0]) ?? -1;
            int col = int.tryParse(parts[1]) ?? -1;
            
            if (row >= 1 && row <= size && col >= 1 && col <= size) {
              if (board[row-1][col-1] == '.') {
                board[row-1][col-1] = currentPlayer;
                validMove = true;
              } else {
                print('Эта клетка уже занята!');
              }
            } else {
              print('Неверные координаты!');
            }
          } else {
            print('Введите два числа через пробел!');
          }
        }
      }
      
      bool win = false;

      for (int i = 0; i < size; i++) {
        bool rowWin = true;
        for (int j = 0; j < size; j++) {
          if (board[i][j] != currentPlayer) {
            rowWin = false;
            break;
          }
        }
        if (rowWin) win = true;
      }
      
      for (int j = 0; j < size; j++) {
        bool colWin = true;
        for (int i = 0; i < size; i++) {
          if (board[i][j] != currentPlayer) {
            colWin = false;
            break;
          }
        }
        if (colWin) win = true;
      }
      
      bool diag1Win = true;
      bool diag2Win = true;
      for (int i = 0; i < size; i++) {
        if (board[i][i] != currentPlayer) diag1Win = false;
        if (board[i][size-1-i] != currentPlayer) diag2Win = false;
      }
      if (diag1Win || diag2Win) win = true;
      
      if (win) {
        if (vsRobot && currentPlayer == 'O') {
          print('\nРОБОТ ВЫИГРАЛ!');
        } else {
          print('\nПОБЕДА! Игрок $currentPlayer выиграл!');
        }
        gameOver = true;
      } else {
        bool draw = true;
        for (int i = 0; i < size; i++) {
          for (int j = 0; j < size; j++) {
            if (board[i][j] == '.') {
              draw = false;
              break;
            }
          }
        }
        
        if (draw) {
          print('\nНИЧЬЯ!');
          gameOver = true;
        } else {
          currentPlayer = currentPlayer == 'X' ? 'O' : 'X';
        }
      }
    }
    
    print('\nФинальное поле:');
    for (int i = 0; i < size; i++) {
      String row = '';
      for (int j = 0; j < size; j++) {
        row += board[i][j] + ' ';
      }
      print(row);
    }

    stdout.write('\nХотите сыграть еще раз? (да/нет): ');
    String answer = stdin.readLineSync()?.toLowerCase() ?? '';
    if (answer != 'да' && answer != 'д' && answer != 'y' && answer != 'yes') {
      print('Спасибо за игру!');
      break;
    }
  }
}