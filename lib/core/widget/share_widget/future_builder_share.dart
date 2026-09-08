import 'package:flutter/material.dart';

class FutureBuilderShare<T> extends StatelessWidget {
  final Future<T> future;
  final Widget loading;
  final Widget error;
  final Widget Function(T data) builder;


  const FutureBuilderShare({
    super.key,
    required this.future,
    required this.loading,
    required this.error,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loading;
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return error;
        }

        return builder(snapshot.data as T);
      },
    );
  }
}