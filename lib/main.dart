import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'screens/catalogo_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  runApp(const FerreteriaApp());
}

class FerreteriaApp extends StatelessWidget {
  const FerreteriaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ferreteria App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A3A6B),
        ),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usuario = TextEditingController();
  final _password = TextEditingController();
  String _rol = 'Empleado';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: Center(
        child: Container(
          width: 380,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFD6E4F0)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A3A6B),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.hardware, color: Colors.white, size: 28),
              ),
              const SizedBox(height: 16),
              const Text('Ferreteria',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Color(0xFF1A3A6B)),
              ),
              const SizedBox(height: 4),
              const Text('Ingresa con tu usuario',
                style: TextStyle(fontSize: 13, color: Color(0xFF888780)),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _usuario,
                decoration: InputDecoration(
                  labelText: 'Usuario',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _password,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Contrasena',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 16),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Rol', style: TextStyle(fontSize: 13, color: Color(0xFF888780))),
              ),
              const SizedBox(height: 6),
              Row(
                children: ['Empleado', 'Dueno'].map((rol) {
                  final selected = _rol == rol;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _rol = rol),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: selected ? const Color(0xFFE6F1FB) : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: selected ? const Color(0xFF185FA5) : const Color(0xFFD3D1C7),
                          ),
                        ),
                        child: Text(rol,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w500,
                            color: selected ? const Color(0xFF185FA5) : const Color(0xFF888780),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CatalogoScreen(rol: _rol),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A3A6B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Ingresar', style: TextStyle(fontSize: 15)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
