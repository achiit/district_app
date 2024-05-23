import 'package:flutter/material.dart';

class UserDetailsItem extends StatelessWidget {
  final String label;
  final String value;

  const UserDetailsItem({
    Key? key,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 5),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
          ),
        ),
        SizedBox(height: 10),
      ],
    );
  }
}
