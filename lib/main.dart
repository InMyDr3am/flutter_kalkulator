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
  
  final List<String> historyList = [];
  final ScrollController _scrollController = ScrollController();

  final List<String> buttons = [
    'AC', '⌫', '%', '÷',
    '7', '8', '9', '×',
    '4', '5', '6', '-',
    '1', '2', '3', '+',
    '00', '0', '.', '='
  ];

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Mendeteksi orientasi layar (Portrait atau Landscape)
    final bool isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return Scaffold(
      body: SafeArea(
        child: isPortrait
            ? Column(
                children: [
                  _buildDisplayArea(isPortrait: true),
                  const Divider(color: Colors.white12, thickness: 1, height: 1),
                  _buildKeypadArea(isPortrait: true),
                ],
              )
            : Row(
                children: [
                  _buildDisplayArea(isPortrait: false),
                  const VerticalDivider(color: Colors.white12, thickness: 1, width: 1),
                  _buildKeypadArea(isPortrait: false),
                ],
              ),
      ),
    );
  }

  // --- BAGIAN 1: LAYAR HASIL & RIWAYAT ---
  Widget _buildDisplayArea({required bool isPortrait}) {
    return Expanded(
      flex: isPortrait ? 3 : 1, // Jika landscape, rasio layarnya dibagi 50:50 dengan keypad
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: historyList.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      historyList[index],
                      textAlign: TextAlign.end,
                      style: GoogleFonts.poppins(
                        // Menggunakan proporsi ukuran layar agar font tidak kebesaran di HP kecil
                        fontSize: MediaQuery.of(context).size.width * 0.045,
                        color: Colors.white.withOpacity(0.25),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            
            // Input berjalan (FittedBox mencegah overflow)
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                userInput,
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  color: Colors.white70,
                ),
              ),
            ),
            const SizedBox(height: 5),
            
            // Hasil akhir (FittedBox membuat angka mengecil otomatis jika sangat panjang)
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                result,
                style: GoogleFonts.poppins(
                  fontSize: 64,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- BAGIAN 2: KEYPAD TOMBOL ---
  Widget _buildKeypadArea({required bool isPortrait}) {
    return Expanded(
      flex: isPortrait ? 5 : 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        // LayoutBuilder mengukur ruang tersisa agar tombol bisa pas secara dinamis
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Kita punya 4 kolom dan 5 baris, beserta padding/spacing
            const int crossAxisCount = 4;
            const int mainAxisCount = 5;
            const double spacing = 12.0;

            // Menghitung lebar dan tinggi ideal satu tombol
            final double availableWidth = constraints.maxWidth - (spacing * (crossAxisCount - 1));
            final double availableHeight = constraints.maxHeight - (spacing * (mainAxisCount - 1));
            
            final double buttonWidth = availableWidth / crossAxisCount;
            final double buttonHeight = availableHeight / mainAxisCount;
            
            // Menentukan rasio aspek dinamis
            final double aspectRatio = buttonWidth / buttonHeight;

            return GridView.builder(
              itemCount: buttons.length,
              physics: const NeverScrollableScrollPhysics(), // Mematikan scroll karena sudah pas di layar
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: spacing,
                mainAxisSpacing: spacing,
                childAspectRatio: aspectRatio, 
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
            );
          },
        ),
      ),
    );
  }

  Color _getTextColor(String text) {
    if (text == 'AC' || text == '⌫') return const Color(0xFFFF6B6B); 
    if (text == '=' || text == '÷' || text == '×' || text == '-' || text == '+') return Colors.white; 
    if (text == '%') return const Color(0xFF4ECDC4); 
    return Colors.white; 
  }

  Color _getBgColor(String text) {
    if (text == '=') return const Color(0xFF4ECDC4); 
    if (text == '÷' || text == '×' || text == '-' || text == '+') return const Color(0xFF2C2F33); 
    return const Color(0xFF1E1E1E); 
  }

  void _handleButtonTap(String text) {
    if (text == 'AC') {
      userInput = '';
      result = '0';
      historyList.clear();
      return;
    }

    if (text == '⌫') {
      if (userInput.isNotEmpty) {
        userInput = userInput.substring(0, userInput.length - 1);
      }
      return;
    }

    if (text == '=') {
      if (userInput.isNotEmpty) {
        _calculateResult();
      }
      return;
    }

    if (userInput.isNotEmpty) {
      String lastChar = userInput[userInput.length - 1];
      bool isLastCharOperator = ['+', '-', '×', '÷', '%', '.'].contains(lastChar);
      bool isCurrentOperator = ['+', '-', '×', '÷', '%', '.'].contains(text);

      if (isLastCharOperator && isCurrentOperator) {
        return; 
      }
    }

    userInput += text;
  }

  void _calculateResult() {
    try {
      String finalInput = userInput
          .replaceAll('×', '*')
          .replaceAll('÷', '/');

      Parser p = Parser();
      Expression exp = p.parse(finalInput);
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);

      String finalResult;
      if (eval % 1 == 0) {
        finalResult = eval.toInt().toString();
      } else {
        finalResult = eval.toString();
      }

      String historyEntry = '$userInput = $finalResult';
      historyList.add(historyEntry);

      result = finalResult;
      userInput = ''; 
      
      _scrollToBottom();
      
    } catch (e) {
      result = 'Error';
    }
  }
}

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
          borderRadius: BorderRadius.circular(100), // Diubah menjadi 100 agar membentuk lingkaran/elips sempurna yang adaptif
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Center(
          // FittedBox di dalam tombol memastikan teks / icon tidak terpotong jika layar sangat kecil
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
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
        ),
      ),
    );
  }
}