import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.dark);

void main() {
  runApp(const PatchQuestApp());
}

class PatchQuestApp extends StatelessWidget {
  const PatchQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, child) {
        return MaterialApp(
          title: 'PatchQuest',
          debugShowCheckedModeBanner: false,
          themeMode: currentMode,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF6A0DAD),
              brightness: Brightness.light,
            ),
            useMaterial3: true,
            fontFamily: 'Roboto',
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF6A0DAD),
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
            fontFamily: 'Roboto',
          ),
          home: const SplashScreen(),
        );
      },
    );
  }
}

// ---------------------------------------------------------
// THEME HELPERS
// ---------------------------------------------------------
bool isDark(BuildContext context) => Theme.of(context).brightness == Brightness.dark;
Color bgGradientStart(BuildContext context) => isDark(context) ? const Color(0xFF160B29) : const Color(0xFFEDE7F6);
Color bgGradientEnd(BuildContext context) => isDark(context) ? const Color(0xFF3B1E63) : const Color(0xFFD1C4E9);
Color splashGradientStart(BuildContext context) => isDark(context) ? const Color(0xFF2A0845) : const Color(0xFFE1BEE7);
Color splashGradientEnd(BuildContext context) => isDark(context) ? const Color(0xFF6441A5) : const Color(0xFF9575CD);
Color tColor(BuildContext context) => isDark(context) ? Colors.white : const Color(0xFF311B92);
Color tSecondaryColor(BuildContext context) => isDark(context) ? Colors.white70 : const Color(0xFF5E35B1);
Color cardBgColor(BuildContext context) => isDark(context) ? Colors.white.withAlpha(20) : Colors.white.withAlpha(180);
Color boardBgColor(BuildContext context) => isDark(context) ? const Color(0xFF2A1B54) : Colors.white;
Color cellBgColor(BuildContext context) => isDark(context) ? const Color(0xFF1E133D) : const Color(0xFFF3E5F5);
Color gridLineColor(BuildContext context) => isDark(context) ? Colors.white.withAlpha(20) : Colors.deepPurple.withAlpha(20);
Color legendBgColor(BuildContext context) => isDark(context) ? Colors.black.withAlpha(60) : Colors.white.withAlpha(200);
Color buttonBgColor(BuildContext context) => isDark(context) ? Colors.white.withAlpha(20) : Colors.deepPurple.withAlpha(20);

// ---------------------------------------------------------
// DATA MODELS
// ---------------------------------------------------------

enum PatchShapeType { square, tallRectangle, wideRectangle }
enum Difficulty { easy, medium, hard, expert }

class CellPosition {
  final int row, col;
  const CellPosition(this.row, this.col);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CellPosition && row == other.row && col == other.col;
  @override
  int get hashCode => row.hashCode ^ col.hashCode;
}

class ClueCell {
  final CellPosition position;
  final int number;
  final PatchShapeType shapeType;
  const ClueCell(this.position, {required this.number, required this.shapeType});
}

class PlacedPatch {
  final int minRow, minCol, maxRow, maxCol;

  PlacedPatch(int r1, int c1, int r2, int c2)
      : minRow = r1 < r2 ? r1 : r2,
        maxRow = r1 > r2 ? r1 : r2,
        minCol = c1 < c2 ? c1 : c2,
        maxCol = c1 > c2 ? c1 : c2;

  int get width => maxCol - minCol + 1;
  int get height => maxRow - minRow + 1;
  int get area => width * height;

  bool contains(int row, int col) {
    return row >= minRow && row <= maxRow && col >= minCol && col <= maxCol;
  }

  bool overlaps(PlacedPatch other) {
    if (minRow > other.maxRow || maxRow < other.minRow) return false;
    if (minCol > other.maxCol || maxCol < other.minCol) return false;
    return true;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlacedPatch &&
          minRow == other.minRow &&
          minCol == other.minCol &&
          maxRow == other.maxRow &&
          maxCol == other.maxCol;
  @override
  int get hashCode => minRow.hashCode ^ minCol.hashCode ^ maxRow.hashCode ^ maxCol.hashCode;
}

class PuzzleLevel {
  final String name;
  final int size;
  final List<ClueCell> clues;
  final List<PlacedPatch> solutionPatches;

