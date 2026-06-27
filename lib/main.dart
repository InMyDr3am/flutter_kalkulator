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
  
  // List untuk menyimpan riwayat perhitungan sebelumnya
  final List<String> historyList = [];
  final ScrollController _scrollController = ScrollController();

  final List<String> buttons = [
    'AC', '⌫', '%', '÷',
    '7', '8', '9', '×',
    '4', '5', '6', '-',
    '1', '2', '3', '+',
    '00', '0', '.', '='
  ];

  // Fungsi utilitas untuk otomatis scroll riwayat ke paling bawah
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
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Bagian Layar Hasil & Riwayat (Flex 2.5 agar lebih luas untuk riwayat)
            Expanded(
              flex: 25,
              child: Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // KANVAS RIWAYAT (Dibuat samar dan bisa di-scroll)
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: historyList.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Text(
                              historyList[index],
                              textAlign: TextAlign.end,
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                // Menggunakan warna putih dengan opasitas rendah agar tampak samar/tidak tegas
                                color: Colors.white.withOpacity(0.25),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    
                    // INPUT YANG SEDANG BERJALAN
                    Text(
                      userInput,
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        color: Colors.white70, // Cukup tegas namun membedakan dengan hasil
                      ),
                    ),
                    const SizedBox(height: 5),
                    
                    // HASIL UTAMA
                    Text(
                      result,
                      style: GoogleFonts.poppins(
                        fontSize: 56,
                        fontWeight: FontWeight.w600,
                        color: Colors.white, // Paling tegas dan terang
                      ),
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            ),
            
            // Garis Pemisah Elegan
            const Divider(color: Colors.white12, thickness: 1),

            // Bagian Tombol (Keypad) (Flex 4)
            Expanded(
              flex: 40,
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
      historyList.clear(); // Opsional: Menghapus history saat AC ditekan
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

      // SIMPAN KE HISTORY SEBELUM MENGUBAH STATE UTAMA
      // Format: "2 + 3 = 5"
      String historyEntry = '$userInput = $finalResult';
      historyList.add(historyEntry);

      // Perbarui tampilan utama
      result = finalResult;
      userInput = ''; // Reset input agar user bisa langsung mengetik perhitungan baru
      
      // Gulir otomatis riwayat ke bawah agar yang terbaru selalu terlihat
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
          borderRadius: BorderRadius.circular(24), 
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