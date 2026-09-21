import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class TestController extends ChangeNotifier {}

void main() {
  testWidgets('check if context.read<TestController?> works with ChangeNotifierProvider<TestController>', (tester) async {
    final controller = TestController();
    await tester.pumpWidget(
      ChangeNotifierProvider<TestController>.value(
        value: controller,
        child: Builder(
          builder: (context) {
            final found = Provider.of<TestController?>(context, listen: false);
            expect(found, isNotNull);
            return const SizedBox();
          },
        ),
      ),
    );
  });
}