  const PuzzleLevel({
    required this.name,
    this.size = 6,
    required this.clues,
    required this.solutionPatches,
  });
}

// ---------------------------------------------------------
// LEVEL DATA
// ---------------------------------------------------------

final Map<Difficulty, List<PuzzleLevel>> levelData = {
  Difficulty.easy: [
    PuzzleLevel(
      name: 'Level 1',
      solutionPatches: [
        PlacedPatch(0, 0, 1, 1),
        PlacedPatch(0, 2, 0, 5),
        PlacedPatch(1, 2, 1, 5),
        PlacedPatch(2, 0, 3, 1),
        PlacedPatch(2, 2, 3, 3),
        PlacedPatch(2, 4, 5, 5),
        PlacedPatch(4, 0, 5, 1),
        PlacedPatch(4, 2, 5, 3),
      ],
      clues: [
        const ClueCell(CellPosition(0, 0), number: 4, shapeType: PatchShapeType.square),
        const ClueCell(CellPosition(0, 3), number: 4, shapeType: PatchShapeType.wideRectangle),
        const ClueCell(CellPosition(1, 3), number: 4, shapeType: PatchShapeType.wideRectangle),
        const ClueCell(CellPosition(2, 0), number: 4, shapeType: PatchShapeType.square),
        const ClueCell(CellPosition(2, 2), number: 4, shapeType: PatchShapeType.square),
        const ClueCell(CellPosition(3, 5), number: 8, shapeType: PatchShapeType.tallRectangle),
        const ClueCell(CellPosition(5, 0), number: 4, shapeType: PatchShapeType.square),
        const ClueCell(CellPosition(4, 3), number: 4, shapeType: PatchShapeType.square),
      ],
    ),
    PuzzleLevel(
      name: 'Level 2',
      solutionPatches: [
        PlacedPatch(0, 0, 0, 2),
        PlacedPatch(0, 3, 2, 5),
        PlacedPatch(1, 0, 3, 0),
        PlacedPatch(1, 1, 3, 2),
        PlacedPatch(4, 0, 5, 2),
        PlacedPatch(3, 3, 5, 5),
      ],
      clues: [
        const ClueCell(CellPosition(0, 0), number: 3, shapeType: PatchShapeType.wideRectangle),
        const ClueCell(CellPosition(1, 4), number: 9, shapeType: PatchShapeType.square),
        const ClueCell(CellPosition(2, 0), number: 3, shapeType: PatchShapeType.tallRectangle),
        const ClueCell(CellPosition(2, 1), number: 6, shapeType: PatchShapeType.tallRectangle),
        const ClueCell(CellPosition(5, 1), number: 6, shapeType: PatchShapeType.wideRectangle),
        const ClueCell(CellPosition(4, 4), number: 9, shapeType: PatchShapeType.square),
      ],
    ),
    PuzzleLevel(
      name: 'Level 3',
      solutionPatches: [
        PlacedPatch(0, 0, 2, 1),
        PlacedPatch(3, 0, 5, 1),
        PlacedPatch(0, 2, 1, 5),
        PlacedPatch(2, 2, 5, 3),
        PlacedPatch(2, 4, 5, 5),
      ],
      clues: [
        const ClueCell(CellPosition(1, 0), number: 6, shapeType: PatchShapeType.tallRectangle),
        const ClueCell(CellPosition(4, 1), number: 6, shapeType: PatchShapeType.tallRectangle),
        const ClueCell(CellPosition(0, 3), number: 8, shapeType: PatchShapeType.wideRectangle),
        const ClueCell(CellPosition(3, 2), number: 8, shapeType: PatchShapeType.tallRectangle),
        const ClueCell(CellPosition(4, 5), number: 8, shapeType: PatchShapeType.tallRectangle),
      ],
    ),
    PuzzleLevel(
      name: 'Level 4',
      solutionPatches: [
        PlacedPatch(0, 0, 5, 0),
        PlacedPatch(0, 5, 5, 5),
        PlacedPatch(0, 1, 0, 4),
        PlacedPatch(5, 1, 5, 4),
        PlacedPatch(1, 1, 4, 4),
      ],
      clues: [
        const ClueCell(CellPosition(2, 0), number: 6, shapeType: PatchShapeType.tallRectangle),
        const ClueCell(CellPosition(3, 5), number: 6, shapeType: PatchShapeType.tallRectangle),
        const ClueCell(CellPosition(0, 2), number: 4, shapeType: PatchShapeType.wideRectangle),
        const ClueCell(CellPosition(5, 3), number: 4, shapeType: PatchShapeType.wideRectangle),
        const ClueCell(CellPosition(2, 2), number: 16, shapeType: PatchShapeType.square),
      ],
    ),
  ],
  Difficulty.medium: [
    PuzzleLevel(
      name: 'Level 1',
      solutionPatches: [
        PlacedPatch(0, 0, 2, 0),
        PlacedPatch(0, 1, 1, 3),
        PlacedPatch(0, 4, 0, 5),
        PlacedPatch(1, 4, 5, 5),
        PlacedPatch(2, 1, 3, 1),
        PlacedPatch(2, 2, 3, 3),
        PlacedPatch(3, 0, 5, 0),
        PlacedPatch(4, 1, 5, 1),
        PlacedPatch(4, 2, 5, 3),
      ],
      clues: [
        const ClueCell(CellPosition(1, 0), number: 3, shapeType: PatchShapeType.tallRectangle),
        const ClueCell(CellPosition(0, 2), number: 6, shapeType: PatchShapeType.wideRectangle),
        const ClueCell(CellPosition(0, 5), number: 2, shapeType: PatchShapeType.wideRectangle),
        const ClueCell(CellPosition(3, 4), number: 10, shapeType: PatchShapeType.tallRectangle),
        const ClueCell(CellPosition(2, 1), number: 2, shapeType: PatchShapeType.tallRectangle),
        const ClueCell(CellPosition(2, 2), number: 4, shapeType: PatchShapeType.square),
        const ClueCell(CellPosition(4, 0), number: 3, shapeType: PatchShapeType.tallRectangle),
        const ClueCell(CellPosition(4, 1), number: 2, shapeType: PatchShapeType.tallRectangle),
        const ClueCell(CellPosition(4, 3), number: 4, shapeType: PatchShapeType.square),
      ],
    ),
    PuzzleLevel(
      name: 'Level 2',
      solutionPatches: [
        PlacedPatch(0, 0, 2, 1),
        PlacedPatch(3, 0, 5, 1),
        PlacedPatch(0, 2, 3, 2),
        PlacedPatch(4, 2, 5, 2),
        PlacedPatch(0, 3, 1, 4),
        PlacedPatch(2, 3, 5, 4),
        PlacedPatch(0, 5, 5, 5),
      ],
      clues: [
        const ClueCell(CellPosition(1, 0), number: 6, shapeType: PatchShapeType.tallRectangle),
        const ClueCell(CellPosition(4, 0), number: 6, shapeType: PatchShapeType.tallRectangle),
        const ClueCell(CellPosition(1, 2), number: 4, shapeType: PatchShapeType.tallRectangle),
        const ClueCell(CellPosition(5, 2), number: 2, shapeType: PatchShapeType.tallRectangle),
        const ClueCell(CellPosition(0, 3), number: 4, shapeType: PatchShapeType.square),
        const ClueCell(CellPosition(3, 3), number: 8, shapeType: PatchShapeType.tallRectangle),
        const ClueCell(CellPosition(2, 5), number: 6, shapeType: PatchShapeType.tallRectangle),
      ],
    ),
    PuzzleLevel(
      name: 'Level 3',
      solutionPatches: [
        PlacedPatch(0, 0, 2, 2),
        PlacedPatch(0, 3, 1, 5),
        PlacedPatch(2, 3, 2, 5),
        PlacedPatch(3, 0, 5, 1),
        PlacedPatch(3, 2, 5, 3),
        PlacedPatch(3, 4, 4, 5),
        PlacedPatch(5, 4, 5, 5),
      ],
      clues: [
        const ClueCell(CellPosition(1, 1), number: 9, shapeType: PatchShapeType.square),
        const ClueCell(CellPosition(0, 4), number: 6, shapeType: PatchShapeType.wideRectangle),
        const ClueCell(CellPosition(2, 4), number: 3, shapeType: PatchShapeType.wideRectangle),
        const ClueCell(CellPosition(4, 0), number: 6, shapeType: PatchShapeType.tallRectangle),
        const ClueCell(CellPosition(3, 3), number: 6, shapeType: PatchShapeType.tallRectangle),
        const ClueCell(CellPosition(4, 5), number: 4, shapeType: PatchShapeType.square),
        const ClueCell(CellPosition(5, 4), number: 2, shapeType: PatchShapeType.wideRectangle),
      ],
    ),
    PuzzleLevel(
      name: 'Level 4',
      solutionPatches: [
        PlacedPatch(0, 0, 1, 3),
        PlacedPatch(0, 4, 4, 5),
        PlacedPatch(2, 0, 3, 1),
        PlacedPatch(2, 2, 5, 3),
        PlacedPatch(4, 0, 5, 1),
        PlacedPatch(5, 4, 5, 5),
      ],
      clues: [
        const ClueCell(CellPosition(0, 1), number: 8, shapeType: PatchShapeType.wideRectangle),
        const ClueCell(CellPosition(2, 5), number: 10, shapeType: PatchShapeType.tallRectangle),
        const ClueCell(CellPosition(2, 0), number: 4, shapeType: PatchShapeType.square),
        const ClueCell(CellPosition(4, 3), number: 8, shapeType: PatchShapeType.tallRectangle),
        const ClueCell(CellPosition(5, 1), number: 4, shapeType: PatchShapeType.square),
        const ClueCell(CellPosition(5, 4), number: 2, shapeType: PatchShapeType.wideRectangle),
      ],
    ),
  ],
  Difficulty.hard: [
    PuzzleLevel(
      name: 'Level 1',
      solutionPatches: [
        PlacedPatch(0, 0, 0, 5),
        PlacedPatch(1, 0, 5, 0),
        PlacedPatch(1, 1, 1, 5),
        PlacedPatch(2, 1, 5, 1),
        PlacedPatch(2, 2, 2, 5),
        PlacedPatch(3, 2, 5, 2),
        PlacedPatch(3, 3, 3, 5),
        PlacedPatch(4, 3, 5, 3),
        PlacedPatch(4, 4, 4, 5),
        PlacedPatch(5, 4, 5, 4),
        PlacedPatch(5, 5, 5, 5),
      ],
      clues: [
        const ClueCell(CellPosition(0, 3), number: 6, shapeType: PatchShapeType.wideRectangle),
        const ClueCell(CellPosition(3, 0), number: 5, shapeType: PatchShapeType.tallRectangle),
        const ClueCell(CellPosition(1, 3), number: 5, shapeType: PatchShapeType.wideRectangle),
        const ClueCell(CellPosition(4, 1), number: 4, shapeType: PatchShapeType.tallRectangle),
        const ClueCell(CellPosition(2, 3), number: 4, shapeType: PatchShapeType.wideRectangle),
        const ClueCell(CellPosition(4, 2), number: 3, shapeType: PatchShapeType.tallRectangle),
        const ClueCell(CellPosition(3, 4), number: 3, shapeType: PatchShapeType.wideRectangle),
        const ClueCell(CellPosition(4, 3), number: 2, shapeType: PatchShapeType.tallRectangle),
        const ClueCell(CellPosition(4, 4), number: 2, shapeType: PatchShapeType.wideRectangle),
        const ClueCell(CellPosition(5, 4), number: 1, shapeType: PatchShapeType.square),
        const ClueCell(CellPosition(5, 5), number: 1, shapeType: PatchShapeType.square),
      ],
    ),
    PuzzleLevel(
      name: 'Level 2',
      solutionPatches: [
        PlacedPatch(0, 0, 2, 2),
        PlacedPatch(0, 3, 1, 5),
        PlacedPatch(2, 3, 5, 4),
        PlacedPatch(2, 5, 5, 5),
        PlacedPatch(3, 0, 4, 2),
        PlacedPatch(5, 0, 5, 2),
      ],
      clues: [
        const ClueCell(CellPosition(1, 1), number: 9, shapeType: PatchShapeType.square),
        const ClueCell(CellPosition(0, 4), number: 6, shapeType: PatchShapeType.wideRectangle),
        const ClueCell(CellPosition(3, 3), number: 8, shapeType: PatchShapeType.tallRectangle),
        const ClueCell(CellPosition(4, 5), number: 4, shapeType: PatchShapeType.tallRectangle),
        const ClueCell(CellPosition(3, 1), number: 6, shapeType: PatchShapeType.wideRectangle),
        const ClueCell(CellPosition(5, 1), number: 3, shapeType: PatchShapeType.wideRectangle),
      ],
    ),
    PuzzleLevel(
      name: 'Level 3',
      solutionPatches: [
        PlacedPatch(0, 0, 0, 5),
        PlacedPatch(1, 0, 1, 2),
        PlacedPatch(1, 3, 1, 3),
        PlacedPatch(1, 4, 1, 5),
        PlacedPatch(2, 0, 2, 0),
        PlacedPatch(2, 1, 2, 4),
        PlacedPatch(2, 5, 2, 5),
        PlacedPatch(3, 0, 3, 1),
        PlacedPatch(3, 2, 3, 3),
        PlacedPatch(3, 4, 3, 5),
        PlacedPatch(4, 0, 5, 1),
        PlacedPatch(4, 2, 5, 3),
        PlacedPatch(4, 4, 5, 5),
      ],
      clues: [
        const ClueCell(CellPosition(0, 2), number: 6, shapeType: PatchShapeType.wideRectangle),
        const ClueCell(CellPosition(1, 1), number: 3, shapeType: PatchShapeType.wideRectangle),
        const ClueCell(CellPosition(1, 3), number: 1, shapeType: PatchShapeType.square),
        const ClueCell(CellPosition(1, 4), number: 2, shapeType: PatchShapeType.wideRectangle),
        const ClueCell(CellPosition(2, 0), number: 1, shapeType: PatchShapeType.square),
        const ClueCell(CellPosition(2, 3), number: 4, shapeType: PatchShapeType.wideRectangle),
        const ClueCell(CellPosition(2, 5), number: 1, shapeType: PatchShapeType.square),
        const ClueCell(CellPosition(3, 0), number: 2, shapeType: PatchShapeType.wideRectangle),
        const ClueCell(CellPosition(3, 3), number: 2, shapeType: PatchShapeType.wideRectangle),
        const ClueCell(CellPosition(3, 4), number: 2, shapeType: PatchShapeType.wideRectangle),
        const ClueCell(CellPosition(4, 1), number: 4, shapeType: PatchShapeType.square),
        const ClueCell(CellPosition(5, 2), number: 4, shapeType: PatchShapeType.square),
        const ClueCell(CellPosition(4, 5), number: 4, shapeType: PatchShapeType.square),
      ],
    ),
    PuzzleLevel(
      name: 'Level 4',
      solutionPatches: [
        PlacedPatch(0, 0, 5, 0),
        PlacedPatch(0, 1, 0, 1),
        PlacedPatch(1, 1, 5, 1),
        PlacedPatch(0, 2, 1, 2),
        PlacedPatch(2, 2, 5, 2),
        PlacedPatch(0, 3, 2, 3),
        PlacedPatch(3, 3, 5, 3),
        PlacedPatch(0, 4, 3, 4),
        PlacedPatch(4, 4, 5, 4),
        PlacedPatch(0, 5, 4, 5),
        PlacedPatch(5, 5, 5, 5),
      ],
      clues: [
        const ClueCell(CellPosition(3, 0), number: 6, shapeType: PatchShapeType.tallRectangle),
        const ClueCell(CellPosition(0, 1), number: 1, shapeType: PatchShapeType.square),
        const ClueCell(CellPosition(4, 1), number: 5, shapeType: PatchShapeType.tallRectangle),
        const ClueCell(CellPosition(1, 2), number: 2, shapeType: PatchShapeType.tallRectangle),
        const ClueCell(CellPosition(3, 2), number: 4, shapeType: PatchShapeType.tallRectangle),
        const ClueCell(CellPosition(0, 3), number: 3, shapeType: PatchShapeType.tallRectangle),
        const ClueCell(CellPosition(5, 3), number: 3, shapeType: PatchShapeType.tallRectangle),
        const ClueCell(CellPosition(2, 4), number: 4, shapeType: PatchShapeType.tallRectangle),
        const ClueCell(CellPosition(4, 4), number: 2, shapeType: PatchShapeType.tallRectangle),
        const ClueCell(CellPosition(1, 5), number: 5, shapeType: PatchShapeType.tallRectangle),
        const ClueCell(CellPosition(5, 5), number: 1, shapeType: PatchShapeType.square),
      ],
    ),
  ],
  Difficulty.expert: [
    PuzzleLevel(
      name: 'Level 1',
      solutionPatches: [
        PlacedPatch(0, 0, 0, 1), 
        PlacedPatch(0, 2, 1, 3), 
        PlacedPatch(0, 4, 0, 5), 
        PlacedPatch(1, 0, 3, 0), 
        PlacedPatch(1, 1, 3, 1), 
        PlacedPatch(1, 4, 2, 5), 
        PlacedPatch(2, 2, 2, 3), 
        PlacedPatch(3, 2, 4, 3), 
        PlacedPatch(3, 4, 4, 5), 
        PlacedPatch(4, 0, 4, 1), 
        PlacedPatch(5, 0, 5, 1), 
        PlacedPatch(5, 2, 5, 3), 
        PlacedPatch(5, 4, 5, 5), 
      ],
      clues: [
        const ClueCell(CellPosition(0, 0), number: 2, shapeType: PatchShapeType.wideRectangle),
        const ClueCell(CellPosition(1, 3), number: 4, shapeType: PatchShapeType.square),
        const ClueCell(CellPosition(0, 4), number: 2, shapeType: PatchShapeType.wideRectangle),
        const ClueCell(CellPosition(2, 0), number: 3, shapeType: PatchShapeType.tallRectangle),
        const ClueCell(CellPosition(3, 1), number: 3, shapeType: PatchShapeType.tallRectangle),
        const ClueCell(CellPosition(2, 5), number: 4, shapeType: PatchShapeType.square),
        const ClueCell(CellPosition(2, 2), number: 2, shapeType: PatchShapeType.wideRectangle),
        const ClueCell(CellPosition(3, 3), number: 4, shapeType: PatchShapeType.square),
        const ClueCell(CellPosition(3, 4), number: 4, shapeType: PatchShapeType.square),
        const ClueCell(CellPosition(4, 0), number: 2, shapeType: PatchShapeType.wideRectangle),
        const ClueCell(CellPosition(5, 1), number: 2, shapeType: PatchShapeType.wideRectangle),
        const ClueCell(CellPosition(5, 2), number: 2, shapeType: PatchShapeType.wideRectangle),
        const ClueCell(CellPosition(5, 5), number: 2, shapeType: PatchShapeType.wideRectangle),
      ],
    ),
    PuzzleLevel(
      name: 'Level 2',
      solutionPatches: [
        PlacedPatch(0, 0, 2, 2), 
        PlacedPatch(0, 3, 3, 3), 
        PlacedPatch(0, 4, 2, 5), 
        PlacedPatch(3, 0, 3, 2), 
        PlacedPatch(3, 4, 3, 4), 
        PlacedPatch(4, 0, 5, 1), 
        PlacedPatch(4, 2, 5, 3), 
        PlacedPatch(4, 4, 5, 4), 
        PlacedPatch(3, 5, 5, 5), 
      ],
      clues: [
        const ClueCell(CellPosition(1, 1), number: 9, shapeType: PatchShapeType.square),
        const ClueCell(CellPosition(2, 3), number: 4, shapeType: PatchShapeType.tallRectangle),
        const ClueCell(CellPosition(1, 5), number: 6, shapeType: PatchShapeType.tallRectangle),
        const ClueCell(CellPosition(3, 0), number: 3, shapeType: PatchShapeType.wideRectangle),
        const ClueCell(CellPosition(3, 4), number: 1, shapeType: PatchShapeType.square),
        const ClueCell(CellPosition(5, 0), number: 4, shapeType: PatchShapeType.square),
        const ClueCell(CellPosition(4, 2), number: 4, shapeType: PatchShapeType.square),
        const ClueCell(CellPosition(5, 4), number: 2, shapeType: PatchShapeType.tallRectangle),
        const ClueCell(CellPosition(4, 5), number: 3, shapeType: PatchShapeType.tallRectangle),
      ],
    ),
    PuzzleLevel(
      name: 'Level 3',
      solutionPatches: [
        PlacedPatch(0, 0, 0, 4),
        PlacedPatch(0, 5, 1, 5),
        PlacedPatch(1, 0, 2, 0),
        PlacedPatch(1, 1, 1, 3),
        PlacedPatch(1, 4, 3, 4),
        PlacedPatch(2, 1, 4, 1),
        PlacedPatch(2, 2, 2, 3),
        PlacedPatch(2, 5, 5, 5),
        PlacedPatch(3, 0, 5, 0),
        PlacedPatch(3, 2, 4, 2),
        PlacedPatch(3, 3, 4, 3),
        PlacedPatch(4, 4, 5, 4),
        PlacedPatch(5, 1, 5, 3),
      ],
      clues: [
        const ClueCell(CellPosition(0, 2), number: 5, shapeType: PatchShapeType.wideRectangle),
        const ClueCell(CellPosition(0, 5), number: 2, shapeType: PatchShapeType.tallRectangle),
        const ClueCell(CellPosition(2, 0), number: 2, shapeType: PatchShapeType.tallRectangle),
        const ClueCell(CellPosition(1, 1), number: 3, shapeType: PatchShapeType.wideRectangle),
        const ClueCell(CellPosition(2, 4), number: 3, shapeType: PatchShapeType.tallRectangle),
        const ClueCell(CellPosition(3, 1), number: 3, shapeType: PatchShapeType.tallRectangle),
        const ClueCell(CellPosition(2, 3), number: 2, shapeType: PatchShapeType.wideRectangle),
        const ClueCell(CellPosition(5, 5), number: 4, shapeType: PatchShapeType.tallRectangle),
        const ClueCell(CellPosition(4, 0), number: 3, shapeType: PatchShapeType.tallRectangle),
        const ClueCell(CellPosition(3, 2), number: 2, shapeType: PatchShapeType.tallRectangle),
        const ClueCell(CellPosition(4, 3), number: 2, shapeType: PatchShapeType.tallRectangle),
        const ClueCell(CellPosition(5, 4), number: 2, shapeType: PatchShapeType.tallRectangle),
        const ClueCell(CellPosition(5, 2), number: 3, shapeType: PatchShapeType.wideRectangle),
      ],
    ),
    PuzzleLevel(
      name: 'Level 4',
      solutionPatches: [
        PlacedPatch(0, 0, 0, 2),
        PlacedPatch(0, 3, 1, 3),
        PlacedPatch(0, 4, 0, 5),
        PlacedPatch(1, 0, 3, 0),
        PlacedPatch(1, 1, 2, 2),
        PlacedPatch(1, 4, 3, 4),
        PlacedPatch(1, 5, 2, 5),
        PlacedPatch(2, 3, 5, 3),
        PlacedPatch(3, 1, 3, 2),
        PlacedPatch(3, 5, 3, 5),
        PlacedPatch(4, 0, 4, 1),
        PlacedPatch(4, 2, 5, 2),
        PlacedPatch(4, 4, 5, 5),
        PlacedPatch(5, 0, 5, 1),
      ],
      clues: [
        const ClueCell(CellPosition(0, 0), number: 3, shapeType: PatchShapeType.wideRectangle),
        const ClueCell(CellPosition(0, 3), number: 2, shapeType: PatchShapeType.tallRectangle),
        const ClueCell(CellPosition(0, 5), number: 2, shapeType: PatchShapeType.wideRectangle),
        const ClueCell(CellPosition(1, 0), number: 4, shapeType: PatchShapeType.tallRectangle),
        const ClueCell(CellPosition(2, 2), number: 4, shapeType: PatchShapeType.square),
        const ClueCell(CellPosition(1, 4), number: 3, shapeType: PatchShapeType.tallRectangle),
        const ClueCell(CellPosition(2, 5), number: 2, shapeType: PatchShapeType.tallRectangle),
        const ClueCell(CellPosition(4, 3), number: 4, shapeType: PatchShapeType.tallRectangle),
        const ClueCell(CellPosition(3, 1), number: 2, shapeType: PatchShapeType.wideRectangle),
        const ClueCell(CellPosition(3, 5), number: 1, shapeType: PatchShapeType.square),
        const ClueCell(CellPosition(4, 0), number: 2, shapeType: PatchShapeType.wideRectangle),
        const ClueCell(CellPosition(5, 2), number: 2, shapeType: PatchShapeType.tallRectangle),
        const ClueCell(CellPosition(5, 5), number: 4, shapeType: PatchShapeType.square),
        const ClueCell(CellPosition(5, 1), number: 2, shapeType: PatchShapeType.wideRectangle),
      ],
    ),
  ],
};

const List<Color> patchColors = [
  Color(0xFFE57373), Color(0xFF81C784), Color(0xFF64B5F6), Color(0xFFFFB74D),
  Color(0xFFBA68C8), Color(0xFF4DD0E1), Color(0xFFFF8A65), Color(0xFFAED581),
  Color(0xFFF06292), Color(0xFF90A4AE), Color(0xFFFFF176),
];

void validateLevels() {
  levelData.forEach((diff, list) {
    for (int i = 0; i < list.length; i++) {
      final level = list[i];
      int totalArea = 0;
      for (var p in level.solutionPatches) {
        totalArea += p.area;
        int clueCount = level.clues.where((c) => p.contains(c.position.row, c.position.col)).length;
        if (clueCount != 1) {
          debugPrint('$diff L${i + 1} ERROR: solution patch $p has $clueCount clues!');
        } else {
          final clue = level.clues.firstWhere((c) => p.contains(c.position.row, c.position.col));
          if (clue.number != p.area) {
            debugPrint('$diff L${i + 1} ERROR: patch area ${p.area} != clue ${clue.number}');
          }
          final s = clue.shapeType;
          if (s == PatchShapeType.square && p.width != p.height) {
            debugPrint('$diff L${i + 1} ERROR: shape mismatch (square on $p)');
          }
          if (s == PatchShapeType.tallRectangle && p.height <= p.width) {
            debugPrint('$diff L${i + 1} ERROR: shape mismatch (tall on $p)');
          }
          if (s == PatchShapeType.wideRectangle && p.width <= p.height) {
            debugPrint('$diff L${i + 1} ERROR: shape mismatch (wide on $p)');
          }
        }
      }
      if (totalArea != level.size * level.size) {
        debugPrint('$diff L${i + 1} ERROR: total area is $totalArea');
      }
      for (int j = 0; j < level.solutionPatches.length; j++) {
        for (int k = j + 1; k < level.solutionPatches.length; k++) {
          if (level.solutionPatches[j].overlaps(level.solutionPatches[k])) {
            debugPrint('$diff L${i + 1} ERROR: overlaps in solution!');
          }
        }
      }
    }
  });
}

// ---------------------------------------------------------
// SCREENS
// ---------------------------------------------------------

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _introController;
  late AnimationController _spinController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    validateLevels();

