//loading_dialog.dart
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class LoadingDialog extends StatelessWidget {
  final String message;

  const LoadingDialog({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Disable back button
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              LoadingAnimationWidget.threeRotatingDots(
                color: Color(0xFFFF725E),
                size: 25,
              ),
              SizedBox(width: 20),
              Expanded(child: Text(message, style: TextStyle(fontSize: 16))),
            ],
          ),
        ),
      ),
    );
  }
}
