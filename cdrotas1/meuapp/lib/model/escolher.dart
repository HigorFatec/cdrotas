import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meuapp/controller/login_controller.dart';
import 'package:meuapp/controller/drawner_controller.dart';
import 'package:meuapp/view/util.dart';

class EscolherPage extends StatefulWidget {
  const EscolherPage({super.key});

  @override
  State<EscolherPage> createState() {
    return _EscolherPageState();
  }
}

class _EscolherPageState extends State<EscolherPage> {
  var excel;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        Navigator.of(context).pushReplacementNamed('/');
        erro(context, 'Usuário não está autenticado!');
      }
    });

    return Scaffold(
      drawer: Drawer(
        child: Column(
          children: [
            //Menu com nome,foto e cargo
            CustomDrawerHeader.getHeader(context),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.home),
                      title: const Text('Inicio'),
                      subtitle: const Text('Tela Inicial'),
                      onTap: () {
                        Navigator.of(context).pushReplacementNamed('/escolher');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.person),
                      title: const Text('Conferencia de Mapas'),
                      subtitle: const Text('Tela Inicial'),
                      onTap: () {
                        Navigator.of(context)
                            .pushReplacementNamed('/principal');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.home),
                      title: const Text('Retorno de Rotas'),
                      subtitle: const Text('Tela Inicial'),
                      onTap: () {
                        Navigator.of(context).pushReplacementNamed('/home');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.logout),
                      title: const Text('Logoff'),
                      subtitle: const Text('finaliza a sessão'),
                      onTap: () {
                        LoginController().logout();
                        Navigator.of(context).pushReplacementNamed('/');
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text('Escolher Servidor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              print("desativado");
              //Navigator.of(context).push(MaterialPageRoute(
              // builder: (BuildContext context) => const SobrePage()));
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("lib/images/fundoinicial.png"),
            fit: BoxFit.cover,
          ),
        ),
        padding: const EdgeInsets.all(10.0),
        child: Center(
          child: Column(
            children: [
              const SizedBox(
                height: 70,
              ),
              Card(
                child: InkWell(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10.0,
                      horizontal: 16.0,
                    ),
                    child: const Row(
                      children: [
                        SizedBox(width: 100),
                        Text(
                          'Tela Inicial',
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Card(
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).pushReplacementNamed('/principal');
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10.0,
                      horizontal: 16.0,
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.local_shipping),
                        SizedBox(width: 15),
                        Text(
                          'Conferência de Mapas de Saída',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Card(
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).pushReplacementNamed('/home');
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10.0,
                      horizontal: 16.0,
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.person),
                        SizedBox(width: 15),
                        Text(
                          'Conferência de Mapas de Retorno',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Card(
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).pushReplacementNamed('/carretas');
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10.0,
                      horizontal: 16.0,
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.local_shipping),
                        SizedBox(width: 15),
                        Text(
                          'Entrada/Saida Carretas',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Card(
                color: Colors.red,
                child: InkWell(
                  onTap: () async {
                    //OBTER O ATRIBUTO "ADMIN"
                    LoginController loginController = LoginController();
                    Map<String, dynamic> usuario =
                        await loginController.usuarioLogado();
                    String admin = usuario['admin'];

                    //VERIFICANDO SE É ADMIN
                    if (admin == 'true' ||
                        admin == 'true2' ||
                        admin == 'true3') {
                      try {
                        Navigator.of(context).pushReplacementNamed('/admin');
                      } catch (e) {
                        erro(context, 'Falha ao enviar a conferencia: $e');
                        print(e);
                      }
                      ;
                    } else {
                      (erro(context,
                          'Não autorizado, consulte o Administrador!'));
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10.0,
                      horizontal: 16.0,
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.local_shipping),
                        SizedBox(width: 15),
                        Text(
                          'Painel Administrador',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void exibirAviso(BuildContext context, String mensagem) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Aviso'),
          content: Text(mensagem),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context)
                    .pop(); // Fecha o diálogo ao pressionar OK.
              },
            ),
          ],
        );
      },
    );
  }
}
