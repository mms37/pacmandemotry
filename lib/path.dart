import 'package:flutter/material.dart';

class MyPath extends StatelessWidget {
  final innerColor;
  final outerColor;
  final child;
  const MyPath({super.key, this.child, this.innerColor, this.outerColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(1.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: EdgeInsets.all(10),
          color: outerColor,
          child:ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(

                color: innerColor,
                child:Center(child: child,)
            ),
          ),
        ),
      ),

    );
  }
}
