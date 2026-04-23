import 'package:flutter/material.dart';

/// Widget condiviso per mostrare uno stato di caricamento centrato.
class LoadingOverlay extends StatelessWidget {
  final Color color;

  const LoadingOverlay({
    super.key,
    this.color = const Color(0xFF2C5542),
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAF9),
      body: Center(
        child: CircularProgressIndicator(color: color),
      ),
    );
  }
}

/// Widget inline per un indicatore di caricamento nel bottone.
class ButtonLoadingIndicator extends StatelessWidget {
  final Color color;

  const ButtonLoadingIndicator({
    super.key,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 20,
      width: 20,
      child: CircularProgressIndicator(color: color, strokeWidth: 2),
    );
  }
}
