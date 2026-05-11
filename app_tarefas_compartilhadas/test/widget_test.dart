import 'package:flutter_test/flutter_test.dart';
import 'package:app_tarefas_compartilhadas/main.dart';

void main() {
  testWidgets('Verifica se o app inicia', (WidgetTester tester) async {
    await tester.pumpWidget(const TarefasCompartilhadasApp());

    expect(find.text('Tarefas Compartilhadas'), findsOneWidget);
  });
}
