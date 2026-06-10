import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:todo_app/core/utils/constants.dart';

import '../widgets/custom_snackbar.dart';

extension ContextExtension on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;
  ColorScheme get colorScheme => theme.colorScheme;


  void showSnackbar({
    required String title,
    required String message,
    bool error = false,
    void Function()? undo,
  }) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        
        SnackBar(

          content: SnackbarWidget(
            title: title,
            message: message,
            error: error,
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor:
              error ? Colors.red[100] : Colors.blue[100],
          padding: EdgeInsets.zero,
          elevation: 0,
          duration: AppConstants.undoDeleteDuration,
          margin: const EdgeInsets.all(20),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () => undo?.call(),
          ),
          
        ),
      );
  }
}