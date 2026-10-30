// Test ringan widget beranda. Sengaja tidak menyentuh Firebase/Auth: hanya
// data yang diumpankan ke widget, supaya bisa jalan tanpa emulator.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tampil/presentation/widgets/home/aktivitas_terbaru_widget.dart';
import 'package:tampil/presentation/widgets/home/hero_card_widget.dart';
import 'package:tampil/services/home_service.dart';

Widget _wrap(Widget child) => MaterialApp(
  home: Scaffold(body: SingleChildScrollView(child: child)),
);

void main() {
  testWidgets('Aktivitas terbaru merender item dari data yang diberikan', (
    tester,
  ) async {
    final items = [
      ActivityEntry(
        id: 'l1',
        kind: 'lesson',
        title: 'Kelancaran Jeda Berbicara',
        subtitle: 'Lesson · Kelancaran jeda',
        badge: '+10 XP',
        time: DateTime.now(),
        lessonId: 'modul_01_lesson_01',
      ),
    ];

    ActivityEntry? tapped;
    await tester.pumpWidget(
      _wrap(
        AktivitasTerbaruWidget(
          items: items,
          onItemTap: (item) => tapped = item,
        ),
      ),
    );

    expect(find.text('Kelancaran Jeda Berbicara'), findsOneWidget);
    expect(find.text('+10 XP'), findsOneWidget);
    expect(find.text('Belum ada aktivitas'), findsNothing);

    await tester.tap(find.text('Kelancaran Jeda Berbicara'));
    await tester.pump();
    expect(tapped?.lessonId, 'modul_01_lesson_01');
  });

  testWidgets('Aktivitas terbaru menampilkan empty state bila belum ada', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(const AktivitasTerbaruWidget()));

    expect(find.text('Belum ada aktivitas'), findsOneWidget);
  });

  testWidgets('Hero card memakai label & angka yang diumpankan', (tester) async {
    String? action;
    await tester.pumpWidget(
      _wrap(
        HeroCardWidget(
          streakDays: 2,
          modulName: 'MODUL 3',
          lessonTitle: 'Penyampaian Cakupan Poin Penting',
          lessonSubtitle: 'Public Speaking · Cakupan isi',
          currentLesson: 3,
          totalLessons: 5,
          currentXp: 30,
          targetXp: 40,
          continueLabel: 'Mulai',
          onContinuePressed: () => action = 'continue',
        ),
      ),
    );

    expect(find.text('MODUL 3'), findsOneWidget);
    expect(find.text('Penyampaian Cakupan Poin Penting'), findsOneWidget);
    expect(find.text('3/5 lesson'), findsOneWidget);
    expect(find.text('Target harian 30/40 XP'), findsOneWidget);
    expect(find.text('Mulai'), findsOneWidget);

    await tester.tap(find.text('Mulai'));
    await tester.pump();
    expect(action, 'continue');
  });

  testWidgets('Hero card tidak error saat total lesson nol', (tester) async {
    await tester.pumpWidget(
      _wrap(const HeroCardWidget(currentLesson: 0, totalLessons: 0)),
    );

    expect(find.text('0/0 lesson'), findsOneWidget);
  });
}
