import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(const GameApp());
}

enum GameType { ticTacToe, chess }
enum GameMode { vsAi, vsPlayer }
enum ChessColor { white, black }
enum ChessPieceType { pawn, rook, knight, bishop, queen, king }

class GameApp extends StatelessWidget {
  const GameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Игры',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const StartScreen(),
    );
  }
}

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3E8FF),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Выбери игру',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ModeSelectScreen(gameType: GameType.ticTacToe),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text(
                      'Крестики-Нолики',
                      style: TextStyle(fontSize: 22),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ModeSelectScreen(gameType: GameType.chess),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text(
                      'Шахматы',
                      style: TextStyle(fontSize: 22),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ModeSelectScreen extends StatelessWidget {
  final GameType gameType;

  const ModeSelectScreen({super.key, required this.gameType});

  @override
  Widget build(BuildContext context) {
    final title = gameType == GameType.ticTacToe ? 'Крестики-Нолики' : 'Шахматы';

    return Scaffold(
      backgroundColor: const Color(0xFFF3E8FF),
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Выберите режим',
                  style: TextStyle(fontSize: 28, color: Colors.deepPurple),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => gameType == GameType.ticTacToe
                              ? const TicTacToeGameScreen(mode: GameMode.vsAi)
                              : const ChessGameScreen(mode: ChessMode.vsAi),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('Играть против бота', style: TextStyle(fontSize: 20)),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => gameType == GameType.ticTacToe
                              ? const TicTacToeGameScreen(mode: GameMode.vsPlayer)
                              : const ChessGameScreen(mode: ChessMode.vsPlayer),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.deepPurple,
                      side: const BorderSide(color: Colors.deepPurple, width: 2),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('Два игрока', style: TextStyle(fontSize: 20)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TicTacToeGameScreen extends StatefulWidget {
  final GameMode mode;

  const TicTacToeGameScreen({super.key, required this.mode});

  @override
  State<TicTacToeGameScreen> createState() => _TicTacToeGameScreenState();
}

class _TicTacToeGameScreenState extends State<TicTacToeGameScreen> {
  final List<String> _board = List.filled(9, '');
  String _currentPlayer = 'X';
  String _winner = '';
  bool _isDraw = false;

  bool get _isAiTurn => widget.mode == GameMode.vsAi && _currentPlayer == 'O' && _winner.isEmpty && !_isDraw;

  @override
  void initState() {
    super.initState();
    _makeAiMoveIfNeeded();
  }

  void _handleTap(int index) {
    if (_board[index].isNotEmpty || _winner.isNotEmpty || _isDraw || _isAiTurn) {
      return;
    }

    setState(() {
      _board[index] = _currentPlayer;
      final result = _checkWinner();

      if (result == 'draw') {
        _isDraw = true;
      } else if (result.isNotEmpty) {
        _winner = result;
      } else {
        _currentPlayer = _currentPlayer == 'X' ? 'O' : 'X';
      }
    });

    _makeAiMoveIfNeeded();
  }

  void _makeAiMoveIfNeeded() {
    if (!_isAiTurn) {
      return;
    }

    Future.delayed(const Duration(milliseconds: 450), () {
      if (!mounted || widget.mode != GameMode.vsAi) {
        return;
      }

      setState(() {
        final availableIndexes = <int>[];
        for (int i = 0; i < _board.length; i++) {
          if (_board[i].isEmpty) {
            availableIndexes.add(i);
          }
        }

        if (availableIndexes.isEmpty || _winner.isNotEmpty || _isDraw) {
          return;
        }

        final random = Random();
        final moveIndex = availableIndexes[random.nextInt(availableIndexes.length)];
        _board[moveIndex] = 'O';

        final result = _checkWinner();
        if (result == 'draw') {
          _isDraw = true;
        } else if (result.isNotEmpty) {
          _winner = result;
        } else {
          _currentPlayer = 'X';
        }
      });
    });
  }

  String _checkWinner() {
    const winPatterns = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];

    for (final pattern in winPatterns) {
      final a = _board[pattern[0]];
      final b = _board[pattern[1]];
      final c = _board[pattern[2]];

      if (a.isNotEmpty && a == b && b == c) {
        return a;
      }
    }

    if (_board.every((cell) => cell.isNotEmpty)) {
      return 'draw';
    }

    return '';
  }

  void _resetGame() {
    setState(() {
      _board.fillRange(0, _board.length, '');
      _currentPlayer = 'X';
      _winner = '';
      _isDraw = false;
    });
    _makeAiMoveIfNeeded();
  }

  @override
  Widget build(BuildContext context) {
    final statusText = _winner.isNotEmpty
        ? 'Победил $_winner'
        : _isDraw
            ? 'Ничья!'
            : widget.mode == GameMode.vsAi && _currentPlayer == 'O'
                ? 'ИИ думает...'
                : 'Ходит $_currentPlayer';

    return Scaffold(
      backgroundColor: const Color(0xFFF3E8FF),
      appBar: AppBar(
        title: const Text('Крестики-Нолики'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          
            child: SingleChildScrollView(
            
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5)),
                      ],
                    ),
                    child: Text(
                      statusText,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: min(MediaQuery.of(context).size.width - 40, 270.0),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: 9,
                      itemBuilder: (context, index) {
                        final cell = _board[index];
                        return GestureDetector(
                          onTap: () => _handleTap(index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Center(
                              child: Text(
                                cell,
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: cell == 'X' ? Colors.blue : Colors.deepOrange,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _resetGame,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Новая игра'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.home),
                    label: const Text('Выбрать режим'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.deepPurple,
                      side: const BorderSide(color: Colors.deepPurple, width: 2),
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      
    
  
 );
  }
}

enum ChessMode { vsAi, vsPlayer }

class ChessPiece {
  final ChessColor color;
  final ChessPieceType type;

  const ChessPiece({required this.color, required this.type});
}

class ChessMove {
  final int from;
  final int to;
  final ChessPiece piece;
  final ChessPiece? capturedPiece;

  ChessMove({
    required this.from,
    required this.to,
    required this.piece,
    this.capturedPiece,
  });
}

class ChessGameScreen extends StatefulWidget {
  final ChessMode mode;

  const ChessGameScreen({super.key, required this.mode});

  @override
  State<ChessGameScreen> createState() => _ChessGameScreenState();
}

class _ChessGameScreenState extends State<ChessGameScreen> {
  final List<ChessPiece?> _board = List<ChessPiece?>.filled(64, null);
  ChessColor _currentTurn = ChessColor.white;
  int? _selectedIndex;
  List<int> _legalMoves = [];
  String _status = 'Ход белых';
  bool _isGameOver = false;

  @override
  void initState() {
    super.initState();
    _resetBoard();
    if (widget.mode == ChessMode.vsAi && _currentTurn == ChessColor.black) {
      _makeAiMove();
    }
  }

  void _resetBoard() {
    _board.fillRange(0, _board.length, null);

    final backRank = [
      ChessPieceType.rook,
      ChessPieceType.knight,
      ChessPieceType.bishop,
      ChessPieceType.queen,
      ChessPieceType.king,
      ChessPieceType.bishop,
      ChessPieceType.knight,
      ChessPieceType.rook,
    ];

    for (int i = 0; i < 8; i++) {
      _board[i] = ChessPiece(color: ChessColor.black, type: backRank[i]);
      _board[56 + i] = ChessPiece(color: ChessColor.white, type: backRank[i]);
      _board[8 + i] = ChessPiece(color: ChessColor.black, type: ChessPieceType.pawn);
      _board[48 + i] = ChessPiece(color: ChessColor.white, type: ChessPieceType.pawn);
    }

    _currentTurn = ChessColor.white;
    _selectedIndex = null;
    _legalMoves = [];
    _status = 'Ход белых';
    _isGameOver = false;
  }

  bool _isInsideBoard(int row, int col) {
    return row >= 0 && row < 8 && col >= 0 && col < 8;
  }

  int _indexFromRowCol(int row, int col) => row * 8 + col;

  bool _isSquareAttacked(int targetIndex, ChessColor byColor) {
    final targetRow = targetIndex ~/ 8;
    final targetCol = targetIndex % 8;

    for (int index = 0; index < _board.length; index++) {
      final piece = _board[index];
      if (piece == null || piece.color != byColor) continue;

      final row = index ~/ 8;
      final col = index % 8;
      final rowDistance = targetRow - row;
      final colDistance = targetCol - col;

      switch (piece.type) {
        case ChessPieceType.pawn:
          final direction = byColor == ChessColor.white ? -1 : 1;
          if (rowDistance == direction && colDistance.abs() == 1) return true;
          break;
        case ChessPieceType.knight:
          if ((rowDistance.abs() == 2 && colDistance.abs() == 1) ||
              (rowDistance.abs() == 1 && colDistance.abs() == 2)) {
            return true;
          }
          break;
        case ChessPieceType.king:
          if (rowDistance.abs() <= 1 && colDistance.abs() <= 1) return true;
          break;
        case ChessPieceType.rook:
          if (rowDistance != 0 && colDistance != 0) break;
          if (_isPathClear(row, col, targetRow, targetCol)) return true;
          break;
        case ChessPieceType.bishop:
          if (rowDistance.abs() != colDistance.abs()) break;
          if (_isPathClear(row, col, targetRow, targetCol)) return true;
          break;
        case ChessPieceType.queen:
          if (rowDistance != 0 && colDistance != 0 && rowDistance.abs() != colDistance.abs()) {
            break;
          }
          if (_isPathClear(row, col, targetRow, targetCol)) return true;
          break;
      }
    }

    return false;
  }

  bool _isPathClear(int fromRow, int fromCol, int toRow, int toCol) {
    final rowStep = (toRow - fromRow).sign;
    final colStep = (toCol - fromCol).sign;
    var row = fromRow + rowStep;
    var col = fromCol + colStep;

    while (row != toRow || col != toCol) {
      if (_board[_indexFromRowCol(row, col)] != null) return false;
      row += rowStep;
      col += colStep;
    }

    return true;
  }

  bool _isInCheck(ChessColor color) {
    final kingIndex = _board.indexWhere(
      (piece) => piece?.color == color && piece?.type == ChessPieceType.king,
    );
    if (kingIndex == -1) return true;

    final opponent = color == ChessColor.white ? ChessColor.black : ChessColor.white;
    return _isSquareAttacked(kingIndex, opponent);
  }

  List<int> _legalMovesForPieceAt(int index, {ChessColor? forColor}) {
    final piece = _board[index];
    if (piece == null || piece.color != (forColor ?? _currentTurn)) {
      return const [];
    }

    final row = index ~/ 8;
    final col = index % 8;
    final moves = <int>[];

    switch (piece.type) {
      case ChessPieceType.pawn:
        final direction = piece.color == ChessColor.white ? -1 : 1;
        final oneStepRow = row + direction;
        if (_isInsideBoard(oneStepRow, col) && _board[_indexFromRowCol(oneStepRow, col)] == null) {
          moves.add(_indexFromRowCol(oneStepRow, col));
          final startRow = piece.color == ChessColor.white ? 6 : 1;
          final twoStepRow = row + direction * 2;
          if (row == startRow && _board[_indexFromRowCol(twoStepRow, col)] == null) {
            moves.add(_indexFromRowCol(twoStepRow, col));
          }
        }
        for (final dc in [-1, 1]) {
          final nextRow = row + direction;
          final nextCol = col + dc;
          if (_isInsideBoard(nextRow, nextCol)) {
            final target = _board[_indexFromRowCol(nextRow, nextCol)];
            if (target != null && target.color != piece.color) {
              moves.add(_indexFromRowCol(nextRow, nextCol));
            }
          }
        }
        break;
      case ChessPieceType.rook:
        for (final delta in [
          [-1, 0],
          [1, 0],
          [0, -1],
          [0, 1],
        ]) {
          var r = row + delta[0];
          var c = col + delta[1];
          while (_isInsideBoard(r, c)) {
            final targetIndex = _indexFromRowCol(r, c);
            final target = _board[targetIndex];
            if (target == null) {
              moves.add(targetIndex);
            } else {
              if (target.color != piece.color) {
                moves.add(targetIndex);
              }
              break;
            }
            r += delta[0];
            c += delta[1];
          }
        }
        break;
      case ChessPieceType.bishop:
        for (final delta in [
          [-1, -1],
          [-1, 1],
          [1, -1],
          [1, 1],
        ]) {
          var r = row + delta[0];
          var c = col + delta[1];
          while (_isInsideBoard(r, c)) {
            final targetIndex = _indexFromRowCol(r, c);
            final target = _board[targetIndex];
            if (target == null) {
              moves.add(targetIndex);
            } else {
              if (target.color != piece.color) {
                moves.add(targetIndex);
              }
              break;
            }
            r += delta[0];
            c += delta[1];
          }
        }
        break;
      case ChessPieceType.knight:
        const knightMoves = [
          [-2, -1],
          [-2, 1],
          [-1, -2],
          [-1, 2],
          [1, -2],
          [1, 2],
          [2, -1],
          [2, 1],
        ];
        for (final move in knightMoves) {
          final r = row + move[0];
          final c = col + move[1];
          if (_isInsideBoard(r, c)) {
            final targetIndex = _indexFromRowCol(r, c);
            final target = _board[targetIndex];
            if (target == null || target.color != piece.color) {
              moves.add(targetIndex);
            }
          }
        }
        break;
      case ChessPieceType.queen:
        for (final delta in [
          [-1, 0],
          [1, 0],
          [0, -1],
          [0, 1],
          [-1, -1],
          [-1, 1],
          [1, -1],
          [1, 1],
        ]) {
          var r = row + delta[0];
          var c = col + delta[1];
          while (_isInsideBoard(r, c)) {
            final targetIndex = _indexFromRowCol(r, c);
            final target = _board[targetIndex];
            if (target == null) {
              moves.add(targetIndex);
            } else {
              if (target.color != piece.color) {
                moves.add(targetIndex);
              }
              break;
            }
            r += delta[0];
            c += delta[1];
          }
        }
        break;
      case ChessPieceType.king:
        for (final dr in [-1, 0, 1]) {
          for (final dc in [-1, 0, 1]) {
            if (dr == 0 && dc == 0) continue;
            final r = row + dr;
            final c = col + dc;
            if (_isInsideBoard(r, c)) {
              final targetIndex = _indexFromRowCol(r, c);
              final target = _board[targetIndex];
              if (target == null || target.color != piece.color) {
                moves.add(targetIndex);
              }
            }
          }
        }
        break;
    }

    return moves.where((moveIndex) {
      final capturedPiece = _board[moveIndex];
      if (capturedPiece?.type == ChessPieceType.king) return false;

      _board[moveIndex] = piece;
      _board[index] = null;
      final leavesKingInCheck = _isInCheck(piece.color);
      _board[index] = piece;
      _board[moveIndex] = capturedPiece;
      return !leavesKingInCheck;
    }).toList();
  }

  bool _hasLegalMove(ChessColor color) {
    for (int index = 0; index < _board.length; index++) {
      if (_board[index]?.color == color &&
          _legalMovesForPieceAt(index, forColor: color).isNotEmpty) {
        return true;
      }
    }
    return false;
  }

  void _handleChessTap(int index) {
    if (_isGameOver) return;

    if (widget.mode == ChessMode.vsAi && _currentTurn == ChessColor.black) {
      return;
    }

    final selectedPiece = _board[index];

    if (_selectedIndex == null) {
      if (selectedPiece != null && selectedPiece.color == _currentTurn) {
        _selectedIndex = index;
        _legalMoves = _legalMovesForPieceAt(index);
        setState(() {});
      }
      return;
    }

    if (selectedPiece != null && selectedPiece.color == _currentTurn) {
      _selectedIndex = index;
      _legalMoves = _legalMovesForPieceAt(index);
      setState(() {});
      return;
    }

    if (_legalMoves.contains(index)) {
      _executeMove(_selectedIndex!, index);
      return;
    }

    _selectedIndex = null;
    _legalMoves = [];
    setState(() {});
  }

  void _executeMove(int from, int to) {
    final movingPiece = _board[from];
    if (movingPiece == null) return;

    _board[to] = movingPiece;
    _board[from] = null;

    if (movingPiece.type == ChessPieceType.pawn &&
        ((movingPiece.color == ChessColor.white && to < 8) ||
            (movingPiece.color == ChessColor.black && to >= 56))) {
      _board[to] = ChessPiece(color: movingPiece.color, type: ChessPieceType.queen);
    }

    _selectedIndex = null;
    _legalMoves = [];

    final nextTurn = _currentTurn == ChessColor.white ? ChessColor.black : ChessColor.white;
    _currentTurn = nextTurn;
    final hasLegalMove = _hasLegalMove(_currentTurn);
    final isInCheck = _isInCheck(_currentTurn);

    if (!hasLegalMove) {
      _isGameOver = true;
      if (isInCheck) {
        _status = 'Шах и мат! ${_currentTurn == ChessColor.white ? 'Чёрные' : 'Белые'} победили';
      } else {
        _status = 'Пат! Ничья';
      }
    } else {
      final turnText = _currentTurn == ChessColor.white ? 'Ход белых' : 'Ход чёрных';
      _status = isInCheck ? 'Шах! $turnText' : turnText;
    }

    if (!_isGameOver && widget.mode == ChessMode.vsAi && _currentTurn == ChessColor.black) {
      _makeAiMove();
    }

    setState(() {});
  }

  void _makeAiMove() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted || widget.mode != ChessMode.vsAi || _isGameOver || _currentTurn != ChessColor.black) {
        return;
      }

      final availableMoves = <ChessMove>[];
      for (int i = 0; i < 64; i++) {
        final piece = _board[i];
        if (piece == null || piece.color != ChessColor.black) continue;
        final moves = _legalMovesForPieceAt(i);
        for (final moveIndex in moves) {
          availableMoves.add(
            ChessMove(
              from: i,
              to: moveIndex,
              piece: piece,
              capturedPiece: _board[moveIndex],
            ),
          );
        }
      }

      if (availableMoves.isEmpty) {
        setState(() {
          _status = 'Белые победили';
          _isGameOver = true;
        });
        return;
      }

      availableMoves.sort((a, b) {
        final aValue = _pieceValue(a.capturedPiece?.type ?? ChessPieceType.pawn) * 10 + _pieceValue(a.piece.type);
        final bValue = _pieceValue(b.capturedPiece?.type ?? ChessPieceType.pawn) * 10 + _pieceValue(b.piece.type);
        return bValue.compareTo(aValue);
      });

      final bestMove = availableMoves.first;
      _executeMove(bestMove.from, bestMove.to);
    });
  }

  int _pieceValue(ChessPieceType type) {
    switch (type) {
      case ChessPieceType.pawn:
        return 1;
      case ChessPieceType.knight:
      case ChessPieceType.bishop:
        return 3;
      case ChessPieceType.rook:
        return 5;
      case ChessPieceType.queen:
        return 9;
      case ChessPieceType.king:
        return 0;
    }
  }

  String _pieceSymbol(ChessPiece piece) {
    const whiteMap = {
      ChessPieceType.pawn: '♙ color: Colors.elevatedButton,',
      ChessPieceType.rook: '♖ color: Colors.elevatedButton,',
      ChessPieceType.knight: '♘ color: Colors.elevatedButton,', 
      ChessPieceType.bishop: '♗ color: Colors.elevatedButton,',
      ChessPieceType.queen: '♕ color: Colors.elevatedButton,',
      ChessPieceType.king: '♔ color: Colors.elevatedButton,',
    };

    const blackMap = {
      ChessPieceType.pawn: '♟',
      ChessPieceType.rook: '♜',
      ChessPieceType.knight: '♞',
      ChessPieceType.bishop: '♝',
      ChessPieceType.queen: '♛',
      ChessPieceType.king: '♚',
    };

    return piece.color == ChessColor.white ? (whiteMap[piece.type] ?? '') : (blackMap[piece.type] ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3E8FF),
      appBar: AppBar(
        title: const Text('Шахматы'),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child:SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  _status,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.indigo),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: 340,
                height: 340,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 64,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 8,
                  ),
                  itemBuilder: (context, index) {
                    final row = index ~/ 8;
                    final col = index % 8;
                    final isDark = (row + col) % 2 == 1;
                    final isSelected = _selectedIndex == index;
                    final isLegalMove = _legalMoves.contains(index);
                    final piece = _board[index];

                    return GestureDetector(
                      onTap: () => _handleChessTap(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.amber.withOpacity(0.9)
                              : isLegalMove
                                  ? Colors.green.withOpacity(0.7)
                                  : isDark
                                      ? Colors.brown.shade300
                                      : Colors.brown.shade100,
                          border: Border.all(color: Colors.black26, width: 0.5),
                        ),
                        child: Center(
                          child: piece == null
                              ? (isLegalMove ? const Icon(Icons.circle, size: 12, color: Colors.black54) : null)
                              : Text(
                                  _pieceSymbol(piece),
                                  style: const TextStyle(fontSize: 28),
                                ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _resetBoard();
                        });
                        if (widget.mode == ChessMode.vsAi && _currentTurn == ChessColor.black) {
                          _makeAiMove();
                        }
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Новая партия'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.home),
                label: const Text('Выбрать игру'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.indigo,
                  side: const BorderSide(color: Colors.indigo, width: 2),
                  padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    )
    );
  }
}
