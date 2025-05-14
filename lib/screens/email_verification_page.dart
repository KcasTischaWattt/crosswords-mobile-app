import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../services/api_service.dart';

class EmailVerificationPage extends StatefulWidget {
  final String email;
  final VoidCallback onVerificationSuccess;
  final VoidCallback onSkip;
  final VoidCallback toggleTheme;
  final bool isDarkMode;

  const EmailVerificationPage({
    super.key,
    required this.email,
    required this.onVerificationSuccess,
    required this.onSkip,
    required this.toggleTheme,
    required this.isDarkMode,
  });

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  String _code = '';
  bool _loading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _sendVerificationCode();
  }

  Future<void> _sendVerificationCode() async {
    try {
      await ApiService.post("/users/verification_code/send", {
        "email": widget.email,
      });
    } catch (e) {
      setState(() => _errorMessage = "Не удалось отправить код на почту.");
    }
  }

  Future<void> _checkCode() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      await ApiService.post("/users/verification_code/check", {
        "code": _code.trim(),
      });

      widget.onVerificationSuccess();
    } catch (e) {
      setState(() => _errorMessage = "Неверный код.");
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.wb_sunny : Icons.nights_stay,
                size: 28),
            onPressed: widget.toggleTheme,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              const Icon(Icons.mark_email_read_outlined,
                  size: 100, color: Colors.grey),
              const SizedBox(height: 24),
              Text(
                "Введите код из письма",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                "Мы отправили 6-значный код на ${widget.email}",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 32),
              PinCodeTextField(
                appContext: context,
                length: 6,
                keyboardType: TextInputType.number,
                animationType: AnimationType.fade,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(10),
                  fieldHeight: 50,
                  fieldWidth: 45,
                  activeFillColor:
                  isDark ? const Color(0xFF1F1F1F) : Colors.white,
                  selectedFillColor:
                  isDark ? const Color(0xFF1F1F1F) : Colors.white,
                  inactiveFillColor:
                  isDark ? const Color(0xFF1F1F1F) : Colors.white,
                  activeColor: Theme.of(context).primaryColor,
                  selectedColor: Theme.of(context).primaryColor,
                  inactiveColor: Colors.grey,
                ),
                animationDuration: const Duration(milliseconds: 300),
                enableActiveFill: true,
                onChanged: (value) {
                  setState(() => _code = value);
                },
              ),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(_errorMessage!,
                      style: const TextStyle(color: Colors.red)),
                ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _loading || _code.length != 6 ? null : _checkCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text("Подтвердить",
                    style: TextStyle(fontSize: 18, color: Colors.black)),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: widget.onSkip,
                child: const Text(
                  "Продолжить без подтверждения",
                  style: TextStyle(
                      fontSize: 16, decoration: TextDecoration.underline),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}