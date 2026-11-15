import 'package:example/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('Material UI fields apply CPF and phone masks', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.text('Masked Controller'));
    await tester.pumpAndSettle();

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), '12345678901');
    await tester.pump();
    expect(
      tester.widget<TextField>(fields.at(0)).controller!.text,
      '123.456.789-01',
    );

    await tester.enterText(fields.at(1), '11987654321');
    await tester.pump();
    expect(
      tester.widget<TextField>(fields.at(1)).controller!.text,
      '(11) 98765-4321',
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Material UI field applies a currency mask', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.text('Money Masked Controller'));
    await tester.pumpAndSettle();

    final field = find.byType(TextField);
    await tester.enterText(field, '123456');
    await tester.pump();
    expect(tester.widget<TextField>(field).controller!.text, 'R\$ 1.234,56');
    expect(tester.takeException(), isNull);
  });
}
