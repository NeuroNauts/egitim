import 'package:flutter/material.dart';

class HocaOnerisiPage extends StatefulWidget {
  const HocaOnerisiPage({super.key});

  @override
  State<HocaOnerisiPage> createState() => _HocaOnerisiPageState();
}

class _HocaOnerisiPageState extends State<HocaOnerisiPage> {
  String? _selectedSubject = 'Matematik';
  String? _selectedDifficulty = 'Kolay';
  List<String> _recommendations = [];

  // Örnek hoca önerileri verisi.
  // Bu veriyi internetteki kaynaklardan (YouTube, eğitim platformları vb.)
  // topladığınız gerçek hoca isimleriyle doldurabilirsiniz.
  final Map<String, Map<String, List<String>>> _sourceRecommendations = {
    'Matematik': {
      'Kolay': ['Mert Hoca', 'İlyas Güneş','Sağlam Matematik','MatAkademi','Kampüs'],
      'Orta': ['Bıyıklı Matematik', 'Matematiğin Fatihi','Ceyhun Hoca','Rehber Matematik', 'Hocalara Geldik','Benim Hocam','Kenan Kara ile Geometri','Nurtaç Hoca'],
      'Zor': ['Şenol Hoca', 'Tunç Kurt','Rehber Matematik (ileri kısımları)','Bazı Kenan Kara dersleri (geometri ispat ağırlıklı)'],
    },
    'Fizik': {
      'Kolay': ['Barış Akıncıoğlu', 'Barıştıran Matematik', 'Tolga Bilgin Fizik'],
      'Orta': ['Umut Öncül Akademi', 'Fizikle Barış', 'VIP Fizik', 'Hocalara Geldik', 'Benim Hocam'],
      'Zor': ['Ümit Öncül (yoğun teori)', 'bazı Umut Öncül dersleri (özellikle AYT konu derinlikleri)'],
    },
    'Kimya': {
      'Kolay': [ 'Kimya Adası', 'Bebar Bilim', 'Ferrum'],
      'Orta': ['Kimya Özel', 'Kimyacı Gülçin Hoca', 'Hocalara Geldik', 'Benim Hocam', 'Khan Academy Türkçe'],
      'Zor': ['Evrim Ağacı (kimya içeren bilimsel içerikler), bazı Kimya Özel dersleri (üniversite düzeyine yakın konular)'],
    },
    'Biyoloji': {
      'Kolay': ['Cici Biyoloji', 'Gıcık Biyoloji', 'Yakışıklı Sorular'],
      'Orta': ['Selin Hoca', 'FUNDAmentals Biyoloji', 'Senin Biyolojin', 'Hocalara Geldik', 'Benim Hocam'],
      'Zor': ['Khan Academy Türkçe (detaylı biyoloji dersleri)', 'Evrim Ağacı (biyoloji-kimya-tarih kesişimi derin içerikler)'],
    },

    'Türkçe/Edebiyat': {
      'Kolay': ['Eyüp Hoca’yla Türkçe ve Edebiyat', 'Nazlı Hoca’m', 'Kampüs (Tonguç Akademi)', 'Açık Lise TV'],
      'Orta': [ 'Harun Ardıç', 'Rüştü Hoca Edebiyat Anlatıyor', 'Fulya Hoca', 'Benim Hocam', 'Hocalara Geldik'],
      'Zor': ['YOK'],
    },

    'Tarih & Coğrafya': {
      'Kolay': ['Basit Tarih', 'Sosyal Kale', 'CrashCourse'],
      'Orta': [ 'OK Tarih', 'Hocalara Geldik', 'Benim Hocam', 'Kampüs', 'KR Akademi', 'Khan Academy Türkçe'],
      'Zor': ['Evrim Ağacı (tarihsel bilim içerikleri)', 'Bazı Khan Academy Türkçe dersleri (dünya tarihi detaylı), CrashCourse (hızlı ve yoğun tempo)'],
    },
  };

  void _getRecommendations() {
    setState(() {
      _recommendations = _sourceRecommendations[_selectedSubject]![_selectedDifficulty] ?? [];
    });
  }

  @override
  void initState() {
    super.initState();
    _getRecommendations(); // Sayfa açıldığında ilk önerileri listeler
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hoca Önerileri', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE0F7FA), Color(0xFFBBDEFB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSelectionSection(),
            const SizedBox(height: 20),
            _buildRecommendationList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Ders Seçin',
                border: OutlineInputBorder(),
              ),
              value: _selectedSubject,
              items: _sourceRecommendations.keys.map((String value) {
                return DropdownMenuItem<String>(value: value, child: Text(value));
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedSubject = newValue;
                  _getRecommendations();
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Zorluk Seviyesi Seçin',
                border: OutlineInputBorder(),
              ),
              value: _selectedDifficulty,
              items: ['Kolay', 'Orta', 'Zor'].map((String value) {
                return DropdownMenuItem<String>(value: value, child: Text(value));
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedDifficulty = newValue;
                  _getRecommendations();
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationList() {
    return Expanded(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Hoca Önerileri',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const Divider(height: 20, thickness: 1),
              Expanded(
                child: _recommendations.isEmpty
                    ? const Center(
                        child: Text(
                          'Bu ders ve seviye için öneri bulunamadı.',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.builder(
                        itemCount: _recommendations.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              children: [
                                const Icon(Icons.person, color: Colors.blueAccent),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    '${index + 1}. ${_recommendations[index]}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}