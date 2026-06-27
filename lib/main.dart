import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:math_expressions/math_expressions.dart';

void main() {
  runApp(const KalkulatorPremiumApp());
}

class KalkulatorPremiumApp extends StatelessWidget {
  const KalkulatorPremiumApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kalkulator Premium',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: const KalkulatorLayar(),
    );
  }
}

class KalkulatorLayar extends StatefulWidget {
  const KalkulatorLayar({super.key});

  @override
  State<KalkulatorLayar> createState() => _KalkulatorLayarState();
}

class _KalkulatorLayarState extends State<KalkulatorLayar> {
  String userInput = '';
  String result = '0';

  final List<String> buttons = [
    'AC', '⌫', '%', '÷',
    '7', '8', '9', '×',
    '4', '5', '6', '-',
    '1', '2', '3', '+',
    '00', '0', '.', '='
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Bagian Layar Hasil
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.all(24),
                alignment: Alignment.bottomRight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      userInput,
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        color: Colors.white54,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      result,
                      style: GoogleFonts.poppins(
                        fontSize: 64,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            ),
            
            // Garis Pemisah Elegan
            const Divider(color: Colors.white12, thickness: 1),

            // Bagian Tombol (Keypad)
            Expanded(
              flex: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: GridView.builder(
                  itemCount: buttons.length,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    return CustomButton(
                      text: buttons[index],
                      textColor: _getTextColor(buttons[index]),
                      bgColor: _getBgColor(buttons[index]),
                      onTap: () {
                        setState(() {
                          _handleButtonTap(buttons[index]);
                        });
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Logika Warna Teks
  Color _getTextColor(String text) {
    if (text == 'AC' || text == '⌫') return const Color(0xFFFF6B6B); // Merah lembut
    if (text == '=' || text == '÷' || text == '×' || text == '-' || text == '+') return Colors.white; // Putih untuk operator utama
    if (text == '%') return const Color(0xFF4ECDC4); // Tosca
    return Colors.white; // Angka
  }

  // Logika Warna Background
  Color _getBgColor(String text) {
    if (text == '=') return const Color(0xFF4ECDC4); // Tosca terang untuk Sama Dengan
    if (text == '÷' || text == '×' || text == '-' || text == '+') return const Color(0xFF2C2F33); // Abu gelap untuk operator
    return const Color(0xFF1E1E1E); // Hitam keabuan untuk angka
  }

  // Logika Utama Kalkulator
  void _handleButtonTap(String text) {
    if (text == 'AC') {
      userInput = '';
      result = '0';
      return;
    }

    if (text == '⌫') {
      if (userInput.isNotEmpty) {
        userInput = userInput.substring(0, userInput.length - 1);
      }
      return;
    }

    if (text == '=') {
      _calculateResult();
      return;
    }

    // Mencegah input ganda pada operator
    if (userInput.isNotEmpty) {
      String lastChar = userInput[userInput.length - 1];
      bool isLastCharOperator = ['+', '-', '×', '÷', '%', '.'].contains(lastChar);
      bool isCurrentOperator = ['+', '-', '×', '÷', '%', '.'].contains(text);

      if (isLastCharOperator && isCurrentOperator) {
        return; // Jangan tambahkan jika operator ditekan dua kali berturut-turut
      }
    }

    userInput += text;
  }

  void _calculateResult() {
    try {
      // Mengubah simbol UI menjadi simbol yang bisa dibaca package math_expressions
      String finalInput = userInput
          .replaceAll('×', '*')
          .replaceAll('÷', '/');

      Parser p = Parser();
      Expression exp = p.parse(finalInput);
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);

      // Membersihkan angka desimal .0 jika hasilnya bilangan bulat
      if (eval % 1 == 0) {
        result = eval.toInt().toString();
      } else {
        result = eval.toString();
      }
    } catch (e) {
      result = 'Error';
    }
  }
}

// Widget Custom untuk Tombol agar terlihat Premium
class CustomButton extends StatelessWidget {
  final String text;
  final Color textColor;
  final Color bgColor;
  final VoidCallback onTap;

  const CustomButton({
    super.key,
    required this.text,
    required this.textColor,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(24), // Sudut membulat yang elegan
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              color: textColor,
              fontSize: 28,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}