import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meuapp/controller/drawner_controller.dart';
import 'package:meuapp/controller/firestore_controller.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meuapp/controller/login_controller.dart';
import 'package:meuapp/view/util.dart';

class DadosGerais extends StatefulWidget {
  const DadosGerais({Key? key}) : super(key: key);

  @override
  State<DadosGerais> createState() => _DadosGeraisState();
}

class _DadosGeraisState extends State<DadosGerais> {
  final firestoreController = FirestoreController();

  List<String> dts = [];
  List<String> motoristas = [];

  String dt = '';
  String km = '';
  String motorista = '';
  String placa = '';
  String data = '';
  String horario = '';
  var excel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Column(
          children: [
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
                        Navigator.of(context).pushReplacementNamed('/home');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.person),
                      title: const Text('Dados do Motorista'),
                      subtitle: const Text('Inserir os dados'),
                      onTap: () {
                        Navigator.of(context)
                            .pushReplacementNamed('/dados_motorista');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.reply),
                      title: const Text('Devoluções'),
                      subtitle: const Text('Devolução de produtos'),
                      onTap: () {
                        Navigator.of(context)
                            .pushReplacementNamed('/devolucoes');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.add),
                      title: const Text('Sobras'),
                      subtitle: const Text('Sobras de produtos'),
                      onTap: () {
                        Navigator.of(context).pushReplacementNamed('/sobras');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.remove),
                      title: const Text('Faltas'),
                      subtitle: const Text('Faltas de produtos'),
                      onTap: () {
                        Navigator.of(context).pushReplacementNamed('/faltas');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.swap_horiz),
                      title: const Text('Trocas'),
                      subtitle: const Text('Trocas de produtos'),
                      onTap: () {
                        Navigator.of(context).pushReplacementNamed('/trocas');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.warning),
                      title: const Text('Avarias'),
                      subtitle: const Text('Avarias de produtos'),
                      onTap: () {
                        Navigator.of(context).pushReplacementNamed('/avarias');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.local_shipping),
                      title: const Text('Caixas'),
                      subtitle: const Text('Caixas/Garrafas'),
                      onTap: () {
                        Navigator.of(context).pushReplacementNamed('/caixas');
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
        title: const Text('Dados Gerais'),
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              height: MediaQuery.of(context)
                  .size
                  .height, // Define a altura do contêiner igual à altura da tela
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('lib/images/new3.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            FutureBuilder<List<String>>(
              future: getDTS(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasData) {
                  dts = snapshot.data!; // Atualiza a lista de motoristas

                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: dts.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.delete),
                          title: Text(dts[index]),
                          onTap: () {
                            _removerDT(index);
                          },
                          subtitle: FutureBuilder<List<String>>(
                            future: obterNomeMotorista(dts[index]),
                            builder: (context, snapshotMotorista) {
                              if (snapshotMotorista.connectionState ==
                                  ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              } else if (snapshotMotorista.hasData) {
                                // Aqui você pode acessar a lista de nomes de motoristas
                                return Text(snapshotMotorista.data!.join(", "));
                              } else if (snapshotMotorista.hasError) {
                                return const Text(
                                    'Erro ao obter o nome do motorista');
                              } else {
                                return const Text('');
                              }
                            },
                          ),
                          trailing: FloatingActionButton(
                            onPressed: () async {
                              try {
                                //RECUPERANDO MOTORISTA
                                await moverDados('MotoristasGerais',
                                    'motoristas5', dts[index]);
                                //RECUPERANDO DEVOLUÇÕES
                                await moverDados('DevolucoesGerais',
                                    'devolucoes2', dts[index]);
                                //RECUPERANDO SOBRAS
                                await moverDados(
                                    'SobrasGerais', 'sobras2', dts[index]);
                                //RECUPERANDO FALTAS
                                await moverDados(
                                    'FaltasGerais', 'faltas2', dts[index]);
                                //RECUPERANDO TROCAS
                                await moverDados(
                                    'TrocasGerais', 'trocas2', dts[index]);
                                //RECUPERANDO AVARIAS
                                await moverDados(
                                    'AvariadosGerais', 'avarias2', dts[index]);
                                //RECUPERANDO CAIXAS
                                await moverDados(
                                    'Ativos', 'caixas2', dts[index]);
                                // Ação adicional ao pressionar o botão "+" dentro do Card
                                sucesso(context, "DADOS MOVIDOS COM SUCESSO!");
                                Navigator.of(context)
                                    .pushReplacementNamed('/home2');
                                _removerDT(index);
                              } catch (error) {
                                print(error);
                                erro(context,
                                    "Não foi possivel recuperar dados!");
                              }
                            },
                            mini: true,
                            child: const Icon(Icons.add),
                          ),
                        ),
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return const Text('Erro ao carregar DTS');
                } else {
                  return const CircularProgressIndicator();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<List<String>> obterNomeMotorista(String dt) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('DTSConferidas')
        .where('data', isEqualTo: getCurrentDate())
        .where('dt', isEqualTo: dt)
        .get();

    // obtendo nome do motorista na variavel nomesMotoristas
    final nomesMotoristas =
        snapshot.docs.map((doc) => doc['motorista'] as String).toList();

    return nomesMotoristas;
  }

  Future<List<String>> getDTS() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('DTSConferidas')
        .where('data', isEqualTo: (getCurrentDate()))
        .get();
    final motoristas = snapshot.docs.map((doc) => doc['dt'] as String).toList();
    return motoristas;
  }

