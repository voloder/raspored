import 'dart:ui' as ui;

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    Widget body = BatchedBackdropFilter(
      filter: ui.ImageFilter.blur(sigmaX: 15, sigmaY: 15),
      color: Colors.white.withOpacity(0.3),
      borderColor: Colors.white.withOpacity(0.1),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(64),
          width: 600,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              for (var i = 0; i < 100; i++)
                BatchedBackdropChild(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: const BorderSide(width: 1),
                  ),
                  child: Container(
                    width: 100,
                    height: 50,
                    alignment: Alignment.center,
                    child: Text(
                      '$i',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Image.network(
              'https://i.imgur.com/nBsOe03.png',
              fit: BoxFit.cover,
            ),
          ),
          SingleChildScrollView(
            child: body,
          ),
        ],
      ),
    );
  }
}

class BatchedBackdropFilter extends StatefulWidget {
  const BatchedBackdropFilter({
    required this.filter,
    required this.child,
    required this.color,
    required this.borderColor,
  });

  final ui.ImageFilter filter;
  final Widget child;
  final Color color;
  final Color borderColor;

  @override
  State<BatchedBackdropFilter> createState() => _BatchedBackdropFilterState();
}

class _BackdropChildGeometry {
  _BackdropChildGeometry(this.rect, this.shape);

  final Rect rect;
  final ShapeBorder shape;
}

class _BatchedBackdropFilterState extends State<BatchedBackdropFilter> {
  final childContexts = <BuildContext>{};

  List<_BackdropChildGeometry> getChildGeometry() {
    final result = <_BackdropChildGeometry>[];
    final renderBox = context.findRenderObject() as RenderBox;
    for (final context in childContexts) {
      final shape = (context.widget as BatchedBackdropChild).shape;
      final childRenderBox = context.findRenderObject() as RenderBox;
      final childTransform = childRenderBox.getTransformTo(renderBox);
      final rect = Rect.fromPoints(
        MatrixUtils.transformPoint(childTransform, Offset.zero),
        MatrixUtils.transformPoint(
          childTransform,
          childRenderBox.size.bottomRight(Offset.zero),
        ),
      );
      result.add(_BackdropChildGeometry(rect, shape));
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _BatchedBackdropClipper(
        getChildGeometry: getChildGeometry,
      ),
      child: CustomPaint(
        foregroundPainter: _BatchedBackdropForegroundPainter(
          getChildGeometry: getChildGeometry,
          borderColor: widget.borderColor,
        ),
        child: CustomPaint(
          painter: _BatchedBackdropPainter(
            getChildGeometry: getChildGeometry,
            color: widget.color,
            borderColor: widget.borderColor,
          ),
          child: BackdropFilter(
            filter: widget.filter,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

class _BatchedBackdropClipper extends CustomClipper<Path> {
  const _BatchedBackdropClipper({
    required this.getChildGeometry,
  });

  final List<_BackdropChildGeometry> Function() getChildGeometry;

  @override
  Path getClip(Size size) {
    final path = Path();
    for (final geometry in getChildGeometry()) {
      path.addPath(
        geometry.shape.getOuterPath(geometry.rect),
        Offset.zero,
      );
    }
    return path;
  }

  @override
  bool shouldReclip(_BatchedBackdropClipper oldClipper) => false;
}

class _BatchedBackdropPainter extends CustomPainter {
  const _BatchedBackdropPainter({
    required this.getChildGeometry,
    required this.color,
    required this.borderColor,
  });

  final List<_BackdropChildGeometry> Function() getChildGeometry;
  final Color color;
  final Color borderColor;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Offset.zero & size);
    for (final geometry in getChildGeometry()) {
      path.addPath(
        geometry.shape.getInnerPath(geometry.rect),
        Offset.zero,
      );
    }
    canvas.drawPath(
      path,
      Paint()..color = borderColor,
    );
    canvas.drawColor(color, BlendMode.srcOver);
  }

  @override
  bool shouldRepaint(_BatchedBackdropPainter oldDelegate) => false;
}

class _BatchedBackdropForegroundPainter extends CustomPainter {
  const _BatchedBackdropForegroundPainter({
    required this.getChildGeometry,
    required this.borderColor,
  });

  final List<_BackdropChildGeometry> Function() getChildGeometry;
  final Color borderColor;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Offset.zero & size);
    for (final geometry in getChildGeometry()) {
      path.addPath(
        geometry.shape.getInnerPath(geometry.rect),
        Offset.zero,
      );
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(_BatchedBackdropForegroundPainter oldDelegate) => false;
}

class BatchedBackdropChild extends StatefulWidget {
  const BatchedBackdropChild({
    required this.shape,
    required this.child,
  });

  final ShapeBorder shape;
  final Widget child;

  @override
  State<BatchedBackdropChild> createState() => _BatchedBackdropChildState();
}

class _BatchedBackdropChildState extends State<BatchedBackdropChild> {
  late final _BatchedBackdropFilterState filterState;

  @override
  void initState() {
    super.initState();
    filterState = context.findAncestorStateOfType()!;
    filterState.childContexts.add(context);
  }

  @override
  void dispose() {
    filterState.childContexts.remove(context);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
