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
    // Reiniciamos el frame si cambia de dirección, si empieza/deja de moverse,
    // o si el jugador empieza/deja de correr para que el cambio sea instantáneo
    if (oldWidget.playerState.isMoving != widget.playerState.isMoving ||
        oldWidget.playerState.facing != widget.playerState.facing ||
        oldWidget.playerState.isRunning != widget.playerState.isRunning) {
      _currentFrame = 0;
    }
  }

  void _startAnimation() {
    // Escucha cada 16 ms (aprox 60fps) para actualizar el frame si toca
    _animationTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (!mounted) return;

      // ACELERACIÓN DE LA ANIMACIÓN
      int currentSpeed = 1000; // Velocidad para el IDLE (1 seg por frame)
      if (widget.playerState.isMoving) {
        // 70ms para correr, 150ms para caminar
        currentSpeed = widget.playerState.isRunning ? 70 : 150; 
      }

      final int totalFrames =
          widget.playerState.isMoving ? _runFramesCount : _idleFramesCount;
      final int newFrame =
          (DateTime.now().millisecondsSinceEpoch ~/ currentSpeed) % totalFrames;

      if (_currentFrame != newFrame) {
        setState(() {
          _currentFrame = newFrame;
        });
      }
    });
  }

  @override
  void dispose() {
    _animationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /* TODO: Cuando decidas migrar tus assets individuales de Kotlin,
      aquí podrás ignorar la lógica de abajo (el ClipRect del spritesheet)
      y retornar directamente la imagen correspondiente:

      if (widget.playerState.isMoving && widget.playerState.isRunning) {
         // Asegúrate de sumar +1 porque tus assets en Kotlin empiezan en 1, no en 0
         return Image.asset('assets/PRINCIPAL/lazaroRun/lazaro_r_${_currentFrame + 1}.webp');
      }
    */

    // 1. DETERMINAR LA FILA (ROW)
    final int row = widget.playerState.isMoving
        ? _getRowForDirection(widget.playerState.facing)
        : 0;

    // 2. DETERMINAR LA COLUMNA (COL)
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