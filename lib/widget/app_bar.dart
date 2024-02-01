import 'package:flutter/material.dart';

AppBar appBar(context) => AppBar(
      elevation: 0.0,
      backgroundColor: Colors.black,
      leading: IconButton(
        icon: const Icon(
          Icons.close,
          color: Colors.white,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: const [
        IconButton(
          icon: Icon(Icons.more_vert, color: Colors.white),
          onPressed: null,
        )
      ],
    );
