import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NorthIndianChart extends StatelessWidget {
  final Map<String, List<String>> houses; // Expected: keys "1" through "12", value is list of planets in that house

  const NorthIndianChart({super.key, required this.houses});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        margin: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black, width: 2),
        ),
        child: CustomPaint(
          painter: _NorthIndianChartPainter(houses),
        ),
      ),
    );
  }
}

class _NorthIndianChartPainter extends CustomPainter {
  final Map<String, List<String>> houses;
  
  _NorthIndianChartPainter(this.houses);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final w = size.width;
    final h = size.height;

    // Draw the main square and diagonals
    canvas.drawLine(const Offset(0, 0), Offset(w, h), paint); // Top-left to Bottom-right
    canvas.drawLine(Offset(w, 0), Offset(0, h), paint); // Top-right to Bottom-left
    
    // Draw the inner diamond
    final topCenter = Offset(w / 2, 0);
    final bottomCenter = Offset(w / 2, h);
    final leftCenter = Offset(0, h / 2);
    final rightCenter = Offset(w, h / 2);

    canvas.drawLine(topCenter, rightCenter, paint);
    canvas.drawLine(rightCenter, bottomCenter, paint);
    canvas.drawLine(bottomCenter, leftCenter, paint);
    canvas.drawLine(leftCenter, topCenter, paint);

    // Function to draw text at a specific coordinate
    void drawHouseText(String houseNumber, Offset centerOffset) {
      final planets = houses[houseNumber] ?? [];
      final textSpan = TextSpan(
        text: '$houseNumber\n',
        style: TextStyle(color: Colors.grey, fontSize: 10.sp),
        children: planets.map((p) => TextSpan(
          text: '$p ',
          style: TextStyle(color: Colors.black, fontSize: 12.sp, fontWeight: FontWeight.bold)
        )).toList(),
      );

      final textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(centerOffset.dx - textPainter.width / 2, centerOffset.dy - textPainter.height / 2),
      );
    }

    // Coordinates for the center of each of the 12 houses in a North Indian chart
    final housePositions = {
      "1": Offset(w / 2, h / 4),
      "2": Offset(w / 4, h / 8),
      "3": Offset(w / 8, h / 4),
      "4": Offset(w / 4, h / 2),
      "5": Offset(w / 8, 3 * h / 4),
      "6": Offset(w / 4, 7 * h / 8),
      "7": Offset(w / 2, 3 * h / 4),
      "8": Offset(3 * w / 4, 7 * h / 8),
      "9": Offset(7 * w / 8, 3 * h / 4),
      "10": Offset(3 * w / 4, h / 2),
      "11": Offset(7 * w / 8, h / 4),
      "12": Offset(3 * w / 4, h / 8),
    };

    housePositions.forEach((key, offset) {
      drawHouseText(key, offset);
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
