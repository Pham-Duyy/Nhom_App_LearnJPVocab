import 'package:flutter/material.dart';

import '../../widgets/japan_scenery.dart';

mixin GenericLayout {
  String getTitle(BuildContext context);

  Widget buildBody(BuildContext context);
  bool get showAppBar => true;

  bool get showBackButton => true;

  /// Màn có AppBar tự dựng Scaffold trên nền washi chung; màn không có AppBar
  /// là một tab và nằm trong Scaffold của MainScreen.
  Widget buildLayout(BuildContext context) {
    if (!showAppBar) return buildBody(context);

    return WashiBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          automaticallyImplyLeading: showBackButton,
          backgroundColor: Colors.transparent,
          title: Text(getTitle(context)),
        ),
        body: buildBody(context),
      ),
    );
  }
}

abstract class GenericScreen extends StatelessWidget with GenericLayout {
  const GenericScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => buildLayout(context);
}

abstract class GenericScreenState<W extends StatefulWidget> extends State<W>
    with GenericLayout {
  @override
  Widget build(BuildContext context) => buildLayout(context);
}
