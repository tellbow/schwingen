import 'package:flutter/material.dart';

bool isWide(BuildContext context) => MediaQuery.sizeOf(context).width >= 820;

const listWidth = 720.0;
const pageWidth = 1100.0;

class Readable extends StatelessWidget {
  const Readable({super.key, required this.child, this.width = listWidth});

  final Widget child;
  final double width;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topCenter,
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: width),
      child: child,
    ),
  );
}

class Columns extends StatelessWidget {
  const Columns(this.children, {super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (!isWide(context) || children.length < 2) {
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children);
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final side in [0, 1])
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [for (var i = side; i < children.length; i += 2) children[i]],
            ),
          ),
      ],
    );
  }
}
