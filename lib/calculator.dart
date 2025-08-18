import 'package:flutter/material.dart';

// Katsayılar
const Map<String, double> TYT_KATSAYILAR = {
  "Matematik": 3.3,
  "Turkce": 3.3,
  "Sosyal": 3.4,
  "Fen": 3.4,
};

const Map<String, double> AYT_KATSAYILAR = {
  "Matematik": 3.0,
  "Fen": 2.85,
  "TDE": 3.0,
  "Sosyal": 2.8,
  "Dil": 3.0
};

// TYT sıralama tablosu
const List<Map<String, double>> siralamalar_tyt = [
  {"puan": 500, "siralama": 5000},
  {"puan": 495, "siralama": 8000},
  {"puan": 490, "siralama": 12000},
  {"puan": 485, "siralama": 17000},
  {"puan": 480, "siralama": 23000},
  {"puan": 475, "siralama": 30000},
  {"puan": 470, "siralama": 38000},
  {"puan": 465, "siralama": 47000},
  {"puan": 460, "siralama": 57000},
  {"puan": 455, "siralama": 68000},
  {"puan": 450, "siralama": 80000},
  {"puan": 445, "siralama": 93000},
  {"puan": 440, "siralama": 107000},
  {"puan": 435, "siralama": 122000},
  {"puan": 430, "siralama": 138000},
  {"puan": 425, "siralama": 160000},
  {"puan": 420, "siralama": 180000},
  {"puan": 415, "siralama": 200000},
  {"puan": 410, "siralama": 220000},
  {"puan": 405, "siralama": 240000},
  {"puan": 400, "siralama": 270000},
  {"puan": 395, "siralama": 300000},
  {"puan": 390, "siralama": 330000},
  {"puan": 385, "siralama": 360000},
  {"puan": 380, "siralama": 390000},
  {"puan": 375, "siralama": 500000},
  {"puan": 370, "siralama": 570000},
  {"puan": 365, "siralama": 640000},
  {"puan": 360, "siralama": 710000},
  {"puan": 355, "siralama": 780000},
  {"puan": 350, "siralama": 850000},
  {"puan": 345, "siralama": 920000},
  {"puan": 340, "siralama": 990000},
  {"puan": 335, "siralama": 1060000},
  {"puan": 330, "siralama": 1130000},
  {"puan": 325, "siralama": 1200000},
  {"puan": 320, "siralama": 1270000},
  {"puan": 315, "siralama": 1340000},
  {"puan": 310, "siralama": 1410000},
  {"puan": 305, "siralama": 1480000},
  {"puan": 300, "siralama": 1550000},
  {"puan": 295, "siralama": 1620000},
  {"puan": 290, "siralama": 1690000},
  {"puan": 285, "siralama": 1760000},
  {"puan": 280, "siralama": 1830000},
  {"puan": 275, "siralama": 1900000},
  {"puan": 270, "siralama": 1970000},
  {"puan": 265, "siralama": 2040000},
  {"puan": 260, "siralama": 2110000},
  {"puan": 255, "siralama": 2180000},
  {"puan": 250, "siralama": 2250000},
  {"puan": 245, "siralama": 2320000},
  {"puan": 240, "siralama": 2390000},
  {"puan": 235, "siralama": 2460000},
  {"puan": 230, "siralama": 2530000},
  {"puan": 225, "siralama": 2600000},
  {"puan": 220, "siralama": 2670000},
  {"puan": 215, "siralama": 2740000},
  {"puan": 210, "siralama": 2810000},
  {"puan": 205, "siralama": 2880000},
  {"puan": 200, "siralama": 2950000},
];

