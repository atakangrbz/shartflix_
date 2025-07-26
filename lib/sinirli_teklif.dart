import 'package:flutter/material.dart';

class SinirliTeklif extends StatefulWidget {
  const SinirliTeklif({super.key});

  @override
  State<SinirliTeklif> createState() => _SinirliTeklifState();
}

class _SinirliTeklifState extends State<SinirliTeklif> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.95),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: CloseButton(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Sınırlı Teklif",
              style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
            ),
            const SizedBox(height: 12),
            const Text(
              "Jeton paketini seçerek bonus kazanın ve yeni bölümlerin kilidini açın!",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 24),

            /// 🛠 Wrap kullanıldı:
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 24,
              runSpacing: 20,
              children: const [
                BonusIcon(icon: Icons.workspace_premium, text: "Premium Hesap"),
                BonusIcon(icon: Icons.favorite, text: "Daha Fazla Eşleşme"),
                BonusIcon(icon: Icons.arrow_circle_up, text: "Öne Çıkarma"),
                BonusIcon(icon: Icons.thumb_up, text: "Daha Fazla Beğeni"),
              ],
            ),

            const SizedBox(height: 32),
            Column(
              children: [
                TeklifKart(
                  yuzde: "+10%",
                  jeton: "330",
                  fiyat: "₺99,99",
                  eskiJeton: "200",
                ),
                TeklifKart(
                  yuzde: "+70%",
                  jeton: "3.375",
                  fiyat: "₺799,99",
                  eskiJeton: "2.000",
                  highlight: true,
                ),
                TeklifKart(
                  yuzde: "+35%",
                  jeton: "1.350",
                  fiyat: "₺399,99",
                  eskiJeton: "1.000",
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                // Tüm jetonları gör tıklanınca yapılacak işlem
              },
              child: const Text(
                "Tüm Jetonları Gör",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BonusIcon extends StatelessWidget {
  final IconData icon;
  final String text;
  const BonusIcon({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 70, // sabit genişlik verildi
      child: Column(
        children: [
          Icon(icon, size: 36, color: Colors.pinkAccent),
          const SizedBox(height: 6),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 12),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class TeklifKart extends StatelessWidget {
  final String yuzde;
  final String jeton;
  final String fiyat;
  final String eskiJeton;
  final bool highlight;

  const TeklifKart({
    super.key,
    required this.yuzde,
    required this.jeton,
    required this.fiyat,
    required this.eskiJeton,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: highlight ? Colors.purple.shade900 : Colors.grey.shade900,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: highlight ? Colors.purpleAccent : Colors.redAccent, width: 2),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(yuzde, style: const TextStyle(color: Colors.white)),
              ),
              const SizedBox(width: 10),
              Text(
                "$jeton Jeton",
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
              ),
              const Spacer(),
              Text(
                fiyat,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text("Önceki: $eskiJeton Jeton", style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
