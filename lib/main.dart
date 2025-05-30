import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show timeDilation;

// This Flutter app demonstrates a radial expansion animation using Hero transitions.
// Swiping up triggers the transition, and swiping down dismisses the detailed view.
void main() => runApp(const MaterialApp(home: RadialExpansionDemo(), debugShowCheckedModeBanner: false));

class Photo extends StatelessWidget {
  const Photo({super.key, required this.photo, this.onSwipe, this.onSwipeDown});
  final String photo;
  final VoidCallback? onSwipe, onSwipeDown;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onPanUpdate: (d) {
      if (d.delta.dy < -1 && d.delta.dx.abs() < 1) onSwipe?.call();
      if (d.delta.dy > 5) onSwipeDown?.call();
    },
    child: Material(
      color: Colors.transparent,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: Image.asset(photo, fit: BoxFit.contain),
    ),
  );
}

class RadialExpansion extends StatelessWidget {
  RadialExpansion({super.key, required this.minRadius, required this.maxRadius, this.child})
      : clipTween = Tween<double>(begin: 2 * minRadius, end: 2 * (maxRadius / math.sqrt2));

  final double minRadius, maxRadius;
  final Tween<double> clipTween;
  final Widget? child;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (_, size) {
      final t = (size.maxWidth / 1.7 - minRadius) / (maxRadius - minRadius);
      final extent = clipTween.transform(t);
      return ClipOval(
        child: Center(
          child: SizedBox(width: extent, height: extent, child: ClipRect(child: child)),
        ),
      );
    },
  );
}

class RadialExpansionDemo extends StatelessWidget {
  const RadialExpansionDemo({super.key});

  static const kMin = 32.0, kMax = 128.0;
  static const opacityCurve = Interval(0.0, 0.75, curve: Curves.fastOutSlowIn);

  RectTween _createTween(Rect? a, Rect? b) => MaterialRectCenterArcTween(begin: a, end: b);

  Widget _buildPage(BuildContext c, String img, String text) => Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(colors: [Color(0xFFe0eafc), Color(0xFFcfdef3)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    ),
    child: Center(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 12,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          SizedBox(
            width: kMax * 2,
            height: kMax * 2,
            child: Hero(
              tag: img,
              createRectTween: _createTween,
              child: RadialExpansion(
                minRadius: kMin,
                maxRadius: kMax,
                child: Photo(photo: img, onSwipeDown: () => Navigator.pop(c)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24, fontFamily: 'Roboto')),
          ),
          const SizedBox(height: 16),
        ]),
      ),
    ),
  );

  Widget _buildHero(BuildContext c, String img, String text) => SizedBox(
    width: kMin * 2,
    height: kMin * 2,
    child: Hero(
      tag: img,
      createRectTween: _createTween,
      child: RadialExpansion(
        minRadius: kMin,
        maxRadius: kMax,
        child: Photo(
          photo: img,
          onSwipe: () => Navigator.push(
            c,
            PageRouteBuilder(
              pageBuilder: (_, a, __) => AnimatedBuilder(
                animation: a,
                builder: (_, __) => Opacity(opacity: opacityCurve.transform(a.value), child: _buildPage(c, img, text)),
              ),
            ),
          ),
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    timeDilation = 2.0;
    const imgs = [
      ['assets/images/chair-alpha.png', 'Chair'],
      ['assets/images/binoculars-alpha.png', 'Binoculars'],
      ['assets/images/beachball-alpha.png', 'Beach ball'],
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Radial Transition Demo', style: TextStyle(fontFamily: 'Roboto')), backgroundColor: const Color(0xff00cb3a)),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xFFe0eafc), Color(0xFFcfdef3)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        ),
        padding: const EdgeInsets.all(32),
        alignment: FractionalOffset.bottomLeft,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: imgs.map((e) => _buildHero(context, e[0], e[1])).toList(),
        ) ,
      ),
    );
  }
}