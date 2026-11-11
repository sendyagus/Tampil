import 'package:flutter/material.dart';

/// ============================================================
/// TAMPIL — Soft Rise + Fade Navigation Utilities
/// ============================================================
///
/// Spesifikasi transisi (revisi motion — gaya premium):
/// - Durasi maju  : 380 ms (lebih lambat & premium)
/// - Durasi balik : 300 ms
/// - Animasi      : fade + naik lembut 24 px + micro-scale 0.98 → 1.00
///                  (gaya presentasi modal iOS — BUKAN slide horizontal)
/// - Curve        : easeOutCubic (masuk), reverse otomatis lebih cepat
/// - Reduced motion: durasi 0 (menghormati aksesibilitas)
///
/// Tidak ada package tambahan; semuanya berbasis Flutter SDK.

/// Durasi transisi saat halaman masuk.
const Duration kDissolveForwardDuration = Duration(milliseconds: 380);

/// Durasi transisi saat halaman keluar (reverse / back).
const Duration kDissolveReverseDuration = Duration(milliseconds: 300);

/// Curve fade & rise saat masuk — melambat di akhir agar "mendarat" halus.
const Curve kEntranceCurve = Curves.easeOutCubic;

/// Jarak naik halus dalam fraksi tinggi layar (~24 px pada 700 px).
const double kRiseFraction = 0.035;

/// Scale awal halaman baru — sangat kecil, bukan zoom mencolok.
const double kStartScale = 0.98;

/// Helper: durasi nol bila pengguna mengaktifkan reduced motion.
Duration dissolveDuration(BuildContext context, Duration normal) {
  final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
  return reduceMotion ? Duration.zero : normal;
}

/// Kombinasi FadeTransition + naik lembut + micro-scale.
///
/// Dipakai seragam oleh route push/pop dan crossfade tab agar karakter
/// gerakkan identik di seluruh aplikasi. Semua transform bersifat
/// paint-only (Transform/Fade) sehingga murah untuk performa.
class SoftRiseFade extends StatelessWidget {
  const SoftRiseFade({
    super.key,
    required this.animation,
    required this.child,
  });

  /// 0.0 = halaman belum masuk (turun sedikit, transparan),
  /// 1.0 = posisi penuh.
  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: kEntranceCurve,
      reverseCurve: kEntranceCurve.flipped,
    );
    return FadeTransition(
      opacity: curved,
      child: ScaleTransition(
        // Micro-scale 0.98 → 1.00 — sangat halus, bukan zoom mencolok.
        scale: Tween<double>(begin: kStartScale, end: 1.0).animate(curved),
        child: AnimatedBuilder(
          animation: curved,
          builder: (context, inner) {
            final t = curved.value;
            return Transform.translate(
              // Naik dari +kRiseFraction menuju 0.
              offset: Offset(0, (1.0 - t) * MediaQuery.of(context).size.height * kRiseFraction),
              child: inner,
            );
          },
          child: child,
        ),
      ),
    );
  }
}

/// Route push/pop dengan efek Soft Rise + Fade.
///
/// Halaman baru naik lembut (~24 px) sambil memudar masuk dengan
/// micro-scale — gaya presentasi modal iOS. Tidak ada slide horizontal.
/// [builder] hanya dipanggil sekali per navigasi (via [pageBuilder]),
/// sehingga tidak memicu ulang request API atau me-reset state halaman
/// tujuan selama animasi berjalan. Transisi bersifat non-blocking.
class DissolvePageRoute<T> extends PageRouteBuilder<T> {
  DissolvePageRoute({
    required WidgetBuilder builder,
    RouteSettings settings = const RouteSettings(),
    Duration? forwardDuration,
    Duration? reverseDuration,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) =>
              Builder(builder: builder),
          settings: settings,
          transitionDuration:
              forwardDuration ?? kDissolveForwardDuration,
          reverseTransitionDuration:
              reverseDuration ?? kDissolveReverseDuration,
          // Rise + fade untuk halaman yang masuk; halaman di bawahnya
          // hanya ikut meredup halus (tanpa bergerak) saat tertindih.
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final entering = SoftRiseFade(animation: animation, child: child);
            return FadeTransition(
              opacity: Tween<double>(begin: 1.0, end: 0.85).animate(
                CurvedAnimation(parent: secondaryAnimation, curve: Curves.linear),
              ),
              child: entering,
            );
          },
        );
}

