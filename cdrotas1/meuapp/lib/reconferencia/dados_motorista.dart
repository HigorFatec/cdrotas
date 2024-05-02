import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meuapp/controller/drawner_controller.dart';
import 'package:meuapp/controller/firestore_controller.dart';
import 'package:meuapp/reconferencia/motorista_dt.dart';

import '../view/util.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class DadosMotoristaScreen5 extends StatefulWidget {
  final Motorista5? motoristaSelecionado;

  const DadosMotoristaScreen5({Key? key, this.motoristaSelecionado})
      : super(key: key);

  @override
  State<DadosMotoristaScreen5> createState() => _DadosMotoristaScreenState5();
}

class _DadosMotoristaScreenState5 extends State<DadosMotoristaScreen5> {
  final firestoreController = FirestoreController();

  final _motoristaController = TextEditingController();
  final _dtController = TextEditingController();
  final _placaController = TextEditingController();

  List<String> motoristas = [];

  String dt = '';
  String km = '';
  String motorista = '';
  String placa = '';
  String data = '';
  String horario = '';

  @override
  void initState() {
    super.initState();
    if (widget.motoristaSelecionado != null) {
      _motoristaController.text = widget.motoristaSelecionado!.motorista;
      _dtController.text = widget.motoristaSelecionado!.dt;
      _placaController.text = widget.motoristaSelecionado!.placa;
      motorista = _motoristaController.text;
      dt = _dtController.text;
      placa = _placaController.text;
    }
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
                        Navigator.of(context).pushReplacementNamed('/home2');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.person),
                      title: const Text('Dados do Motorista'),
                      subtitle: const Text('Inserir os dados'),
                      onTap: () {
                        Navigator.of(context)
                            .pushReplacementNamed('/dados_motorista5');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.reply),
                      title: const Text('Devoluções'),
                      subtitle: const Text('Devolução de produtos'),
                      onTap: () {
                        Navigator.of(context)
                            .pushReplacementNamed('/devolucoes2');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.add),
                      title: const Text('Sobras'),
                      subtitle: const Text('Sobras de produtos'),
                      onTap: () {
                        Navigator.of(context).pushReplacementNamed('/sobras2');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.remove),
                      title: const Text('Faltas'),
                      subtitle: const Text('Faltas de produtos'),
                      onTap: () {
                        Navigator.of(context).pushReplacementNamed('/faltas2');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.swap_horiz),
                      title: const Text('Trocas'),
                      subtitle: const Text('Trocas de produtos'),
                      onTap: () {
                        Navigator.of(context).pushReplacementNamed('/trocas2');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.warning),
                      title: const Text('Avarias'),
                      subtitle: const Text('Avarias de produtos'),
                      onTap: () {
                        Navigator.of(context).pushReplacementNamed('/avarias2');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.local_shipping),
                      title: const Text('Caixas'),
                      subtitle: const Text('Caixas/Garrafas'),
                      onTap: () {
                        Navigator.of(context).pushReplacementNamed('/caixas2');
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
        title: const Text('Reconferencia Dados Motorista'),
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
                                      leading: const Icon(Icons.delete),
                                      title: Text(motoristas[index]),
                                      onTap: () {
                                        _removerMotorista(index);
                                      },
                                      trailing: FloatingActionButton(
                                        onPressed: () {
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
                          setState(() {
                            dt = text;
                          });
                        },
                        controller: _dtController,
                        decoration: InputDecoration(
                          labelText: 'Número da DT',
                          border: const OutlineInputBorder(),
                          suffixIcon: GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, '/dts');
                            },
                            child: const Icon(Icons.list),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    Card(
                      child: TextFormField(
                        onChanged: (text) {
                          motorista = text;
                        },
                        controller: _motoristaController,
                        decoration: const InputDecoration(
                          labelText: 'Motorista',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.person),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    Card(
                      child: TextFormField(
                        onChanged: (text) {
                          km = text;
                        },
                        decoration: const InputDecoration(
                          labelText: 'KM',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.directions_car),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    Card(
                      child: TextFormField(
                        onChanged: (text) {
                          placa = text;
                        },
                        controller: _placaController,
                        decoration: const InputDecoration(
                          labelText: 'Placa',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.directions_car),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    Card(
                      color: Colors.grey[400],
                      child: TextFormField(
                        initialValue: getCurrentDate(),
                        enabled: false,
                        decoration: const InputDecoration(
                          labelText: 'Data',
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
                        enabled: false,
                        decoration: const InputDecoration(
                          labelText: 'Hora',
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
                          firestoreController.salvarDadosMotorista(
                              _dtController.text,
                              km,
                              _motoristaController.text,
                              _placaController.text);
                          //});
                          Navigator.pushNamed(context, '/home');
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
    final snapshot =
        await FirebaseFirestore.instance.collection('motoristas5').get();
    final motoristas =
        snapshot.docs.map((doc) => doc['motorista'] as String).toList();
    return motoristas;
  }

  Future<List<String>> getDts() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('motoristas5').get();
    final dts = snapshot.docs.map((doc) => doc['dt'] as String).toList();
    return dts;
  }

  Future<List<String>> getPlacas() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('motoristas5').get();
    final placas = snapshot.docs.map((doc) => doc['placa'] as String).toList();
    return placas;
  }

  bool _validateFields() {
    if (_dtController.text.isEmpty ||
        _motoristaController.text.isEmpty ||
        km.isEmpty ||
//        data.isEmpty ||
        _placaController.text.isEmpty) {
//        horario.isEmpty
      erro(context, 'Preencha todos os campos.');
      return false;
    } else {
      sucesso(context, 'Dados salvos com sucesso.');
      Navigator.of(context).pushNamed('/home');
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
          .collection('motoristas5')
          .where('motorista', isEqualTo: motoristaRemover)
          .get()
          .then((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          String docId = snapshot.docs.first.id;
          FirebaseFirestore.instance
              .collection('motoristas5')
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
