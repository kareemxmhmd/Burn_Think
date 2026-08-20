import 'package:flutter/material.dart';

abstract final class AppSpacing {
  static const double p4 = 4.0;
  static const double p8 = 8.0;
  static const double p12 = 12.0;
  static const double p16 = 16.0;
  static const double p20 = 20.0;
  static const double p24 = 24.0;
  static const double p28 = 28.0;
  static const double p32 = 32.0;
  static const double p40 = 40.0;
  static const double p48 = 48.0;

  // Insets helpers
  static const EdgeInsets insets4 = EdgeInsets.all(p4);
  static const EdgeInsets insets8 = EdgeInsets.all(p8);
  static const EdgeInsets insets12 = EdgeInsets.all(p12);
  static const EdgeInsets insets16 = EdgeInsets.all(p16);
  static const EdgeInsets insets20 = EdgeInsets.all(p20);
  static const EdgeInsets insets24 = EdgeInsets.all(p24);
  static const EdgeInsets insets32 = EdgeInsets.all(p32);

  static const EdgeInsets h8 = EdgeInsets.symmetric(horizontal: p8);
  static const EdgeInsets h12 = EdgeInsets.symmetric(horizontal: p12);
  static const EdgeInsets h16 = EdgeInsets.symmetric(horizontal: p16);
  static const EdgeInsets h24 = EdgeInsets.symmetric(horizontal: p24);

  static const EdgeInsets v8 = EdgeInsets.symmetric(vertical: p8);
  static const EdgeInsets v12 = EdgeInsets.symmetric(vertical: p12);
  static const EdgeInsets v16 = EdgeInsets.symmetric(vertical: p16);
  static const EdgeInsets v24 = EdgeInsets.symmetric(vertical: p24);
}
