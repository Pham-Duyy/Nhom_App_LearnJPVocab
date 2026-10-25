import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/progress_provider.dart';
import '../theme/app_colors.dart';
import 'error_view.dart';

class FavoriteButton extends StatelessWidget {
  const FavoriteButton({
    Key? key,
    required this.vocabularyId,
    required this.isFavorite,
  }) : super(key: key);

  final String vocabularyId;
  final bool isFavorite;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return IconButton(
      tooltip: isFavorite ? 'Bỏ yêu thích' : 'Thêm vào yêu thích',
      onPressed: () async {
        final error =
            await context.read<ProgressProvider>().toggleFavorite(vocabularyId);
        if (error != null && context.mounted) {
          showErrorSnackBar(context, error);
        }
      },
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder: (child, animation) =>
            ScaleTransition(scale: animation, child: child),
        child: Icon(
          isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          key: ValueKey(isFavorite),
          color: isFavorite ? palette.favorite : palette.textMuted,
        ),
      ),
    );
  }
}
