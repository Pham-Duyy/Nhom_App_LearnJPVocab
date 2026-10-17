import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

mixin GenericLayout {
  String getTitle(BuildContext context);

  Widget buildBody(BuildContext context);
  bool get showAppBar => true;

  bool get showBackButton => true;

  Widget buildLayout(BuildContext context) {
    if (!showAppBar) return buildBody(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: showBackButton,
        backgroundColor: AppColors.appBarBackground,
        foregroundColor: AppColors.appBarForeground,
        title: Text(getTitle(context)),
      ),
      body: buildBody(context),
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
