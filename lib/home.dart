import 'package:flutter/material.dart';
import 'program.dart'; // ProgramPage'inizin burada olduğunu varsayıyorum
import 'pomodoro.dart'; // PomodoroPage'inizin burada olduğunu varsayıyorum
import 'rehberlik.dart'; // RehberlikPage'inizin burada olduğunu varsayıyorum
import 'kaynak_onerisi.dart';
import 'hoca_onerisi.dart'; // HocaOnerisiPage'i buraya import ediyoruz // KaynakOnerisiPage'i buraya import ediyoruz

class HomePage extends StatelessWidget {
  final String userName;

  const HomePage({super.key, required this.userName});

  /// Özellik kartlarına tıklandığında ilgili sayfaya yönlendirme yapar.
  void _navigateToPage(BuildContext context, String pageLabel) {
    Widget destinationPage;

    // `pageLabel` değerine göre doğru sayfayı belirle
    switch (pageLabel) {
      case 'Program Çıkar':
        destinationPage = ProgramPage(userName: userName);
        break;
      case 'Pomodoro':
        destinationPage = const PomodoroPage();
        break;
      case 'Rehberlik':
        destinationPage = RehberlikPage(userName: userName);
        break;
      case 'Kaynak Önerisi': // Kaynak Önerisi sayfasını ekliyoruz
        destinationPage = const KaynakOnerisiPage();
        break;
      case 'Hoca Önerisi':
         destinationPage = const HocaOnerisiPage();
         break;
      default:
        // Henüz hazır olmayan sayfalar için genel bir 'yakında' sayfası göster
        destinationPage = Scaffold(
          appBar: AppBar(
            title: Text(pageLabel),
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.construction, size: 60, color: Colors.blueGrey),
                const SizedBox(height: 16),
                Text(
                  '$pageLabel sayfası yakında hizmetinizde!',
                  style: const TextStyle(fontSize: 20, color: Colors.blueGrey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
        break;
    }

    // Belirlenen sayfaya git
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => destinationPage),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Uygulama özellikleri ve ilgili ikonları
    final List<Map<String, dynamic>> features = [
      {'label': 'Program Çıkar', 'icon': Icons.edit_calendar}, // Daha uygun bir ikon
      {'label': 'Pomodoro', 'icon': Icons.timer},
      {'label': 'Rehberlik', 'icon': Icons.assistant}, // Danışmanlık için
      {'label': 'Kaynak Önerisi', 'icon': Icons.menu_book}, // Kitap için
      {'label': 'Hoca Önerisi', 'icon': Icons.person_search}, // Öğretmen arama için
      // {'label': 'Yeni Özellik', 'icon': Icons.stars}, // İhtiyaç olursa eklenebilir
    ];

    return Scaffold(
      backgroundColor: Colors.transparent, // Gradyan için şeffaf olmalı
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFBBDEFB), // Daha Koyu Mavi
              Color(0xFFE0F7FA), // Açık Mavi
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea( // Kenar boşluklarını otomatik ayarlar (notch, durum çubuğu vb.)
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Metni sola hizala
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 4), // Yukarıdan ve yandan boşluk
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hoş Geldin,',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w400,
                        color: Colors.blueGrey.shade800,
                      ),
                    ),
                    Text(
                      userName,
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey.shade900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Ne öğrenmek istersin?',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.blueGrey.shade700,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24), // Özellik kartlarından önceki boşluk

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0), // Yanlardan boşluk
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, // Her satırda 2 kart
                      crossAxisSpacing: 4.0, // Yatay boşluk
                      mainAxisSpacing: 4.0, // Dikey boşluk
                      childAspectRatio: 0.8, // Kartların genişlik/yükseklik oranı
                    ),
                    itemCount: features.length,
                    itemBuilder: (context, index) {
                      final feature = features[index];
                      return FeatureCard(
                        label: feature['label'] as String,
                        icon: feature['icon'] as IconData,
                        onTap: () => _navigateToPage(context, feature['label'] as String),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Yeniden kullanılabilir özellik kartı widget'ı
class FeatureCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const FeatureCard({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6, // Hafif gölge
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18), // Yuvarlak köşeler
      ),
      clipBehavior: Clip.antiAlias, // İçeriği köşelere göre kırp
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.blueAccent.withOpacity(0.3), // Tıklama efekti rengi
        highlightColor: Colors.blueAccent.withOpacity(0.1), // Basılı tutma efekti rengi
        child: Padding(
          padding: const EdgeInsets.all(16.0), // Kartın iç boşluğu
          child: Column(
            // mainAxisAlignment'ı 'start' olarak değiştirerek içeriği yukarı hizaladım.
            mainAxisAlignment: MainAxisAlignment.start,
            // crossAxisAlignment'ı 'center' yaparak ikon ve metni yatayda ortaladım.
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // İkona yukarıdan biraz boşluk ekledim, böylece tam tepeye yapışmaz.
              const SizedBox(height: 10),
              Icon(
                icon,
                size: 60, // İkon boyutu
                color: Colors.blueAccent.shade700,
              ),
              // İkon ile metin arasındaki boşluğu korudum.
              const SizedBox(height: 12),
              // Metnin esnek bir şekilde kalan alanı doldurmasını sağladım.
              // Bu sayede metin uzunluğu ne olursa olsun kartın alt kısmına doğru yayılabilir.
              Expanded(
                child: Align( // Metni dikeyde üste hizaladım (Expanded içinde).
                  alignment: Alignment.topCenter,
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                    ),
                    maxLines: 2, // Uzun etiketler için metni iki satırla sınırladım.
                    overflow: TextOverflow.ellipsis, // Taşarsa ... göster
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}