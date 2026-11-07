import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailCtrl = TextEditingController();
  final senhaCtrl = TextEditingController();
  String? token;
  String? erro;
  bool carregando = false;

  Future<void> entrar() async {
    setState(() {
      carregando = true;
      token = null;
      erro = null;
    });
    try {
      final resp = await http.post(
        Uri.parse('http://127.0.0.1:5050/auth'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': emailCtrl.text,
          'password': senhaCtrl.text,
        }),
      );
      if (resp.statusCode == 200) {
        final dados = jsonDecode(resp.body);
        setState(() => token = dados['access_token']);
      } else {
        setState(() => erro = 'Login inválido (${resp.statusCode})');
      }
    } catch (e) {
      setState(() => erro = 'Não foi possível conectar à API');
    }
    setState(() => carregando = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('HelpDesk - Login')),
      body: Center(
        child: SizedBox(
          width: 400,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: emailCtrl,
                    decoration: const InputDecoration(labelText: 'E-mail'),
                  ),
                  TextField(
                    controller: senhaCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Senha'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: carregando ? null : entrar,
                    child: Text(carregando ? 'Entrando...' : 'Entrar'),
                  ),
                  const SizedBox(height: 16),
                  if (erro != null)
                    Text(erro!, style: const TextStyle(color: Colors.red)),
                  if (token != null) ...[
                    const Text('access_token recebido:'),
                    SelectableText(token!),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}