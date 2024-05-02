import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../controller/login_controller.dart';
import 'entrada.dart';

class CarretaDT {
  final String nome;
  final String dt;

  CarretaDT({
    required this.nome,
    required this.dt,
  });
}

final IdentificacaoController = LoginController();

Future<bool> _verificarDtNoFirebase(String dt) async {
  final query = await FirebaseFirestore.instance
      .collection('CarretasComEntrada')
      .where('dt', isEqualTo: dt)
      .get();

  //print('Verificando Firestore para DT: $dt, Existe: ${query.docs.isNotEmpty}');
  return query.docs.isNotEmpty;
}

Future<List<CarretaDT>?> fetchMotoristasFromFirebase() async {
  // Obtenha os documentos da coleção 'DTSConferidas' no Firebase
  final querySnapshot = await FirebaseFirestore.instance
      .collection('EscalaCarretas')
      .where('data', isEqualTo: getCurrentDate())
      .where('filial', isEqualTo: await IdentificacaoController.filial())
      .get();

  // Converta os documentos em objetos Motorista
  final nomes = querySnapshot.docs.map((doc) {
    final nome = (doc['nome'] ?? 0).toString();
    final dt = (doc['dt'] ?? 0).toString();

    return CarretaDT(
      nome: nome,
      dt: dt,
    );
  }).toList();
  nomes.sort((a, b) => a.nome.compareTo(b.nome));
  return nomes;
}

class CarretaDTScreen extends StatefulWidget {
  const CarretaDTScreen({Key? key}) : super(key: key);

  @override
  _CarretaDTScreenState createState() => _CarretaDTScreenState();
}

class _CarretaDTScreenState extends State<CarretaDTScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carreta DTS'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/images/new3.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Buscar por DT',
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchText = value;
                      });
                    },
                  ),
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder<List<CarretaDT>?>(
                future: fetchMotoristasFromFirebase().catchError((error) {
                  print('Erro ao carregar motoristas: $error');
                  return null; // Return null to indicate error
                }),
                builder: (BuildContext context,
                    AsyncSnapshot<List<CarretaDT>?> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError || snapshot.data == null) {
                    return const Center(
                        child: Text('Erro ao carregar motoristas'));
                  } else {
                    final motoristas = snapshot.data!;
                    return ListView.builder(
                      itemCount: motoristas.length,
                      itemBuilder: (BuildContext context, int index) {
                        final motorista = motoristas[index];
                        if (_searchText.isNotEmpty &&
                            !motorista.dt
                                .toLowerCase()
                                .contains(_searchText.toLowerCase())) {
                          return const SizedBox.shrink();
                        }

                        return FutureBuilder<bool>(
                          future: _verificarDtNoFirebase(motorista.dt),
                          builder: (context, snapshot) {
                            Color cardColor = Colors.white; // cor padrão

                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              if (snapshot.data == true) {
                                cardColor = Colors
                                    .green; // cor se dt estiver no Firebase
                              }
                            }

                            return GestureDetector(
                              onTap: () {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (context) => EntradaScreen(
                                      motoristaSelecionado: motorista,
                                    ),
                                  ),
                                );
                              },
                              child: Card(
                                color: cardColor,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    ListTile(
                                      title: Text(motorista.nome),
                                      subtitle: Text(
                                          'DT: ${motorista.dt}, Nome: ${motorista.nome}'),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String getCurrentDate() {
  DateTime now = DateTime.now();
  String formattedDate = DateFormat('dd/MM/yyyy').format(now);
  return formattedDate;
}
