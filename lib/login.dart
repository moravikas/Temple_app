import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'mainpage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static const String _configuredBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  bool _otpRequested = false;
  bool _showSuccessMessage = false;
  bool _isLoading = false;

  String get _apiBaseUrl {
    if (_configuredBaseUrl.isNotEmpty) {
      return _configuredBaseUrl;
    }

    if (kIsWeb) {
      return 'http://localhost:3000';
    }

    return defaultTargetPlatform == TargetPlatform.android
        ? 'http://127.0.0.1:3000'
        : 'http://localhost:3000';
  }

  @override
  void dispose() {
    _mobileController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _requestOtp() async {
    final String mobileNumber = _mobileController.text.trim();
    if (mobileNumber.length != 10 || int.tryParse(mobileNumber) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid 10-digit mobile number.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final http.Response response = await http.post(
        Uri.parse('$_apiBaseUrl/api/auth/request-otp'),
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode(<String, String>{'mobileNumber': mobileNumber}),
      );

      final Map<String, dynamic> body =
          jsonDecode(response.body) as Map<String, dynamic>;

      if (!mounted) {
        return;
      }

      if (response.statusCode == 200 && body['success'] == true) {
        setState(() {
          _otpRequested = true;
          _showSuccessMessage = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(body['message'] as String? ?? 'OTP requested.'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              body['message'] as String? ?? 'Unable to request OTP.',
            ),
          ),
        );
      }
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to connect to the server.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _login() async {
    final String mobileNumber = _mobileController.text.trim();
    final String otp = _otpController.text.trim();

    if (mobileNumber.length != 10 || int.tryParse(mobileNumber) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid 10-digit mobile number.')),
      );
      return;
    }

    if (!_otpRequested) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please request an OTP first.')),
      );
      return;
    }

    if (otp != '1234') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter OTP 1234 to continue for now.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final http.Response response = await http.post(
        Uri.parse('$_apiBaseUrl/api/auth/login'),
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode(<String, String>{
          'mobileNumber': mobileNumber,
          'otp': otp,
        }),
      );

      final Map<String, dynamic> body =
          jsonDecode(response.body) as Map<String, dynamic>;

      if (!mounted) {
        return;
      }

      if (response.statusCode == 200 && body['success'] == true) {
        setState(() {
          _showSuccessMessage = true;
        });

        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => const MainPage()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(body['message'] as String? ?? 'Login failed.'),
          ),
        );
      }
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to connect to the server.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color backgroundStart = const Color(0xFFF7F1E8);
    final Color backgroundEnd = const Color(0xFFE9D7C2);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [backgroundStart, backgroundEnd],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x22000000),
                        blurRadius: 30,
                        offset: Offset(0, 18),
                      ),
                    ],
                    border: Border.all(color: const Color(0xFFE9DCC9)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        height: 84,
                        width: 84,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF8C6239),
                              const Color(0xFFB98A5A).withValues(alpha: 0.95),
                            ],
                          ),
                        ),
                        child: const Icon(
                          Icons.temple_hindu,
                          color: Colors.white,
                          size: 42,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Ramesharalayam Temple',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                          color: Color(0xFF4E342E),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Sign in with your mobile number and OTP',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF7A6A5D),
                        ),
                      ),
                      const SizedBox(height: 28),
                      TextField(
                        controller: _mobileController,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        decoration: const InputDecoration(
                          labelText: 'Mobile Number',
                          prefixIcon: Icon(Icons.phone_outlined),
                          counterText: '',
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 54,
                        child: FilledButton(
                          onPressed: _isLoading ? null : _requestOtp,
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF8C6239),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Get OTP',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _otpController,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        enabled: _otpRequested,
                        decoration: InputDecoration(
                          labelText: 'Enter OTP',
                          prefixIcon: const Icon(Icons.lock_outline),
                          counterText: '',
                          helperText: _otpRequested
                              ? 'OTP has been requested'
                              : 'Request OTP to continue',
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 54,
                        child: FilledButton(
                          onPressed: _isLoading ? null : _login,
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF4E342E),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      if (_showSuccessMessage) ...[
                        const SizedBox(height: 18),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE9F6EC),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFB8E0C0)),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.verified_rounded,
                                color: Color(0xFF2E7D32),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Login successful. Welcome to Ramesharalayam Temple.',
                                  style: TextStyle(
                                    color: Color(0xFF2E7D32),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
