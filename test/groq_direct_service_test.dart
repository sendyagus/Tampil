// Uji logika lokal GroqDirectService (tanpa jaringan).
// Bagian transkrip/nilaiIsi tidak diuji di sini karena memanggil Groq API.
import 'package:flutter_test/flutter_test.dart';
import 'package:tampil/services/groq_direct_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final layanan = GroqDirectService.instance;

  setUpAll(() => layanan.siapkan());

  test('cakupan mencocokkan kata kunci studi kasus', () {
    final hasil = layanan.cakupan(
      'Maaf, proyek kita terlambat karena deadline besok dan tugasnya belum selesai.',
      'proyek_terlambat',
    );

    expect(hasil['skor_cakupan'], greaterThan(0));
    expect(hasil['poin_disebut'], contains('Menjelaskan kondisi proyek'));
    expect(hasil['total_poin'], 4);
  });

  test('pencocokan bersifat utuh, bukan sebagian kata', () {
    final hasil = layanan.cakupan(
      'aku suka sekali makan garam',
      'proyek_terlambat',
    );
    // "garam" tidak boleh dihitung sebagai cocok untuk kata kunci "ramai" dsb.
    expect(hasil['poin_tercapai'], 0);
  });

  test('kasus tidak dikenal mengembalikan rincian kosong', () {
    final hasil = layanan.cakupan('halo hai', 'case_001');
    expect(hasil['rincian_poin'], isEmpty);
    expect(hasil['skor_cakupan'], 0);
  });

  test('ucapan kosong tidak dinilai oleh LLM', () async {
    final hasil = await layanan.nilaiIsi('', 'proyek_terlambat');
    expect(hasil['skor_isi'], 0);
    expect(hasil['perbaikan'], isNotEmpty);
  });

  test('ucapan berisi kata pengisi saja dihentikan sebelum ke AI', () async {
    final hasil = await layanan.nilaiIsi(
      'eee Emm hmm halo halo',
      'proyek_terlambat',
    );
    expect(hasil['skor_isi'], 0);
    expect(hasil['ringkasan'].toString(), contains('belum terdapat jawaban'));
  });
}
