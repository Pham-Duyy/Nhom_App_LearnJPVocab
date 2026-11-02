import 'package:chibakanji/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

double _scaleOf(WidgetTester tester, String text) =>
    MediaQuery.textScalerOf(
      tester.element(find.text(text)),
    ).scale(10) /
    10;

void main() {
  testWidgets('máy để chữ hệ thống 145% thì chữ trong app giữ cỡ thiết kế', (
    tester,
  ) async {
    tester.platformDispatcher.textScaleFactorTestValue = 1.45;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await pumpTestApp(tester);

    expect(_scaleOf(tester, 'Chào Duy!'), ChibaKanjiApp.maxTextScale);
  });

  testWidgets('máy để chữ nhỏ hơn mặc định thì app thu nhỏ theo', (
    tester,
  ) async {
    tester.platformDispatcher.textScaleFactorTestValue = 0.9;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await pumpTestApp(tester);

    expect(_scaleOf(tester, 'Chào Duy!'), closeTo(0.9, 1e-9));
  });
}
