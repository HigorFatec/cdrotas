import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meuapp/carretas/entrada_controller.dart';
import 'package:meuapp/controller/drawner_controller.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meuapp/controller/login_controller.dart';
import 'package:meuapp/view/util.dart';

class DescargaGerais extends StatefulWidget {
  const DescargaGerais({Key? key}) : super(key: key);

  @override
  State<DescargaGerais> createState() => _DescargaGeraisState();
}

class _DescargaGeraisState extends State<DescargaGerais> {
  final firestoreController = EntradaController();

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
                        Navigator.of(context).pushReplacementNamed('/carretas');
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text('Descarga Carretas'),
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              leading: GestureDetector(
                                child: const Icon(Icons.delete, size: 40),
                                onTap: () {
                                  _removerDT(index);
                                },
                              ),
                              title: Text("DT: ${dts[index]}"),
                              trailing: FloatingActionButton(
                                onPressed: () async {
                                  try {
                                    //RECUPERANDO MOTORISTA
                                    await moverDados('EntradaCarreta',
                                        'QuarentenaCarreta', dts[index]);
                                    //RECUPERANDO DEVOLUÇÕES

                                    // Ação adicional ao pressionar o botão "+" dentro do Card
                                    sucesso(
                                        context, "DADOS MOVIDOS COM SUCESSO!");
                                    Navigator.of(context).pushReplacementNamed(
                                        '/descargaCarreta');
                                    _removerDT(index);
                                  } catch (error) {
                                    print(error);
                                    erro(context,
                                        "Não foi possível recuperar dados!");
                                  }
                                },
                                mini: true,
                                child: const Icon(Icons.add),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: FutureBuilder<List<Map<String, String>>>(
                                future: obterNomeMotorista(dts[index]),
                                builder: (context, snapshotMotorista) {
                                  if (snapshotMotorista.connectionState ==
                                      ConnectionState.waiting) {
                                    return const CircularProgressIndicator();
                                  } else if (snapshotMotorista.hasData) {
                                    // Aqui você pode acessar a lista de nomes de motoristas
                                    return Text(
                                        " ${snapshotMotorista.data!.join(", ")}");
                                  } else if (snapshotMotorista.hasError) {
                                    return const Text(
                                        'Erro ao obter o nome do motorista');
                                  } else {
                                    return const Text('');
                                  }
                                },
                              ),
                            ),
                            const Divider(),
                          ],
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

  Future<List<Map<String, String>>> obterNomeMotorista(String dt) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('EntradaCarreta')
        //.where('data', isEqualTo: getCurrentDate())
        .where('filial', isEqualTo: await IdentificacaoController.filial())
        .where('dt', isEqualTo: dt)
        .get();

    // obtendo a placa da carreta e o nome do motorista e armazenando em uma lista de mapas
    final dadosCarretas = snapshot.docs.map((doc) {
      return {
        'Transportadora': doc['transportadora'] as String,
        'PLACA': doc['placa_carreta'] as String,
        'MOTORISTA': doc['motorista'] as String,
      };
    }).toList();

    return dadosCarretas;
  }

  Future<List<String>> getDTS() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('EntradaCarreta')
        .where('filial', isEqualTo: await IdentificacaoController.filial())
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
            .collection('EntradaCarreta')
            .where('dt', isEqualTo: dtRemover)
            .get()
            .then((snapshot) {
          if (snapshot.docs.isNotEmpty) {
            String docId = snapshot.docs.first.id;
            FirebaseFirestore.instance
                .collection('EntradaCarreta')
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
    QuerySnapshot querySnapshot = await origem.where('dt', isEqualTo: dt).get();

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
