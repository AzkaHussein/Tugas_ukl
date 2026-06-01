import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TipsScreen extends StatelessWidget {
  const TipsScreen({super.key});

  static const List<String> tips = [
    "Perbaiki kebocoran keran atau pipa karena dapat membuang banyak air setiap hari.",
    "Matikan keran saat tidak digunakan, misalnya saat menyikat gigi atau menggosok sabun.",
    "Mandi lebih singkat, cukup 5-10 menit untuk menghemat puluhan liter air.",
    "Gunakan ember daripada selang saat mencuci kendaraan atau membersihkan halaman.",
    "Manfaatkan air bekas yang masih layak, seperti air cucian beras atau sayuran, untuk menyiram tanaman.",
  ];

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF1877F2);
    const dark = Color(0xFF1A1A2E);
    const grey = Color(0xFF8A8A9A);
    const cardBorder = Color(0xFFE8F0FE);
    const circleBg = Color(0xFFEEF4FF);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Custom AppBar
            Container(
              height: 20,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: const BoxDecoration(color: Colors.white),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFE0E0E0)),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: blue,
                        size: 18,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Image.asset(
                        'assets/images/water_drop.png',
                        width: 24,
                        height: 24,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'WATERCASH',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: blue,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hemat Air, Hemat Tagihan',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: dark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '5 Kiat Cepat Mengurangi Konsumsi Air hingga 20%',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: grey,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Card Tips
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: cardBorder, width: 1.5),
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ...List.generate(tips.length, (i) => Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: circleBg,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '${i + 1}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: blue,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  tips[i],
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: dark,
                                    height: 1.6,
                                  ),
                                ),
                              ),
                            ],
                          )),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),
                    Text(
                      'Jika dilakukan secara rutin, langkah-langkah sederhana ini dapat membantu mengurangi penggunaan air bulanan hingga sekitar 20%.',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: grey,
                        height: 1.6,
                      ),
                    ),

                    const SizedBox(height: 32),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Opacity(
                        opacity: 0.6,
                        child: Image.asset(
                          'assets/images/water_drop.png',
                          width: 80,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
