import 'package:flutter/material.dart';

class WinningLinePainter extends CustomPainter {
  final List<Offset> lineOffsets;

  WinningLinePainter({required this.lineOffsets});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 5;

    canvas.drawLine(lineOffsets.first, lineOffsets.last, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}


// CustomPaint(
//         size: Size.infinite,
//         painter: winningLine.isEmpty
//             ? null
//             : LinePainter(
//                 boxes: winningLine,
//                 color: Colors.red,
//                 strokeWidth: 10.0,
//               ),