// Yerleştirme sıralama tablosu
const List<Map<String, double>> siralamalar_yer = [
  {"puan": 560, "siralama": 100}, {"puan": 555, "siralama": 500}, {"puan": 550, "siralama": 1000}, {"puan": 545, "siralama": 3000}, {"puan": 540, "siralama": 5000},
  {"puan": 535, "siralama": 8000}, {"puan": 530, "siralama": 12000}, {"puan": 525, "siralama": 18000},
  {"puan": 520, "siralama": 25000}, {"puan": 515, "siralama": 35000}, {"puan": 510, "siralama": 45000},
  {"puan": 505, "siralama": 60000}, {"puan": 500, "siralama": 80000}, {"puan": 495, "siralama": 100000},
  {"puan": 490, "siralama": 125000}, {"puan": 485, "siralama": 150000}, {"puan": 480, "siralama": 180000},
  {"puan": 475, "siralama": 210000}, {"puan": 470, "siralama": 240000}, {"puan": 465, "siralama": 270000},
  {"puan": 460, "siralama": 300000}, {"puan": 455, "siralama": 340000}, {"puan": 450, "siralama": 380000},
  {"puan": 445, "siralama": 420000}, {"puan": 440, "siralama": 460000}, {"puan": 435, "siralama": 500000},
  {"puan": 430, "siralama": 550000}, {"puan": 425, "siralama": 600000}, {"puan": 420, "siralama": 650000},
  {"puan": 415, "siralama": 700000}, {"puan": 410, "siralama": 760000}, {"puan": 405, "siralama": 820000},
  {"puan": 400, "siralama": 880000}, {"puan": 395, "siralama": 940000}, {"puan": 390, "siralama": 1000000},
  {"puan": 385, "siralama": 1070000}, {"puan": 380, "siralama": 1140000}, {"puan": 375, "siralama": 1210000},
  {"puan": 370, "siralama": 1280000}, {"puan": 365, "siralama": 1350000}, {"puan": 360, "siralama": 1420000},
  {"puan": 355, "siralama": 1500000}, {"puan": 350, "siralama": 1580000}, {"puan": 345, "siralama": 1660000},
  {"puan": 340, "siralama": 1740000}, {"puan": 335, "siralama": 1820000}, {"puan": 330, "siralama": 1900000},
  {"puan": 325, "siralama": 1980000}, {"puan": 320, "siralama": 2060000}, {"puan": 315, "siralama": 2140000},
  {"puan": 310, "siralama": 2220000}, {"puan": 305, "siralama": 2260000}, {"puan": 300, "siralama": 2300000},
  {"puan": 295, "siralama": 2320000}, {"puan": 290, "siralama": 2340000}, {"puan": 285, "siralama": 2360000},
  {"puan": 280, "siralama": 2380000}, {"puan": 275, "siralama": 2400000}, {"puan": 270, "siralama": 2420000},
  {"puan": 265, "siralama": 2440000}, {"puan": 260, "siralama": 2460000}, {"puan": 255, "siralama": 2480000},
  {"puan": 250, "siralama": 2500000},
];

// Tahmini sıralama bulma fonksiyonu
int? tahminiSiralama(double puan, List<Map<String, double>> tablo) {
  for (int i = 0; i < tablo.length - 1; i++) {
    final p1 = tablo[i]["puan"]!;
    final s1 = tablo[i]["siralama"]!;
    final p2 = tablo[i + 1]["puan"]!;
    final s2 = tablo[i + 1]["siralama"]!;
    
    if (p1 >= puan && puan >= p2) {
      if ((p1 - p2) == 0) {
        return s1.round();
      }
      final double oran = (puan - p2) / (p1 - p2);
      final int siralama = (s2 + oran * (s1 - s2)).round();
      return siralama;
    }
  }
  return null;
}

// AYT ham puanını normalize eden fonksiyon
double _aytHamNormalize(double aytRaw, int bolum) {
  double maxRaw = 0;
  switch (bolum) {
    case 1: // Sayısal: Mat(40) + Fen(40)
      maxRaw = 40 * AYT_KATSAYILAR["Matematik"]! + 40 * AYT_KATSAYILAR["Fen"]!;
      break;
    case 2: // EA: Mat(40) + TDE(40)
      maxRaw = 40 * AYT_KATSAYILAR["Matematik"]! + 40 * AYT_KATSAYILAR["TDE"]!;
      break;
    case 3: // Sözel: TDE(40) + Sosyal-2(40)
      maxRaw = 40 * AYT_KATSAYILAR["TDE"]! + 40 * AYT_KATSAYILAR["Sosyal"]!;
      break;
    case 4: // Dil: YDT 80 soru
      maxRaw = 80 * AYT_KATSAYILAR["Dil"]!;
      break;
  }
  if (maxRaw <= 0) return 100;
  final oran = (aytRaw / maxRaw).clamp(0.0, 1.0);
  return 100 + oran * 400; // 100–500 aralığı
}