/// Helper navigasi seragam untuk seluruh alur TAMPIL.
///
/// Contoh: `context.pushDissolve((_) => const LessonScreen())`
/// dan `context.pushDissolveReplacement((_) => const HomeScreen())`.
/// Durasi otomatis nol ketika reduced motion / disable animations aktif.
extension DissolveNavigator on BuildContext {
  Future<T?> pushDissolve<T>(Widget Function(BuildContext context) pageBuilder) {
    final reduceMotion = MediaQuery.maybeOf(this)?.disableAnimations ?? false;
    return Navigator.of(this).push(DissolvePageRoute<T>(
      builder: pageBuilder,
      forwardDuration:
          reduceMotion ? Duration.zero : kDissolveForwardDuration,
      reverseDuration:
          reduceMotion ? Duration.zero : kDissolveReverseDuration,
    ));
  }

  Future<T?> pushDissolveReplacement<T>(Widget Function(BuildContext context) pageBuilder) {
    final reduceMotion = MediaQuery.maybeOf(this)?.disableAnimations ?? false;
    return Navigator.of(this).pushReplacement(DissolvePageRoute<T>(
      builder: pageBuilder,
      forwardDuration:
          reduceMotion ? Duration.zero : kDissolveForwardDuration,
      reverseDuration:
          reduceMotion ? Duration.zero : kDissolveReverseDuration,
    ));
  }
}

/// Crossfade antar konten tab Bottom Navigation TAMPIL.
///
/// Semua tab tetap hidup (state, posisi scroll, stream, dan sesi
/// perekaman tidak dihancurkan) — meniru perilaku `IndexedStack` —
/// namun saat [currentIndex] berubah, tab baru masuk dengan Soft Rise +
/// Fade di atas tab lama yang memudar di bawahnya.
///
/// Bottom Navigation berada di luar widget ini sehingga tidak ikut
/// memudar atau dibangun ulang.
class TabDissolve extends StatefulWidget {
  const TabDissolve({
    super.key,
    required this.currentIndex,
    required this.children,
  });

  final int currentIndex;
  final List<Widget> children;

  @override
  State<TabDissolve> createState() => _TabDissolveState();
}

class _TabDissolveState extends State<TabDissolve>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  int _previousIndex = 0;

  @override
  void initState() {
    super.initState();
    _previousIndex = widget.currentIndex;
    _controller = AnimationController(
      vsync: this,
      duration: kDissolveForwardDuration,
      value: 1.0,
    );
    // Setelah fade-in selesai, kembali ke mode stabil agar tab lama
    // dilepas dari layar (hemat paint, menghindari frame drop).
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        setState(() {});
      }
    });
  }

  @override
  void didUpdateWidget(covariant TabDissolve oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _previousIndex = oldWidget.currentIndex;
      // Restart rise+fade tab baru di atas tab lama.
      _controller.value = 0.0;
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    final newChild = KeyedSubtree(
      key: ValueKey<int>(widget.currentIndex),
      child: widget.children[widget.currentIndex],
    );
    final oldChild = KeyedSubtree(
      key: ValueKey<int>(_previousIndex),
      child: widget.children[_previousIndex],
    );

    // Mode stabil: hanya tab aktif yang (secara visual) terlihat —
    // sama seperti IndexedStack, semua child tetap hidup di tree.
    if (reduceMotion ||
        _previousIndex == widget.currentIndex ||
        (_controller.value >= 1.0 && !_controller.isAnimating)) {
      return KeyedSubtree(key: const ValueKey('tab-dissolve'), child: newChild);
    }

    // Dibungkus KeyedSubtree dengan key tetap agar elemen Stack berikut
    // child-nya bereuse saat berpindah antara mode stabil dan mode animasi
    // (state tab, posisi scroll, dan sesi rekaman tidak terganggu).
    return KeyedSubtree(
      key: const ValueKey('tab-dissolve'),
      child: RepaintBoundary(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Tab lama memudar halus di bawah (fade-only, tanpa gerak)
            // agar tidak ada dua halaman yang bergeser bersamaan.
            FadeTransition(
              opacity: Tween<double>(begin: 1.0, end: 0.0).animate(
                CurvedAnimation(parent: _controller, curve: Curves.easeOut),
              ),
              child: oldChild,
            ),
            // Tab baru: rise + fade + micro-scale (karakter sama dgn route).
            SoftRiseFade(animation: _controller, child: newChild),
          ],
        ),
      ),
    );
  }
}
