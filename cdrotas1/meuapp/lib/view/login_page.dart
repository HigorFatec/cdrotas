import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../controller/login_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  var txtEmail = TextEditingController();
  var txtSenha = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  Widget _body() {
    return SingleChildScrollView(
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 200,
                height: 200,
                child: ClipOval(
                  child: Image.asset('lib/images/novologo.png'),
                ),
              ),
              Container(
                height: 20,
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 12, right: 12, top: 20, bottom: 12),
                  child: Column(children: [
                    TextField(
                      controller: txtEmail,
                      decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: txtSenha,
                      obscureText: true,
                      decoration: const InputDecoration(
                          labelText: 'Senha',
                          prefixIcon: Icon(Icons.password),
                          border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            LoginController().login(
                              context,
                              txtEmail.text,
                              txtSenha.text,
                            );
                          },
                          child: const Text('Entrar'),
                        ),
                        const SizedBox(width: 145),
                        ElevatedButton(
                            child: const Text('Cadastrar'),
                            onPressed: () {
                              Navigator.of(context).pushNamed('/cadastrar');
                            }),
                      ],
                    ),
                    GestureDetector(
                      onTap: _irParaRecuperarSenha,
                      child: const Column(
                        children: [
                          Text(
                            'Esqueceu a senha?',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    )
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        Navigator.of(context).pushReplacementNamed('/servidor');
        //sucesso(context, 'Usuário está autenticado!');
      }
    });
    return Scaffold(
        //  appBar: AppBar(
        //    title: const Text('Login'),
        //  ),
        body: Stack(
      children: [
        SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Image.asset(
              'lib/images/truck.png',
              fit: BoxFit.cover,
            )),
        Container(
          color: Colors.black.withOpacity(0.5),
        ),
        _body(),
      ],
    ));
  }

  void _irParaRecuperarSenha() {
    Navigator.of(context).pushNamed('/recuperar_senha');
  }
}