  void _removerDT(int index) async {
// verificar se é admin

    LoginController loginController = LoginController();
    Map<String, dynamic> usuario = await loginController.usuarioLogado();
    String admin = usuario['admin'];

    if (admin == 'true' || admin == 'true2') {
      if (index >= 0 && index < dts.length) {
        String dtRemover = dts[index];

        // Remover motorista do Firestore
        await FirebaseFirestore.instance
            .collection('DTSConferidas')
            .where('dt', isEqualTo: dtRemover)
            .get()
            .then((snapshot) {
          if (snapshot.docs.isNotEmpty) {
            String docId = snapshot.docs.first.id;
            FirebaseFirestore.instance
                .collection('DTSConferidas')
                .doc(docId)
                .delete();
          }
        });

        // Remover motorista da lista
        setState(() {
          dts.removeAt(index);
        });
      }
    } else {
      erro(context, "Não autorizado!");
    }
  }
}

Future<void> moverDados(
    String colecaoOrigem, String colecaoDestino, String dt) async {
  try {
    // Obtenha a referência da coleção de origem
    CollectionReference origem =
        FirebaseFirestore.instance.collection(colecaoOrigem);

    // Obtenha os documentos da coleção de origem
    QuerySnapshot querySnapshot = await origem
        .where('data', isEqualTo: getCurrentDate())
        .where('dt', isEqualTo: dt)
        .get();

    // Obtenha a referência da coleção de destino
    CollectionReference destino =
        FirebaseFirestore.instance.collection(colecaoDestino);

    // Lista de operações assíncronas
    List<Future<void>> operacoes = [];

    // Itere sobre os documentos da coleção de origem
    querySnapshot.docs.forEach((QueryDocumentSnapshot document) {
      // Crie um novo documento na coleção de destino com os mesmos dados
      operacoes.add(destino.doc(document.id).set(document.data()));

      // Exclua o documento da coleção de origem
      operacoes.add(origem.doc(document.id).delete());
    });

    // Aguarde a conclusão de todas as operações
    await Future.wait(operacoes);

    print('Dados movidos com sucesso!');
  } catch (e) {
    print('Erro ao mover dados: $e');
  }
}

String getCurrentDate() {
  DateTime now = DateTime.now();
  String formattedDate = DateFormat('dd/MM/yyyy').format(now);
  return formattedDate;
}