    _introController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(CurvedAnimation(parent: _introController, curve: Curves.easeOutBack));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _introController, curve: Curves.easeIn));

    _spinController = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();

    _introController.forward();

    Timer(const Duration(milliseconds: 3000), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const DashboardScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _introController.dispose();
    _spinController.dispose();
    super.dispose();
  }

  Widget _buildFloatingShape(IconData icon, double x, double y, double size, Color color, bool reverse) {
    return Positioned(
      left: x,
      top: y,
      child: AnimatedBuilder(
        animation: _spinController,
        builder: (context, child) {
          return Transform.rotate(
            angle: (reverse ? -1 : 1) * _spinController.value * 2 * 3.14159,
            child: Opacity(
              opacity: 0.15,
              child: Icon(icon, size: size, color: color),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [splashGradientStart(context), splashGradientEnd(context)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            _buildFloatingShape(Icons.crop_square, size.width * 0.1, size.height * 0.2, 100, Colors.pinkAccent, false),
            _buildFloatingShape(Icons.crop_portrait, size.width * 0.7, size.height * 0.1, 80, Colors.amber, true),
            _buildFloatingShape(Icons.crop_landscape, size.width * 0.8, size.height * 0.7, 120, Colors.lightBlueAccent, false),
            _buildFloatingShape(Icons.crop_square, size.width * 0.15, size.height * 0.75, 70, Colors.greenAccent, true),
            
            Center(
              child: AnimatedBuilder(
                animation: _introController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeAnimation.value,
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedBuilder(
                            animation: _spinController,
                            builder: (context, child) {
                              final scale = 1.0 + 0.05 * math.sin(_spinController.value * 2 * 3.14159);
                              return Transform.scale(
                                scale: scale,
                                child: Container(
                                  width: 140,
                                  height: 140,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(40),
                                    boxShadow: [
                                      BoxShadow(color: isDark(context) ? Colors.black.withAlpha(80) : Colors.deepPurple.withAlpha(20), blurRadius: 40, spreadRadius: 10),
                                    ],
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: Image.asset(
                                    isDark(context) ? 'assets/logo_dark.png' : 'assets/logo_light.png',
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: isDark(context) ? const Color(0xFF1E133D) : Colors.white,
                                        child: Center(child: Icon(Icons.dashboard_customize, size: 80, color: tColor(context))),
                                      );
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'PatchQuest',
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: tColor(context),
                              letterSpacing: 3,
                              shadows: [
                                Shadow(color: isDark(context) ? Colors.black45 : Colors.black12, blurRadius: 10, offset: const Offset(0, 4)),
                              ]
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Shape the grid. Solve the logic.',
                            style: TextStyle(
                              fontSize: 18,
                              color: tSecondaryColor(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  void _showHowToPlay(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark(context) ? const Color(0xFF1E133D) : const Color(0xFFF3E5F5),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('How to Play', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: tColor(context))),
              const SizedBox(height: 16),
              _ruleRow(context, Icons.touch_app, 'Drag across the board to create rectangular patches.'),
              _ruleRow(context, Icons.looks_one, 'Every patch must contain exactly ONE clue.'),
              _ruleRow(context, Icons.format_list_numbered, 'The NUMBER tells you the exact area of the patch.'),
              _ruleRow(context, Icons.shape_line, 'The ICON tells you the patch shape.'),
              const SizedBox(height: 8),
              _shapeRule(context, Icons.crop_square, 'Square: width equals height.'),
              _shapeRule(context, Icons.crop_portrait, 'Tall: height is greater than width.'),
              _shapeRule(context, Icons.crop_landscape, 'Wide: width is greater than height.'),
              const SizedBox(height: 16),
              _ruleRow(context, Icons.grid_on, 'Fill the entire board with no gaps and no overlaps!'),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6441A5), foregroundColor: Colors.white),
                  child: const Text('Got it!'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _ruleRow(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.amber, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: TextStyle(color: tSecondaryColor(context), fontSize: 14))),
        ],
      ),
    );
  }

  Widget _shapeRule(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 32.0, bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, color: tColor(context), size: 16),
          const SizedBox(width: 8),
          Text(text, style: TextStyle(color: tSecondaryColor(context), fontSize: 13)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [bgGradientStart(context), bgGradientEnd(context)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: IconButton(
                    icon: Icon(isDark(context) ? Icons.light_mode : Icons.dark_mode, color: tColor(context)),
                    onPressed: () {
                      themeNotifier.value = isDark(context) ? ThemeMode.light : ThemeMode.dark;
                    },
                  ),
                ),
              ),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: isDark(context) ? Colors.black45 : Colors.deepPurple.withAlpha(50), blurRadius: 12, offset: const Offset(0, 6)),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.asset(
                  isDark(context) ? 'assets/logo_dark.png' : 'assets/logo_light.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.dashboard_customize, size: 48, color: tColor(context));
                  },
                ),
              ),
              const SizedBox(height: 12),
              Text('PatchQuest', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: tColor(context))),
              const SizedBox(height: 4),
              Text('Shape the grid. Solve the logic.', style: TextStyle(color: tSecondaryColor(context), fontSize: 15)),
              const SizedBox(height: 32),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Expanded(child: _buildDifficultyCard(context, Difficulty.easy, 'Easy', Icons.sentiment_satisfied, Colors.green)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildDifficultyCard(context, Difficulty.medium, 'Medium', Icons.sentiment_neutral, Colors.orange)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _buildDifficultyCard(context, Difficulty.hard, 'Hard', Icons.whatshot, Colors.deepOrange)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildDifficultyCard(context, Difficulty.expert, 'Expert', Icons.psychology, Colors.redAccent)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0, top: 16.0),
                child: OutlinedButton.icon(
                  onPressed: () => _showHowToPlay(context),
                  icon: Icon(Icons.help_outline, color: tColor(context)),
                  label: Text('How to Play', style: TextStyle(color: tColor(context))),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: tSecondaryColor(context)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultyCard(BuildContext context, Difficulty diff, String title, IconData icon, Color color) {
    final levels = levelData[diff]!;
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => GameScreen(difficulty: diff, levelIndex: 0)));
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: cardBgColor(context),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isDark(context) ? Colors.white.withAlpha(30) : Colors.deepPurple.withAlpha(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withAlpha(50), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 16),
            Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: tColor(context))),
            const SizedBox(height: 4),
            Text('${levels.length} Levels', style: TextStyle(color: tSecondaryColor(context), fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

class GameScreen extends StatefulWidget {
  final Difficulty difficulty;
  final int levelIndex;

  const GameScreen({super.key, required this.difficulty, required this.levelIndex});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late Difficulty _difficulty;
  late int _levelIndex;
  
  List<PlacedPatch> placedPatches = [];

  int? _dragStartRow;
  int? _dragStartCol;
  int? _dragCurrentRow;
  int? _dragCurrentCol;

  Timer? _timer;
  int _secondsElapsed = 0;
  
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _difficulty = widget.difficulty;
    _levelIndex = widget.levelIndex;
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _secondsElapsed = 0;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _secondsElapsed++;
      });
    });
  }

  PuzzleLevel get currentLevel => levelData[_difficulty]![_levelIndex];

  String _formatTime(int seconds) {
    int m = seconds ~/ 60;
    int s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  bool _isPatchValid(PlacedPatch patch, List<PlacedPatch> others) {
    int clueCount = 0;
    ClueCell? containedClue;
    for (var clue in currentLevel.clues) {
      if (patch.contains(clue.position.row, clue.position.col)) {
        clueCount++;
        containedClue = clue;
      }
    }
    if (clueCount != 1) return false;
    if (patch.area != containedClue!.number) return false;

    final s = containedClue.shapeType;
    if (s == PatchShapeType.square && patch.width != patch.height) return false;
    if (s == PatchShapeType.tallRectangle && patch.height <= patch.width) return false;
    if (s == PatchShapeType.wideRectangle && patch.width <= patch.height) return false;

    for (var other in others) {
      if (patch.overlaps(other)) return false;
    }

    return true;
  }

  void _hideErrorAfterDelay() {
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _errorMessage = null;
        });
      }
    });
  }

  void _showSuccessDialog() {
    final bool isLastLevel = _levelIndex == levelData[_difficulty]!.length - 1;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: boardBgColor(context),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(isLastLevel ? 'Difficulty Completed!' : 'Puzzle Solved!', style: TextStyle(color: tColor(context), fontWeight: FontWeight.bold)),
          content: Text('Time taken: ${_formatTime(_secondsElapsed)}', style: TextStyle(color: tSecondaryColor(context))),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); 
                Navigator.of(context).pop(); 
              },
              child: Text('Back to Dashboard', style: TextStyle(color: tSecondaryColor(context))),
            ),
            if (!isLastLevel)
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    _levelIndex++;
                    _resetBoard();
                    _startTimer();
                  });
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6441A5), foregroundColor: Colors.white),
                child: const Text('Next Level'),
              ),
          ],
        );
      },
    );
  }

  void _resetBoard() {
    setState(() {
      placedPatches.clear();
      _errorMessage = null;
      _clearDrag();
    });
  }

  void _undo() {
    if (placedPatches.isNotEmpty) {
      setState(() {
        placedPatches.removeLast();
        _errorMessage = null;
      });
    }
  }
  
  void _hint() {
    for (var sp in currentLevel.solutionPatches) {
      if (!placedPatches.contains(sp)) {
        setState(() {
          placedPatches.removeWhere((p) => p.overlaps(sp));
          placedPatches.add(sp);
          _errorMessage = null;
        });
        int totalArea = placedPatches.fold(0, (sum, p) => sum + p.area);
        if (totalArea == currentLevel.size * currentLevel.size) {
          _timer?.cancel();
          _showSuccessDialog();
        }
        break;
      }
    }
  }

  IconData _getShapeIcon(PatchShapeType type) {
    switch (type) {
      case PatchShapeType.square: return Icons.crop_square;
      case PatchShapeType.tallRectangle: return Icons.crop_portrait;
      case PatchShapeType.wideRectangle: return Icons.crop_landscape;
    }
  }
  
  void _clearDrag() {
    _dragStartRow = null;
    _dragStartCol = null;
    _dragCurrentRow = null;
    _dragCurrentCol = null;
  }
  
  void _onPanStart(DragStartDetails details, double cellWidth) {
    final row = (details.localPosition.dy / cellWidth).floor();
    final col = (details.localPosition.dx / cellWidth).floor();
    if (row >= 0 && row < currentLevel.size && col >= 0 && col < currentLevel.size) {
      final existingIndex = placedPatches.lastIndexWhere((p) => p.contains(row, col));
      if (existingIndex != -1) {
        setState(() {
          placedPatches.removeAt(existingIndex);
          _clearDrag(); 
        });
        return;
      }
      setState(() {
        _dragStartRow = row;
        _dragStartCol = col;
        _dragCurrentRow = row;
        _dragCurrentCol = col;
      });
    }
  }

  void _onPanUpdate(DragUpdateDetails details, double cellWidth) {
    if (_dragStartRow == null) return;
    final row = (details.localPosition.dy / cellWidth).floor().clamp(0, currentLevel.size - 1);
    final col = (details.localPosition.dx / cellWidth).floor().clamp(0, currentLevel.size - 1);
    if (_dragCurrentRow != row || _dragCurrentCol != col) {
      setState(() {
        _dragCurrentRow = row;
        _dragCurrentCol = col;
      });
    }
  }

  void _onPanEnd(DragEndDetails details) {
    if (_dragStartRow != null && _dragCurrentRow != null) {
      final patch = PlacedPatch(
        _dragStartRow!,
        _dragStartCol!,
        _dragCurrentRow!,
        _dragCurrentCol!,
      );

      // Validate patch before committing
      int clueCount = 0;
      ClueCell? containedClue;
      for (var clue in currentLevel.clues) {
        if (patch.contains(clue.position.row, clue.position.col)) {
          clueCount++;
          containedClue = clue;
        }
      }

      String? error;
      if (clueCount == 0) {
        error = 'A patch must contain exactly one clue.';
      } else if (clueCount > 1) {
        error = 'A patch cannot contain multiple clues.';
      } else {
        for (var other in placedPatches) {
          if (patch.overlaps(other)) {
            error = 'Patches cannot overlap.';
            break;
          }
        }
        if (error == null) {
          if (patch.area != containedClue!.number) {
            error = 'Patch area must match clue number.';
          } else {
            final s = containedClue.shapeType;
            if (s == PatchShapeType.square && patch.width != patch.height) {
              error = 'Clue requires a square shape.';
            } else if (s == PatchShapeType.tallRectangle && patch.height <= patch.width) {
              error = 'Clue requires a tall rectangle.';
            } else if (s == PatchShapeType.wideRectangle && patch.width <= patch.height) {
              error = 'Clue requires a wide rectangle.';
            }
          }
        }
      }

      setState(() {
        if (error == null) {
          placedPatches.add(patch);
          _errorMessage = null;
        } else {
          _errorMessage = error;
          _hideErrorAfterDelay();
        }
        _clearDrag();
      });

      if (error == null) {
        int totalArea = placedPatches.fold(0, (sum, p) => sum + p.area);
        if (totalArea == currentLevel.size * currentLevel.size) {
          _timer?.cancel();
          _showSuccessDialog();
        }
      }
    }
  }

  String get _difficultyName {
    switch (_difficulty) {
      case Difficulty.easy: return "Easy";
      case Difficulty.medium: return "Medium";
      case Difficulty.hard: return "Hard";
      case Difficulty.expert: return "Expert";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [bgGradientStart(context), bgGradientEnd(context)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Hero(
                            tag: 'board',
                            child: Material(
                              color: Colors.transparent,
                              child: _buildBoardCard(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildLegend(),
                        const SizedBox(height: 8),
                        _buildInlineError(),
                        const SizedBox(height: 8),
                        _buildControls(),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back, color: tColor(context)),
                onPressed: () => Navigator.pop(context),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_difficultyName, style: const TextStyle(color: Colors.amber, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  Text(currentLevel.name, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: tColor(context))),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: legendBgColor(context),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: gridLineColor(context)),
            ),
            child: Row(
              children: [
                Icon(Icons.timer, size: 16, color: tSecondaryColor(context)),
                const SizedBox(width: 6),
                Text(_formatTime(_secondsElapsed), style: TextStyle(fontSize: 16, color: tColor(context), fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBoardCard() {
    return Container(
      decoration: BoxDecoration(
        color: boardBgColor(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark(context) ? Colors.black.withAlpha(100) : Colors.deepPurple.withAlpha(40), 
            blurRadius: 20, 
            offset: const Offset(0, 10)
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: AspectRatio(
        aspectRatio: 1,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final cellWidth = constraints.maxWidth / currentLevel.size;
            return GestureDetector(
              onPanStart: (d) => _onPanStart(d, cellWidth),
              onPanUpdate: (d) => _onPanUpdate(d, cellWidth),
              onPanEnd: _onPanEnd,
              child: Container(
                decoration: BoxDecoration(
                  color: cellBgColor(context),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: gridLineColor(context), width: 1),
                ),
                clipBehavior: Clip.hardEdge,
                child: Stack(
                  children: [
                    _buildGridLines(cellWidth),
                    for (int i = 0; i < placedPatches.length; i++)
                      _buildPatch(placedPatches[i], cellWidth, patchColors[i % patchColors.length], true, i),
                    if (_dragStartRow != null && _dragCurrentRow != null)
                      _buildPatch(
                        PlacedPatch(_dragStartRow!, _dragStartCol!, _dragCurrentRow!, _dragCurrentCol!),
                        cellWidth,
                        isDark(context) ? Colors.white.withAlpha(60) : Colors.deepPurple.withAlpha(40),
                        true,
                        -1,
                      ),
                    _buildClues(cellWidth),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildGridLines(double cellWidth) {
    final size = currentLevel.size;
    List<Widget> lines = [];
    for (int i = 1; i < size; i++) {
      lines.add(Positioned(
        left: i * cellWidth, top: 0, bottom: 0, width: 1,
        child: Container(color: gridLineColor(context)),
      ));
      lines.add(Positioned(
        top: i * cellWidth, left: 0, right: 0, height: 1,
        child: Container(color: gridLineColor(context)),
      ));
    }
    return Stack(children: lines);
  }

  Widget _buildPatch(PlacedPatch patch, double cellWidth, Color color, bool checkValidity, int index) {
    bool isInvalid = false;
    if (checkValidity) {
      final others = List<PlacedPatch>.from(placedPatches);
      if (index >= 0) {
        others.removeAt(index);
      }
      isInvalid = !_isPatchValid(patch, others);
    }

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOutCubic,
      top: patch.minRow * cellWidth,
      left: patch.minCol * cellWidth,
      width: patch.width * cellWidth,
      height: patch.height * cellWidth,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: isInvalid ? Colors.redAccent.withAlpha(180) : color.withAlpha(220),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isInvalid ? Colors.red : (isDark(context) ? Colors.white.withAlpha(150) : Colors.white.withAlpha(200)),
            width: isInvalid ? 3 : 2,
          ),
          boxShadow: checkValidity && !isInvalid ? [
            BoxShadow(color: color.withAlpha(100), blurRadius: 8, spreadRadius: 1)
          ] : [],
        ),
      ),
    );
  }

  Widget _buildClues(double cellWidth) {
    List<Widget> clues = [];
    for (var clue in currentLevel.clues) {
      clues.add(
        Positioned(
          top: clue.position.row * cellWidth,
          left: clue.position.col * cellWidth,
          width: cellWidth,
          height: cellWidth,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  clue.number.toString(),
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, height: 1.0, color: tColor(context)),
                ),
                Icon(_getShapeIcon(clue.shapeType), size: 18, color: tSecondaryColor(context)),
              ],
            ),
          ),
        ),
      );
    }
    return Stack(children: clues);
  }

  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        decoration: BoxDecoration(
          color: legendBgColor(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: gridLineColor(context)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _legendItem(Icons.crop_square, 'Square'),
            _legendItem(Icons.crop_portrait, 'Tall'),
            _legendItem(Icons.crop_landscape, 'Wide'),
          ],
        ),
      ),
    );
  }

  Widget _legendItem(IconData icon, String text) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: tSecondaryColor(context)),
        const SizedBox(height: 2),
        Text(text, style: TextStyle(fontSize: 12, color: tSecondaryColor(context))),
      ],
    );
  }

  Widget _buildInlineError() {
    return Container(
      height: 20,
      alignment: Alignment.center,
      child: _errorMessage != null
          ? Text(_errorMessage!, style: const TextStyle(color: Colors.redAccent, fontSize: 14, fontWeight: FontWeight.bold))
          : const SizedBox(),
    );
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _controlButton(Icons.refresh, 'Reset', _resetBoard),
          _controlButton(Icons.undo, 'Undo', placedPatches.isNotEmpty ? _undo : null),
          _controlButton(Icons.lightbulb_outline, 'Hint', _hint),
        ],
      ),
    );
  }

  Widget _controlButton(IconData icon, String label, VoidCallback? onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonBgColor(context),
        foregroundColor: tColor(context),
        disabledForegroundColor: isDark(context) ? Colors.white30 : Colors.deepPurple.withAlpha(100),
        disabledBackgroundColor: isDark(context) ? Colors.white.withAlpha(10) : Colors.deepPurple.withAlpha(10),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 22),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