class NetControllers {
  final TextEditingController mat = TextEditingController();
  final TextEditingController turkce = TextEditingController();
  final TextEditingController sosyal = TextEditingController();
  final TextEditingController fen = TextEditingController();
  final TextEditingController aytMat = TextEditingController();
  final TextEditingController aytFen = TextEditingController();
  final TextEditingController aytTDE = TextEditingController();
  final TextEditingController aytSosyal = TextEditingController();
  final TextEditingController aytDil = TextEditingController();
  final TextEditingController obp = TextEditingController();
}

class YksCalculatorPage extends StatefulWidget {
  const YksCalculatorPage({super.key});

  @override
  State<YksCalculatorPage> createState() => _YksCalculatorPageState();
}

class _YksCalculatorPageState extends State<YksCalculatorPage> {
  final _netControllers = NetControllers();

  String _tytSonuc = 'TYT netlerinizi girin ve hesaplayın.';
  String _yerlestirmeSonuc = 'AYT, OBP ve TYT netlerinizi girin ve hesaplayın.';
  int _selectedBolum = 1;

  void _hesapla() {
    FocusScope.of(context).unfocus();

    // Netleri al
    double matNet = double.tryParse(_netControllers.mat.text) ?? 0.0;
    double turkceNet = double.tryParse(_netControllers.turkce.text) ?? 0.0;
    double sosyalNet = double.tryParse(_netControllers.sosyal.text) ?? 0.0;
    double fenNet = double.tryParse(_netControllers.fen.text) ?? 0.0;
    double obpNotu = double.tryParse(_netControllers.obp.text) ?? 0.0;

    // OBP hesaplama
    double obpEk = (obpNotu * 0.6).clamp(0, 60);

    // TYT Ham Puanı hesaplama
    double tytPuan = (matNet * TYT_KATSAYILAR["Matematik"]! +
        turkceNet * TYT_KATSAYILAR["Turkce"]! +
        sosyalNet * TYT_KATSAYILAR["Sosyal"]! +
        fenNet * TYT_KATSAYILAR["Fen"]! + 100);

    // AYT Ham Puanı (Raw) hesaplama
    double aytRaw = 0.0;
    switch (_selectedBolum) {
      case 1:
        double aytMatNet = double.tryParse(_netControllers.aytMat.text) ?? 0.0;
        double aytFenNet = double.tryParse(_netControllers.aytFen.text) ?? 0.0;
        aytRaw = aytMatNet * AYT_KATSAYILAR["Matematik"]! + aytFenNet * AYT_KATSAYILAR["Fen"]!;
        break;
      case 2:
        double aytMatNet = double.tryParse(_netControllers.aytMat.text) ?? 0.0;
        double aytTdeNet = double.tryParse(_netControllers.aytTDE.text) ?? 0.0;
        aytRaw = aytMatNet * AYT_KATSAYILAR["Matematik"]! + aytTdeNet * AYT_KATSAYILAR["TDE"]!;
        break;
      case 3:
        double aytTdeNet = double.tryParse(_netControllers.aytTDE.text) ?? 0.0;
        double aytSosyalNet = double.tryParse(_netControllers.aytSosyal.text) ?? 0.0;
        aytRaw = aytTdeNet * AYT_KATSAYILAR["TDE"]! + aytSosyalNet * AYT_KATSAYILAR["Sosyal"]!;
        break;
      case 4:
        double aytDilNet = double.tryParse(_netControllers.aytDil.text) ?? 0.0;
        aytRaw = aytDilNet * AYT_KATSAYILAR["Dil"]!;
        break;
    }

    // AYT Raw puanını 100-500 aralığına normalize et
    double aytPuan = _aytHamNormalize(aytRaw, _selectedBolum);
    
    // YKS Ham Puanı (yerleştirme puanı için)
    double yksHam = 0.4 * tytPuan + 0.6 * aytPuan;

    // Yerleştirme Puanı
    double yerlestirmePuan = yksHam + obpEk;
    final int? tahminiYer = tahminiSiralama(yerlestirmePuan, siralamalar_yer);

    // Sonuçları güncelle
    setState(() {
      final int? tahminiTyt = tahminiSiralama(tytPuan, siralamalar_tyt);
      _tytSonuc =
          "TYT Ham Puanınız: ${tytPuan.toStringAsFixed(2)}\n"
          "Tahmini TYT Sıralamanız: ${tahminiTyt != null ? tahminiTyt.toString() : 'Verilemiyor'}";

      _yerlestirmeSonuc =
          "Yerleştirme Puanınız: ${yerlestirmePuan.toStringAsFixed(2)}\n"
          "Tahmini Yerleştirme Sıralamanız: ${tahminiYer != null ? tahminiYer.toString() : 'Verilemiyor'}";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('YKS Puan Hesaplayıcı'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionTitle('TYT Netleri'),
            _buildNetInput('Matematik', _netControllers.mat),
            _buildNetInput('Türkçe', _netControllers.turkce),
            _buildNetInput('Sosyal Bilimler', _netControllers.sosyal),
            _buildNetInput('Fen Bilimleri', _netControllers.fen),
            
            _buildSectionTitle('AYT Netleri'),
            _buildBolumDropdown(),
            const SizedBox(height: 10),
            _buildAytInputs(),

            _buildSectionTitle('OBP'),
            _buildNetInput('OBP (50-100)', _netControllers.obp),
            
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _hesapla,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15.0),
              ),
              child: const Text('Puanı ve Sıralamayı Hesapla', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 20),
            _buildResultCard(_tytSonuc),
            const SizedBox(height: 10),
            _buildResultCard(_yerlestirmeSonuc),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, bottom: 10.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildNetInput(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildBolumDropdown() {
    return DropdownButtonFormField<int>(
      decoration: const InputDecoration(
        labelText: 'Alan Seçiniz',
        border: OutlineInputBorder(),
      ),
      value: _selectedBolum,
      items: const [
        DropdownMenuItem(value: 1, child: Text('Sayısal')),
        DropdownMenuItem(value: 2, child: Text('Eşit Ağırlık')),
        DropdownMenuItem(value: 3, child: Text('Sözel')),
        DropdownMenuItem(value: 4, child: Text('Dil')),
      ],
      onChanged: (value) {
        setState(() {
          _selectedBolum = value!;
          _resetAytInputs();
        });
      },
    );
  }

  Widget _buildAytInputs() {
    switch (_selectedBolum) {
      case 1:
        return Column(
          children: [
            _buildNetInput('Matematik', _netControllers.aytMat),
            _buildNetInput('Fen Bilimleri', _netControllers.aytFen),
          ],
        );
      case 2:
        return Column(
          children: [
            _buildNetInput('Matematik', _netControllers.aytMat),
            _buildNetInput('Türk Dili ve Edebiyatı', _netControllers.aytTDE),
          ],
        );
      case 3:
        return Column(
          children: [
            _buildNetInput('Türk Dili ve Edebiyatı', _netControllers.aytTDE),
            _buildNetInput('Sosyal Bilimler-2', _netControllers.aytSosyal),
          ],
        );
      case 4:
        return _buildNetInput('Yabancı Dil', _netControllers.aytDil);
      default:
        return const SizedBox();
    }
  }

  void _resetAytInputs() {
    _netControllers.aytMat.clear();
    _netControllers.aytFen.clear();
    _netControllers.aytTDE.clear();
    _netControllers.aytSosyal.clear();
    _netControllers.aytDil.clear();
  }

  Widget _buildResultCard(String resultText) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          resultText,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}