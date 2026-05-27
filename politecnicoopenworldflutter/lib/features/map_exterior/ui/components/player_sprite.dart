import 'dart:async';
import 'package:flutter/material.dart';
import '../../state/player_movement_notifier.dart';

class PlayerSprite extends StatefulWidget {
  final PlayerState playerState;
  final String spritesheetPath;

  const PlayerSprite({
    super.key,
    required this.playerState,
    required this.spritesheetPath,
  });

  @override
  State<PlayerSprite> createState() => _PlayerSpriteState();
}

class _PlayerSpriteState extends State<PlayerSprite> {
  Timer? _animationTimer;
  int _currentFrame = 0;

  // --- LOS NÚMEROS DE TU NUEVA CUADRÍCULA ---
  static const int _columns = 6; // Máximo de cuadros en la fila más larga
  static const int _rows = 5; // 1 fila de idle + 4 filas de direcciones

  static const int _idleFramesCount = 4;
  static const int _runFramesCount = 6;

  int _getRowForDirection(PlayerDirection dir) {
    switch (dir) {
      case PlayerDirection.down:
        return 1; // Fila 2
      case PlayerDirection.up:
        return 2; // Fila 3
      case PlayerDirection.right:
        return 3; // Fila 4
      case PlayerDirection.left:
        return 4; // Fila 5
    }
  }

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  @override
  void didUpdateWidget(covariant PlayerSprite oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reiniciamos el frame si cambia de dirección o si empieza/deja de moverse
    if (oldWidget.playerState.isMoving != widget.playerState.isMoving ||
        oldWidget.playerState.facing != widget.playerState.facing) {
      _currentFrame = 0;
    }
  }

  void _startAnimation() {
    // 150 ms de velocidad de animación
    _animationTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (!mounted) return;

      final int currentSpeed = widget.playerState.isMoving ? 150 : 1000;

      setState(() {
        final totalFrames =
            widget.playerState.isMoving ? _runFramesCount : _idleFramesCount;
        _currentFrame =
            (DateTime.now().millisecondsSinceEpoch ~/ currentSpeed) %
                totalFrames;
      });
    });
  }

  @override
  void dispose() {
    _animationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 1. DETERMINAR LA FILA (ROW)
    // Si NO se está moviendo, forzamos la fila 0 (el descanso)
    // Si SÍ se está moviendo, buscamos la fila de su dirección
    final int row = widget.playerState.isMoving
        ? _getRowForDirection(widget.playerState.facing)
        : 0;

    // 2. DETERMINAR LA COLUMNA (COL)
    // Como el descanso tiene su propia fila independiente,
    // ya no necesitamos saltarnos espacios. Usamos el frame directo.
    final int col = _currentFrame;

    // Fórmulas matemáticas de alineación en Flutter
    final double xAlign = _columns > 1 ? (col / (_columns - 1)) * 2 - 1 : 0;
    final double yAlign = _rows > 1 ? (row / (_rows - 1)) * 2 - 1 : 0;

    return FittedBox(
      fit: BoxFit.contain,
      child: ClipRect(
        child: Align(
          alignment: Alignment(xAlign, yAlign),
          widthFactor: 1.0 / _columns,
          heightFactor: 1.0 / _rows,
          child: Image.asset(
            widget.spritesheetPath,
            filterQuality: FilterQuality.none,
          ),
        ),
      ),
    );
  }
}
