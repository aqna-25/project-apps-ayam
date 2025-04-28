import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:projectayam/services/auth_service.dart';
import 'home.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController noHpController = TextEditingController();
  final TextEditingController tglLahirController = TextEditingController();
  final TextEditingController provinsiController = TextEditingController();
  final TextEditingController kotaController = TextEditingController();
  final TextEditingController alamatController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool hidePassword = true;
  bool hideConfirmPassword = true;
  bool isLoading = false;

  final _formKey = GlobalKey<FormState>();
  final InputDecoration _inputDecoration = InputDecoration(
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
  );

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  // Cek apakah user sudah login
  void _checkLoginStatus() async {
    final isLoggedIn = await AuthService.isLoggedIn();
    if (isLoggedIn && mounted) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const HomePage()));
    }
  }

  void handleSignUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Validasi tambahan untuk memastikan semua field terisi
      if (noHpController.text.isEmpty ||
          tglLahirController.text.isEmpty ||
          provinsiController.text.isEmpty ||
          kotaController.text.isEmpty ||
          alamatController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Semua field harus diisi")),
        );
        setState(() {
          isLoading = false;
        });
        return;
      }

      // Debug: Log data yang akan dikirim
      print("Sending registration data:");
      print("Name: ${nameController.text}");
      print("Email: ${emailController.text}");
      print("No HP: ${noHpController.text}");
      print("Tgl Lahir: ${tglLahirController.text}");
      print("Provinsi: ${provinsiController.text}");
      print("Kota: ${kotaController.text}");
      print("Alamat: ${alamatController.text}");

      final result = await AuthService.register(
        nameController.text.trim(),
        emailController.text.trim(),
        noHpController.text.trim(),
        tglLahirController.text.trim(),
        provinsiController.text.trim(),
        kotaController.text.trim(),
        alamatController.text.trim(),
        passwordController.text,
        confirmPasswordController.text,
      );

      if (!mounted) return;

      if (result['success']) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Registrasi berhasil")));

        // Cek token dan redirect ke halaman Home
        final isLoggedIn = await AuthService.isLoggedIn();
        if (!mounted) return;

        if (isLoggedIn) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomePage()),
          );
        } else {
          // Jika tidak berhasil login setelah registrasi, tetap di halaman yang sama
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Silakan login dengan akun yang baru dibuat"),
            ),
          );
        }
      } else {
        String errorMessage = result['message'] ?? "Terjadi kesalahan";

        // Menampilkan error validasi jika ada
        if (result['errors'] != null) {
          final errors = result['errors'] as Map<String, dynamic>;
          errorMessage = '';
          errors.forEach((key, value) {
            if (value is List) {
              for (var error in value) {
                errorMessage += '• $error\n';
              }
            }
          });
        }

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Terjadi kesalahan: $e")));
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _pilihTanggal(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF82985E),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF82985E),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Image.asset('Assets/back.png', width: 20, height: 20),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                "DAFTAR",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text("Buat Akun Baru"),
              const SizedBox(height: 24),

              TextFormField(
                controller: nameController,
                decoration: _inputDecoration.copyWith(
                  labelText: 'Nama Lengkap',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama lengkap harus diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: _inputDecoration.copyWith(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email harus diisi';
                  }
                  if (!value.contains('@') || !value.contains('.')) {
                    return 'Email tidak valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: noHpController,
                keyboardType: TextInputType.phone,
                decoration: _inputDecoration.copyWith(labelText: 'No HP'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'No HP harus diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: tglLahirController,
                decoration: _inputDecoration.copyWith(
                  labelText: 'Tanggal Lahir',
                  suffixIcon: const Icon(
                    Icons.calendar_today,
                    color: Colors.grey,
                  ),
                ),
                readOnly: true,
                onTap: () => _pilihTanggal(context, tglLahirController),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Tanggal Lahir harus diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: provinsiController,
                decoration: _inputDecoration.copyWith(labelText: 'Provinsi'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Provinsi harus diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: kotaController,
                decoration: _inputDecoration.copyWith(
                  labelText: 'Kota / Kabupaten',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Kota/Kabupaten harus diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: alamatController,
                decoration: _inputDecoration.copyWith(
                  labelText: 'Alamat Lengkap',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Alamat lengkap harus diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: passwordController,
                obscureText: hidePassword,
                decoration: _inputDecoration.copyWith(
                  labelText: 'Kata Sandi',
                  suffixIcon: IconButton(
                    icon: Icon(
                      hidePassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed:
                        () => setState(() => hidePassword = !hidePassword),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Kata sandi harus diisi';
                  }
                  if (value.length < 6) {
                    return 'Kata sandi minimal 6 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: confirmPasswordController,
                obscureText: hideConfirmPassword,
                decoration: _inputDecoration.copyWith(
                  labelText: 'Ulangi Kata Sandi',
                  suffixIcon: IconButton(
                    icon: Icon(
                      hideConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed:
                        () => setState(
                          () => hideConfirmPassword = !hideConfirmPassword,
                        ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Konfirmasi kata sandi harus diisi';
                  }
                  if (value != passwordController.text) {
                    return 'Kata sandi tidak cocok';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8EA458),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                onPressed: isLoading ? null : handleSignUp,
                child:
                    isLoading
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                        : const Text(
                          "Simpan",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
