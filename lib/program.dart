import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:html/parser.dart';

class ProgramPage extends StatefulWidget {
  final String userName;

  const ProgramPage({super.key, required this.userName});

  @override
  State<ProgramPage> createState() => _ProgramPageState();
}

class _ProgramPageState extends State<ProgramPage> {
  final List<String> lessons = ['Matematik', 'Fizik', 'Kimya', 'Biyoloji', 'Edebiyat', 'Tarih', 'Coğrafya'];
  final List<String> selectedLessons = [];
  
  int studyHours = 4;
  String? selectedPeriod = 'Günlük';
  String? selectedTime = '09:00'; 
  String? selectedClass = '9. Sınıf';
  
  bool _isLoading = false;

  final TextEditingController noteController = TextEditingController();

  final List<String> periodOptions = ['Günlük', 'Haftalık', 'Aylık'];
  final List<String> timeOptions = [
    '09:00', '10:00', '11:00', '12:00', '13:00', '14:00', '15:00', '16:00', 
    '17:00', '18:00', '19:00', '20:00', '21:00', '22:00', '23:00'
  ];
  final List<String> classOptions = ['9. Sınıf', '10. Sınıf', '11. Sınıf', '12. Sınıf'];

  final Map<String, Map<String, List<String>>> _mebCurriculum = {
    '9. Sınıf': {
      'Matematik': ['Mantık', 'Kümeler', 'Denklem ve Eşitsizlikler', 'Üçgenler'],
      'Fizik': ['Fizik Bilimine Giriş', 'Madde ve Özellikleri', 'Kuvvet ve Hareket'],
      'Kimya': ['Kimya Bilimi', 'Atom ve Periyodik Sistem', 'Kimyasal Türler Arası Etkileşimler'],
    },
    '10. Sınıf': {
      'Matematik': ['Fonksiyonlar', 'Polinomlar', 'İkinci Dereceden Denklemler'],
      'Fizik': ['Basınç ve Kaldırma Kuvveti', 'Isı ve Sıcaklık', 'Elektrik ve Manyetizma'],
      'Kimya': ['Asitler, Bazlar ve Tuzlar', 'Kimyasal Tepkimeler'],
    },
    '11. Sınıf': {
      'Matematik': ['Trigonometri', 'Analitik Geometri', 'Logaritma'],
      'Fizik': ['Vektörler ve Kuvvet', 'Newton’un Hareket Yasaları', 'Bir Boyutta Sabit İvmeli Hareket'],
    },
    '12. Sınıf': {
      'Matematik': ['Türev', 'İntegral', 'Limit ve Süreklilik'],
      'Fizik': ['Çembersel Hareket', 'Basit Harmonik Hareket', 'Kütle Çekimi'],
    },
  };

  static const String _geminiApiKey = "AIzaSyD57e6Ly9RgFXTf5eg5nnryvo0nGQ3tV4k";
  static const String _geminiApiUrl = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent";

  void toggleLesson(String lesson) {
    setState(() {
      if (selectedLessons.contains(lesson)) {
        selectedLessons.remove(lesson);
      } else {
        selectedLessons.add(lesson);
      }
    });
  }

  Future<void> _generateProgramWithGemini() async {
    if (selectedLessons.isEmpty || selectedClass == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen bir ders ve sınıf seçin!')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    String kazanimlarText = '';
    for (var lesson in selectedLessons) {
      if (_mebCurriculum[selectedClass]?.containsKey(lesson) ?? false) {
        kazanimlarText += '\n- **$lesson:** ${_mebCurriculum[selectedClass]![lesson]!.join(', ')}';
      }
    }

    String promptText = """
    Sen bir çalışma programı oluşturan yapay zeka asistanısın. Kullanıcının verdiği bilgilere göre ona uygun, mantıklı ve detaylı bir ders çalışma programı oluştur. Programını Markdown formatında, başlıklar ve liste maddeleri kullanarak düzenle. 
    Kullanıcının adı: ${widget.userName}
    Sınıfı: $selectedClass
    Seçilen dersler: ${selectedLessons.join(', ')}
    Çalışma periyodu: $selectedPeriod
    Günlük ayrılacak toplam saat: $studyHours saat
    Çalışmaya başlangıç saati: $selectedTime
    Ek notlar: ${noteController.text.isNotEmpty ? noteController.text : 'Yok'}
    
    Bu dersler için MEB müfredatından çekilen bazı kazanımlar şunlardır:
    $kazanimlarText
    
    Programı oluştururken şu kurallara dikkat et:
    - Verilen kazanımları ve derslerin öncelik sırasını gözeterek programı **$selectedPeriod** olarak oluştur.
    - Belirtilen saat dilimini etkin kullan ve programı **$selectedTime**'da başlat.
    - Programı okunabilir ve motive edici bir dille yaz.
    - Programı **liste şeklinde, saat ve ders adlarını belirterek** düzenle. Lütfen programı tablo şeklinde hazırlama.
    - Programın sonuna "Başarılar dilerim, ${widget.userName}!" gibi motivasyonel bir cümle ekle.
    """;

    try {
      final response = await http.post(
        Uri.parse('$_geminiApiUrl?key=$_geminiApiKey'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "contents": [
            {
              "parts": [
                {"text": promptText}
              ]
            }
          ],
        }),
      );

      String programText = "Üzgünüm, program oluşturulamadı. Lütfen tekrar deneyin.";

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data != null && data['candidates'] != null && data['candidates'].isNotEmpty && data['candidates'][0]['content'] != null && data['candidates'][0]['content']['parts'] != null && data['candidates'][0]['content']['parts'].isNotEmpty && data['candidates'][0]['content']['parts'][0]['text'] != null) {
          programText = data['candidates'][0]['content']['parts'][0]['text'];
        }
      }

