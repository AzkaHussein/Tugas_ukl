import 'package:intl/intl.dart';

class FormatHelper {
  static String formatRupiah(num amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  static String formatBulan(int month) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    if (month < 1 || month > 12) return '';
    return months[month - 1];
  }

  static String formatTanggal(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day} ${formatBulan(date.month)} ${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  static String formatBulanTahun(int month, int year) {
    return '${formatBulan(month)} $year';
  }
}