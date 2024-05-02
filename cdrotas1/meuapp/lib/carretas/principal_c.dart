import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meuapp/controller/login_controller.dart';
import 'package:meuapp/controller/drawner_controller.dart';
import 'package:meuapp/view/util.dart';

import '../reconferencia/sobre.dart';
import 'excel_carretas copy.dart';
import 'excel_carretas.dart';
import 'dart:async';

class PrincipalCarretas extends StatefulWidget {
  const PrincipalCarretas({super.key});

  @override
  State<PrincipalCarretas> createState() {
    return _PrincipalCarretasState();
  }
}

class _PrincipalCarretasState extends State<PrincipalCarretas> {
  final excelCarreta = ExcelCarreta();
  final excelCarreta2 = ExcelCarreta2();
  bool _funcaoChamada1 = false;

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    iniciarTimer();
  }

  void iniciarTimer() {
    const Duration tempoDeEspera = Duration(hours: 1);

    // Configura o timer para chamar a função a cada hora
    _timer = Timer.periodic(tempoDeEspera, (Timer timer) {
      // Reseta a variável para permitir uma nova chamada na próxima hora
      _funcaoChamada1 = false;
    });
  }

  @override
  void dispose() {
    // Certifica-se de cancelar o timer quando o widget for descartado
    _timer?.cancel();
    super.dispose();
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
                        leading: const Icon(Icons.add),
                        title: const Text('Gerar Relatorio de Entrada',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            )),
                        onTap: () async {
                          if (!_funcaoChamada1) {
                            await excelCarreta.CriarPlanilha();
                            sucesso(context, 'Planilha enviada com sucesso!');
                            _funcaoChamada1 = true;
                          } else {
                            erro(context,
                                'Aguarde 60 minutos para chamar a função novamente.');
                          }
                        }
                        // Simulando o processo de seleção de arquivo              },
                        ),
                    ListTile(
                      leading: const Icon(Icons.loop),
                      title: const Text('Trocar'),
                      subtitle: const Text('Trocar de servidor'),
                      onTap: () {
                        Navigator.of(context).pushReplacementNamed('/servidor');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.add),
                      title: const Text('Nova Entrada'),
                      subtitle: const Text('Registrar nova entrada'),
                      onTap: () {
                        Navigator.of(context).pushReplacementNamed('/entrada');
                      },
                    ),
                    //DESCARGA DE CARRETAS
                    ListTile(
                      leading: const Icon(Icons.arrow_downward),
                      title: const Text('Descarga'),
                      subtitle: const Text('Registrar descarga de carreta'),
                      onTap: () {
                        Navigator.of(context)
                            .pushReplacementNamed('/descargaCarreta');
                      },
                    ),
                    //SAIDA DE CARRETAS
                    ListTile(
                      leading: const Icon(Icons.arrow_upward),
                      title: const Text('Saida'),
                      subtitle: const Text('Registrar saída de carreta'),
                      onTap: () {
                        Navigator.of(context)
                            .pushReplacementNamed('/saidaCarreta');
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
        title: const Text('Controle de Entrada e Saida de Carretas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) => const SobrePage()));
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("lib/images/back2.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        padding: const EdgeInsets.all(10.0),
        child: Center(
          child: Column(
            children: [
              const SizedBox(
                height: 50,
              ),
              Card(
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).pushReplacementNamed('/entrada');
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10.0,
                      horizontal: 16.0,
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.person),
                        SizedBox(width: 20),
                        Text(
                          'Entrada de Carreta',
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
                    Navigator.of(context).pushReplacementNamed('/descarga');
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10.0,
                      horizontal: 16.0,
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.local_shipping),
                        SizedBox(width: 20),
                        Text(
                          'Descarga de Carreta',
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
                    Navigator.of(context).pushReplacementNamed('/saida');
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10.0,
                      horizontal: 16.0,
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.local_shipping),
                        SizedBox(width: 20),
                        Text(
                          'Saida de Carreta',
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
            ],
          ),
        ),
      ),
    );
  }
}
