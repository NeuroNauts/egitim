import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

// Channel verilerini tutmak için model sınıfı
class Channel {
  final String name;
  final String branch;
  final String link;
  final String? profileImageUrl;

  Channel({
    required this.name,
    required this.branch,
    required this.link,
    this.profileImageUrl,
  });

  factory Channel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Channel(
      name: data['name'] ?? '',
      branch: data['branch'] ?? '',
      link: data['link'] ?? '',
      profileImageUrl: data['profileImage'], // Firebase'den doğrudan çekiyoruz
    );
  }
}

class HocaOnerisiPage extends StatefulWidget {
  const HocaOnerisiPage({super.key});

  @override
  State<HocaOnerisiPage> createState() => _HocaOnerisiPageState();
}

class _HocaOnerisiPageState extends State<HocaOnerisiPage> {
  String? _selectedSubject = 'Matematik';
  final List<String> _subjects = [
    'Matematik',
    'Geometri',
    'Fizik',
    'Kimya',
    'Biyoloji',
    'Edebiyat',
    'Tarih',
    'Din Kültürü',
    'Felsefe',
    'Coğrafya'
  ];

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
              items: _subjects.map((String value) {
                return DropdownMenuItem<String>(value: value, child: Text(value));
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedSubject = newValue;
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
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('channels')
                      .where('branch', isEqualTo: _selectedSubject)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return const Center(child: Text('Bir hata oluştu.'));
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text(
                          'Bu ders için öneri bulunamadı.',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }

                    final recommendations = snapshot.data!.docs
                        .map((doc) => Channel.fromFirestore(doc))
                        .toList();

                    return ListView.builder(
                      itemCount: recommendations.length,
                      itemBuilder: (context, index) {
                        final channel = recommendations[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: InkWell(
                            onTap: () async {
                              final url = Uri.parse(channel.link);
                              if (await canLaunchUrl(url)) {
                                await launchUrl(url);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Link açılamıyor.')),
                                );
                              }
                            },
                            child: Row(
                              children: [
                                // Kapak fotoğrafı için widget
                                if (channel.profileImageUrl != null && channel.profileImageUrl!.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(right: 12.0),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: Image.network(
                                        channel.profileImageUrl!,
                                        width: 40,
                                        height: 40,
                                        fit: BoxFit.cover,
                                        loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                          if (loadingProgress == null) return child;
                                          return SizedBox(
                                            width: 40,
                                            height: 40,
                                            child: Center(
                                              child: CircularProgressIndicator(
                                                value: loadingProgress.expectedTotalBytes != null
                                                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                                    : null,
                                              ),
                                            ),
                                          );
                                        },
                                        errorBuilder: (context, error, stackTrace) {
                                          return const Icon(Icons.person, color: Colors.blueAccent, size: 40);
                                        },
                                      ),
                                    ),
                                  )
                                else
                                  const Padding(
                                    padding: EdgeInsets.only(right: 12.0),
                                    child: Icon(Icons.person, color: Colors.blueAccent, size: 40),
                                  ),
                                Expanded(
                                  child: Text(
                                    '${index + 1}. ${channel.name}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
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