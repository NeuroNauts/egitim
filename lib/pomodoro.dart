import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart'; // audioplayers'ı import edin

class PomodoroPage extends StatefulWidget {
  const PomodoroPage({super.key});

  @override
  State<PomodoroPage> createState() => _PomodoroPageState();
}

class _PomodoroPageState extends State<PomodoroPage> with SingleTickerProviderStateMixin {
  // Pomodoro ayarları
  int _workMinutes = 25;
  int _shortBreakMinutes = 5;
  int _longBreakMinutes = 15;
  int _cycles = 4;

  // Zamanlayıcı durumu
  late int _remainingSeconds;
  int _currentCycle = 1;
  String _mode = "Çalışma";

  Timer? _timer;
  bool _isRunning = false;

  // Ses çalmak için AudioPlayer nesnesi
  late AudioPlayer _audioPlayer;

  // Animasyon için Controller
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = _workMinutes * 60;
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: _remainingSeconds),
    )..addListener(() {
        setState(() {});
      });

    // AudioPlayer'ı başlatın
    _audioPlayer = AudioPlayer();
  }

  /// Zamanlayıcıyı başlatır veya devam ettirir.
  void _startTimer() {
    if (_timer != null && _timer!.isActive) return;

    setState(() {
      _isRunning = true;
    });

    _animationController.duration = Duration(seconds: _remainingSeconds);
    _animationController.reverse(from: _remainingSeconds / _animationController.duration!.inSeconds);

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _playSound(); // Süre bitince ses çal
          _nextMode();
        }
      });
    });
  }

  /// Zamanlayıcıyı duraklatır.
  void _pauseTimer() {
    _timer?.cancel();
    _animationController.stop();
    setState(() {
      _isRunning = false;
    });
  }

  /// Zamanlayıcıyı sıfırlar ve başlangıç durumuna getirir.
  void _resetTimer() {
    _timer?.cancel();
    _animationController.stop();
    _animationController.value = 0.0;
    setState(() {
      _isRunning = false;
      _currentCycle = 1;
      _mode = "Çalışma";
      _remainingSeconds = _workMinutes * 60;
      _animationController.duration = Duration(seconds: _workMinutes * 60);
    });
  }

  /// Bir sonraki Pomodoro moduna geçiş yapar.
  void _nextMode() {
    _timer?.cancel();
    _animationController.stop();

    setState(() {
      if (_mode == "Çalışma") {
        if (_currentCycle % _cycles == 0) {
          _mode = "Uzun Mola";
          _remainingSeconds = _longBreakMinutes * 60;
        } else {
          _mode = "Kısa Mola";
          _remainingSeconds = _shortBreakMinutes * 60;
        }
      } else {
        _mode = "Çalışma";
        _currentCycle++;
        _remainingSeconds = _workMinutes * 60;
      }
      _animationController.duration = Duration(seconds: _remainingSeconds);
      _animationController.reverse(from: 1.0);
    });

    _startTimer();
  }

  /// Ses dosyasını çalar
  void _playSound() async {
    // Ses dosyasının yolunu belirtin
    await _audioPlayer.play(AssetSource('sounds/bip.mp3'));
  }

  /// Saniye cinsinden süreyi "MM:SS" formatına dönüştürür.
  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int secs = seconds % 60;
    return "${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}";
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    _audioPlayer.dispose(); // AudioPlayer'ı dispose edin
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Arayüz kodunuz aynı kalacak, sadece `Stack` içindeki `Column` widget'ı `Text` ile değiştirilmiştir.
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pomodoro Zamanlayıcı', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFE0F7FA),
              Color(0xFFBBDEFB),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Card(
                margin: const EdgeInsets.only(bottom: 24),
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text(
                            "Mod:",
                            style: TextStyle(
                                fontSize: 18,
                                color: Colors.blueGrey.shade700,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            _mode,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: _mode == "Çalışma"
                                  ? Colors.blueAccent
                                  : (_mode == "Kısa Mola" ? Colors.green : Colors.orange),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            "Döngü:",
                            style: TextStyle(
                                fontSize: 18,
                                color: Colors.blueGrey.shade700,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "$_currentCycle / $_cycles",
                            style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: SizedBox(
                    width: 320,
                    height: 320,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        AnimatedBuilder(
                          animation: _animationController,
                          builder: (context, child) {
                            return CustomPaint(
                              size: const Size(320, 320),
                              painter: TimerPainter(
                                animation: _animationController,
                                backgroundColor: Colors.blueGrey.shade200,
                                progressColor: _mode == "Çalışma"
                                    ? Colors.blueAccent
                                    : (_mode == "Kısa Mola" ? Colors.green : Colors.orange),
                              ),
                            );
                          },
                        ),
                        Text(
                          _formatTime(_remainingSeconds),
                          style: const TextStyle(
                            fontSize: 90,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _controlButton(
                    icon: _isRunning ? Icons.pause : Icons.play_arrow,
                    label: _isRunning ? "DURAKLAT" : "BAŞLAT",
                    color: _isRunning ? Colors.orange.shade700 : Colors.green.shade700,
                    onPressed: _isRunning ? _pauseTimer : _startTimer,
                  ),
                  const SizedBox(width: 24),
                  _controlButton(
                    icon: Icons.stop,
                    label: "SIFIRLA",
                    color: Colors.red.shade700,
                    onPressed: _resetTimer,
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Expanded(
                child: ListView(
                  children: [
                    _buildSettingRow(
                      label: "Çalışma Süresi (dk)",
                      value: _workMinutes,
                      onChanged: (val) {
                        setState(() {
                          _workMinutes = val;
                          if (_mode == "Çalışma" && !_isRunning) {
                            _remainingSeconds = val * 60;
                            _animationController.duration = Duration(seconds: _remainingSeconds);
                            _animationController.value = 0.0;
                          }
                        });
                      },
                    ),
                    _buildSettingRow(
                      label: "Kısa Mola (dk)",
                      value: _shortBreakMinutes,
                      onChanged: (val) {
                        setState(() => _shortBreakMinutes = val);
                      },
                    ),
                    _buildSettingRow(
                      label: "Uzun Mola (dk)",
                      value: _longBreakMinutes,
                      onChanged: (val) {
                        setState(() => _longBreakMinutes = val);
                      },
                    ),
                    _buildSettingRow(
                      label: "Döngü Sayısı",
                      value: _cycles,
                      onChanged: (val) {
                        setState(() => _cycles = val);
                      },
                      minValue: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Diğer yardımcı widget'lar aynı kalacak
  Widget _controlButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 30, color: Colors.white),
      label: Text(
        label,
        style: const TextStyle(fontSize: 18, color: Colors.white),
      ),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 5,
      ),
    );
  }

  Widget _buildSettingRow({
    required String label,
    required int value,
    required Function(int) onChanged,
    int minValue = 1,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(label, style: const TextStyle(fontSize: 18, color: Colors.blueGrey)),
            ),
            Row(
              children: [
                _circleIconButton(
                  Icons.remove,
                  () {
                    if (value > minValue) onChanged(value - 1);
                  },
                  Colors.deepOrange,
                ),
                SizedBox(
                  width: 40,
                  child: Text(
                    '$value',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                  ),
                ),
                _circleIconButton(
                  Icons.add,
                  () {
                    onChanged(value + 1);
                  },
                  Colors.teal,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _circleIconButton(IconData icon, VoidCallback onTap, Color color) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
        padding: const EdgeInsets.all(8),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }
}

// --- Animasyonlu İlerleme Göstergesi İçin CustomPainter ---
class TimerPainter extends CustomPainter {
  final Animation<double> animation;
  final Color backgroundColor;
  final Color progressColor;

  TimerPainter({
    required this.animation,
    required this.backgroundColor,
    required this.progressColor,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    Paint backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = 15
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    Paint progressPaint = Paint()
      ..color = progressColor
      ..strokeWidth = 15
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    Offset center = Offset(size.width / 2, size.height / 2);
    double radius = (size.width / 2) - (backgroundPaint.strokeWidth / 2);

    canvas.drawCircle(center, radius, backgroundPaint);

    double progressSweepAngle = 2 * 3.14159265359 * (1.0 - animation.value);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14159265359 / 2,
      progressSweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant TimerPainter oldDelegate) {
    return animation.value != oldDelegate.animation.value ||
        backgroundColor != oldDelegate.backgroundColor ||
        progressColor != oldDelegate.progressColor;
  }
}