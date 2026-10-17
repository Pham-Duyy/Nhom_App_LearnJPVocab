import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

mixin GenericLayout {
  String getTitle(BuildContext context);

  Widget buildBody(BuildContext context);

  /// Màn hình là một tab trong MainScreen (đã có Scaffold và AppBar chung)
  /// trả về false để chỉ dựng phần thân, tránh lồng hai Scaffold.
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

/// Bố cục chung cho các màn hình: Scaffold với AppBar theo màu chuẩn của app.
/// Lớp con chỉ khai báo [getTitle] và [buildBody], không tự dựng lại
/// Scaffold/AppBar ở từng màn hình.
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