      _showProgramResult(programText);

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bir hata oluştu: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _removeMarkdown(String markdownText) {
    final document = parse(markdownText);
    return document.body?.text ?? markdownText;
  }

  Future<void> _saveProgramAsPdf(String programText) async {
    final pdf = pw.Document();

    try {
      final fontData = await rootBundle.load("assets/fonts/Roboto-Regular.ttf");
      final ttf = pw.Font.ttf(fontData);

      final plainText = _removeMarkdown(programText);

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Padding(
              padding: const pw.EdgeInsets.all(24),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Çalışma Programı',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                      font: ttf,
                    ),
                  ),
                  pw.SizedBox(height: 20),
                  pw.Text(
                    plainText,
                    style: pw.TextStyle(
                      fontSize: 12,
                      font: ttf,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );

      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/calisma_programi.pdf');
      
      await file.writeAsBytes(await pdf.save());
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Program PDF olarak kaydedildi: ${file.path}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF kaydederken bir hata oluştu: $e')),
        );
      }
    }
  }

  void _showProgramResult(String programText) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Oluşturulan Program', style: TextStyle(fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: double.maxFinite,
          child: Markdown(
            data: programText,
            styleSheet: MarkdownStyleSheet(
              h1: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepPurple),
              h2: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepPurple),
              p: const TextStyle(fontSize: 16),
              listBullet: const TextStyle(fontSize: 16),
              strong: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Kapat', style: TextStyle(color: Colors.blueAccent)),
          ),
          TextButton(
            onPressed: () {
              _saveProgramAsPdf(programText);
              Navigator.of(context).pop();
            },
            child: const Text('PDF Olarak Kaydet', style: TextStyle(color: Colors.blueAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Çalışma Programı Oluştur', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
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
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildClassSelection(),
            const SizedBox(height: 24),
            _buildLessonSelection(),
            const SizedBox(height: 24),
            _buildPeriodAndTime(),
            const SizedBox(height: 24),
            _buildStudyHours(),
            const SizedBox(height: 24),
            _buildNoteCard(),
            const SizedBox(height: 24),
            _buildGenerateButton(),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: CircularProgressIndicator(color: Colors.blueAccent),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        children: [
          const TextSpan(
            text: 'Bugün ne çalışacaksın, ',
            style: TextStyle(color: Colors.black),
          ),
          TextSpan(
            text: '${widget.userName}?',
            style: TextStyle(
              foreground: Paint()
                ..shader = const LinearGradient(
                  colors: [Colors.blue, Colors.purple],
                ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassSelection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'Sınıfını Seç',
            border: OutlineInputBorder(),
          ),
          items: classOptions.map((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
          value: selectedClass,
          onChanged: (val) {
            setState(() {
              selectedClass = val;
            });
          },
        ),
      ),
    );
  }

  Widget _buildLessonSelection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dersleri Seç',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: lessons.map((lesson) {
                final isSelected = selectedLessons.contains(lesson);
                return ChoiceChip(
                  label: Text(lesson),
                  selected: isSelected,
                  onSelected: (_) => toggleLesson(lesson),
                  selectedColor: Colors.blueAccent,
                  backgroundColor: Colors.grey[200],
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.blueGrey.shade800,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected ? Colors.blueAccent : Colors.grey.shade400,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPeriodAndTime() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Program Periyodu',
                border: OutlineInputBorder(),
              ),
              items: periodOptions.map((String value) {
                return DropdownMenuItem<String>(value: value, child: Text(value));
              }).toList(),
              value: selectedPeriod,
              onChanged: (val) {
                setState(() {
                  selectedPeriod = val;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Başlangıç Saati',
                border: OutlineInputBorder(),
              ),
              items: timeOptions.map((String value) {
                return DropdownMenuItem<String>(value: value, child: Text(value));
              }).toList(),
              value: selectedTime,
              onChanged: (val) {
                setState(() {
                  selectedTime = val;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudyHours() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Günlük Çalışma Saati:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            Row(
              children: [
                _circleIconButton(
                  Icons.remove,
                  () {
                    setState(() {
                      if (studyHours > 1) studyHours--;
                    });
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    '$studyHours',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                _circleIconButton(
                  Icons.add,
                  () {
                    setState(() {
                      if (studyHours < 24) studyHours++;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ek Notlar (Hedeflerin veya zorlandığın konular)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: noteController,
              decoration: InputDecoration(
                hintText: 'Örn: "Matematik konularını tekrar etmek istiyorum."',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenerateButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [Colors.blue, Colors.purple],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _generateProgramWithGemini,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : const Text(
                'Program Oluştur',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
      ),
    );
  }
  
  Widget _circleIconButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.blueAccent.withOpacity(0.1),
        ),
        padding: const EdgeInsets.all(8),
        child: Icon(icon, color: Colors.blueAccent, size: 20),
      ),
    );
  }
}