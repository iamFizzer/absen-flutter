import 'package:absensi_fr/modules/admin/views/unauthorized_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('unknown route menampilkan fallback yang jelas', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: UnauthorizedPage(notFound: true)),
    );

    expect(find.text('Halaman tidak ditemukan'), findsOneWidget);
    expect(find.text('Kembali ke Dashboard'), findsOneWidget);
    expect(find.byIcon(Icons.travel_explore_outlined), findsOneWidget);
  });
}
