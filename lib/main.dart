import 'package:flutter/material.dart';

void main() {
  runApp(const ProfitWebApp());
}

class ProfitWebApp extends StatelessWidget {
  const ProfitWebApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '分潤計算器 Web App',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        fontFamily: '微軟正黑體',
      ),
      home: const CalculatorPage(),
    );
  }
}

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _breathingColor;

  final TextEditingController _salesAmount = TextEditingController(text: "50000");
  final TextEditingController _score = TextEditingController(text: "95");
  final TextEditingController _newStudents = TextEditingController(text: "5");
  bool _isCooperative = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    _breathingColor = ColorTween(
      begin: const Color(0xFF92400E),
      end: const Color(0xFFFBBF24),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Map<String, double> get results {
    double s = double.tryParse(_salesAmount.text) ?? 0;
    double sc = double.tryParse(_score.text) ?? 0;
    int ns = int.tryParse(_newStudents.text) ?? 0;
    
    double base = s * 0.15;
    double perf = s * (sc > 80 ? (sc - 80) : 0) * 0.0005;
    double nb = s * ns * 0.05;
    double coop = _isCooperative ? (s * 0.03) : 0;
    
    return {'total': base + perf + nb + coop, 'base': base, 'perf': perf, 'new': nb, 'coop': coop};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          // 修正點：使用 BoxConstraints 來限制最大寬度
          constraints: const BoxConstraints(maxWidth: 500), 
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                AnimatedBuilder(
                  animation: _breathingColor,
                  builder: (context, child) {
                    return Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: _breathingColor.value!, width: 2.5),
                        boxShadow: [
                          BoxShadow(
                            color: _breathingColor.value!.withOpacity(0.4),
                            blurRadius: 25,
                            spreadRadius: 1,
                          )
                        ],
                      ),
                      child: Column(
                        children: [
                          Text("預估結算分潤", style: TextStyle(color: _breathingColor.value, letterSpacing: 3, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 15),
                          Text("NT\$ ${results['total']!.round().toString()}", 
                            style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: Colors.white)),
                          const Divider(color: Colors.white10, height: 40),
                          _detailRow("基礎分潤 (15%)", results['base']!),
                          _detailRow("滿意度獎勵", results['perf']!),
                          _detailRow("新客招募獎勵", results['new']!),
                          _detailRow("合作任務加乘", results['coop']!),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 40),
                _buildInput("💰 銷售總額 (NT\$)", _salesAmount, Colors.blueAccent),
                _buildInput("⭐ 學員滿意度 (0-100)", _score, Colors.greenAccent),
                _buildInput("🚀 新客招募人數", _newStudents, Colors.redAccent),
                _buildDropdown(),
                const SizedBox(height: 40),
                AnimatedBuilder(
                  animation: _breathingColor,
                  builder: (context, child) {
                    return Container(
                      width: double.infinity,
                      height: 65,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [BoxShadow(color: _breathingColor.value!.withOpacity(0.3), blurRadius: 15)],
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _breathingColor.value,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          elevation: 0,
                        ),
                        onPressed: () {},
                        child: const Text("複製完整結算報表", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, double val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 14)),
          Text("NT\$ ${val.round()}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController ctrl, Color spectrumColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextField(
        controller: ctrl,
        keyboardType: TextInputType.number,
        onChanged: (v) => setState(() {}),
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white38),
          filled: true,
          fillColor: const Color(0xFF1E293B),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.white10)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: spectrumColor, width: 2.5)),
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<bool>(
          value: _isCooperative,
          isExpanded: true,
          dropdownColor: const Color(0xFF1E293B),
          onChanged: (v) => setState(() => _isCooperative = v!),
          items: const [
            DropdownMenuItem(value: false, child: Text("一般個人模式", style: TextStyle(color: Colors.white70))),
            DropdownMenuItem(value: true, child: Text("🤝 協同合作模式 (+3%)", style: TextStyle(color: Colors.purpleAccent, fontWeight: FontWeight.bold))),
          ],
        ),
      ),
    );
  }
}