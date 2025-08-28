import 'package:flutter/material.dart';

/*
tools with UI
*/

// void widget
/// An empty widget that takes no space (0x0)
SizedBox voidWidget() => const SizedBox.shrink();

/// Create horizontal space of [pixels] between widgets
Widget hSpacer(double pixels) => SizedBox(
  width: pixels,
); // y'a une lib (Gap) qui fait le même truc mais bof, je garde mon truc

/// Create vertical space of [pixels] between widgets
Widget vSpacer(double pixels) => SizedBox(height: pixels);
