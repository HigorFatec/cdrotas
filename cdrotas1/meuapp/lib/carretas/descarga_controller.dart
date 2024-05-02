import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meuapp/controller/drawner_controller.dart';

import '../view/util.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'entrada_controller.dart';

class DescargaScreen extends StatefulWidget {
  const DescargaScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<DescargaScreen> createState() => DescargaScreenState();
}

class DescargaScreenState extends State<DescargaScreen> {
  final firestoreController = EntradaController();

  final _motoristaController = TextEditingController();
  final _dtController = TextEditingController();
  final _placaController = TextEditingController();

  List<String> motoristas = [];

  String placaCarreta = '';
  String transportadora = '';
  String tipo = 'Não';
  String dt = '';
  String telefone = '';
  String motorista = '';
  String placa = '';
  String data_saida = '';
  String horario_saida = '';
  String documentId = '';

  @override
  void initState() {
    super.initState();
    data_saida = getCurrentDate();
    horario_saida = getCurrentTime();
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
        title: const Text('Descarga de Carreta'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            FutureBuilder<List<String>>(
              future: getMotoristas(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasData) {
                  motoristas = snapshot.data!; // Atualiza a lista de motoristas
                  return FutureBuilder<List<String>>(
                    future: getPlacas(), // Obtém a lista de placas
                    builder: (context, placasSnapshot) {
                      if (placasSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (placasSnapshot.hasData) {
                        List<String> placas = placasSnapshot.data!;

                        return FutureBuilder<List<String>>(
                          future: getDts(), // Obtém a lista de DTs
                          builder: (context, dtsSnapshot) {
                            if (dtsSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            } else if (dtsSnapshot.hasData) {
                              List<String> dts = dtsSnapshot.data!;

                              return ListView.builder(
                                shrinkWrap: true,
                                itemCount: motoristas.length,
                                itemBuilder: (context, index) {
                                  return Card(
                                    child: ListTile(
                                      leading: GestureDetector(
                                        child:
                                            const Icon(Icons.delete, size: 40),
                                        onTap: () {
                                          _removerMotorista(index);
                                        },
                                      ),
                                      title: Text(motoristas[index]),
                                      trailing: FloatingActionButton(
                                        onPressed: () async {
                                          _motoristaController.text =
                                              motoristas[index];
                                          _placaController.text = placas[
                                              index]; // Defina a placa do motorista
                                          _dtController.text = dts[
                                              index]; // Defina a DT do motorista
                                          // Ação adicional ao pressionar o botão "+" dentro do Card
                                        },
                                        mini: true,
                                        child: const Icon(Icons.add),
                                      ),
                                    ),
                                  );
                                },
                              );
                            } else if (dtsSnapshot.hasError) {
                              return const Text('Erro ao carregar DTs');
                            } else {
                              return const Text('Carregando DTs...');
                            }
                          },
                        );
                      } else if (placasSnapshot.hasError) {
                        return const Text('Erro ao carregar placas');
                      } else {
                        return const Text('Carregando placas...');
                      }
                    },
                  );
                } else if (snapshot.hasError) {
                  return const Text('Erro ao carregar motoristas');
                } else {
                  return const CircularProgressIndicator();
                }
              },
            ),
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
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16.0),
                    Card(
                      child: TextFormField(
                        onChanged: (text) {
                          dt = text;
                        },
                        controller: _dtController,
                        decoration: const InputDecoration(
                          labelText: 'Número da DT',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.list),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    Card(
                      color: Colors.grey[400],
                      child: TextFormField(
                        initialValue: getCurrentDate(),
                        onChanged: (text) {
                          data_saida = text;
                        },
                        enabled: true,
                        decoration: const InputDecoration(
                          labelText: 'Data Inicio Descarga',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    Card(
                      color: Colors.grey[400],
                      child: TextFormField(
                        initialValue: getCurrentTime(),
                        onChanged: (text) {
                          horario_saida = text;
                        },
                        enabled: true,
                        decoration: const InputDecoration(
                          labelText: 'Hora Inicio Descarga',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.access_time),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    ElevatedButton(
                      onPressed: () {
                        if (_validateFields()) {
                          // SALVAR DADOS NO FIREBASE
                          firestoreController.salvarDadosDescarga(
                              _dtController.text, data_saida, horario_saida);
                          //});
                          Navigator.pushNamed(context, '/carretas');
                        }
                      },
                      child: const Text('Salvar'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<String>> getMotoristas() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('QuarentenaCarreta')
        .where('filial', isEqualTo: await IdentificacaoController.filial())
        .get();
    final motoristas =
        snapshot.docs.map((doc) => doc['motorista'] as String).toList();
    return motoristas;
  }

  Future<List<String>> getDts() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('QuarentenaCarreta')
        .where('filial', isEqualTo: await IdentificacaoController.filial())
        .get();
    final dts = snapshot.docs.map((doc) => doc['dt'] as String).toList();
    return dts;
  }

  Future<List<String>> getPlacas() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('QuarentenaCarreta')
        .where('filial', isEqualTo: await IdentificacaoController.filial())
        .get();
    final placas =
        snapshot.docs.map((doc) => doc['placa_cavalo'] as String).toList();
    return placas;
  }

  bool _validateFields() {
    if (_dtController.text.isEmpty) {
//        data.isEmpty ||
//        horario.isEmpty
      erro(context, 'Preencha todos os campos.');
      return false;
    } else {
      sucesso(context, 'Dados salvos com sucesso.');
      Navigator.of(context).pushNamed('/carretas');
      return true;
    }
  }

  String getCurrentDate() {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('dd/MM/yyyy').format(now);
    return formattedDate;
  }

  String getCurrentTime() {
    DateTime now = DateTime.now();
    String formattedTime = DateFormat('HH:mm:ss').format(now);
    return formattedTime;
  }

  void _removerMotorista(int index) async {
    if (index >= 0 && index < motoristas.length) {
      String motoristaRemover = motoristas[index];

      // Remover motorista do Firestore
      await FirebaseFirestore.instance
          .collection('QuarentenaCarreta')
          .where('motorista', isEqualTo: motoristaRemover)
          .get()
          .then((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          String docId = snapshot.docs.first.id;
          FirebaseFirestore.instance
              .collection('QuarentenaCarreta')
              .doc(docId)
              .delete();
        }
      });

      // Remover motorista da lista
      setState(() {
        motoristas.removeAt(index);
      });
    }
  }
}

Future<String> _getDocumentId(String motorista) async {
  final snapshot = await FirebaseFirestore.instance
      .collection('QuarentenaCarreta')
      .where('motorista', isEqualTo: motorista)
      .get();

  if (snapshot.docs.isNotEmpty) {
    return snapshot.docs.first.id;
  } else {
    return ''; // Retorne um valor adequado se o documento não for encontrado
  }
}
