import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meuapp/model/noturno.dart';

import '../controller/login_controller.dart';

class Noturn {
  final String Noturna;
  final String codigo;
  final String dt;
  final String vendpalet;
  final String vendcx;
  final String venduni;
  final String totalcx;
  final String placa;

  Noturn({
    required this.Noturna,
    required this.codigo,
    required this.dt,
    required this.vendpalet,
    required this.vendcx,
    required this.venduni,
    required this.totalcx,
    required this.placa,
  });
}

final IdentificacaoController = LoginController();

Future<List<Noturn>?> fetchDevolucoesFromFirestore() async {
  // Obtenha uma referência para a coleção 'teste_json' no Firestore
  final collection = FirebaseFirestore.instance.collection('SaidasProdutos');

  // Obtenha a lista de strings 'dts' usando a função 'getDts()'
  final dts = await getDts();

  // Converta a lista de strings para uma lista de inteiros
  final dtsInt = dts.map(int.parse).toList();

  // Obtenha os documentos da coleção 'teste_json'
  final snapshot = await collection
      .where('TRANSPORTE', isEqualTo: dtsInt.first)
      .where('FILIAL', isEqualTo: await IdentificacaoController.filial())
      .get();

  // // Converta as linhas da planilha em objetos Dev
  // final Noturnas = sheet?.rows.map((row) {
  //   final dt = row[0]?.value?.toString() ?? '';
  //   final codigo = row[1]?.value?.toString() ?? '';
  //   final nome = row[2]?.value?.toString() ?? '';
  //   final vendpalet = row[3]?.value?.toString() ?? '';
  //   final vendcx = row[4]?.value?.toString() ?? '';
  //   final venduni = row[5]?.value?.toString() ?? '';
  //   final placa = row[8]?.value?.toString() ?? '';

  // Converta os documentos do Firestore em objetos Noturn
  final Noturnas = snapshot.docs.map((doc) {
    final data = doc.data();
    final dt = data['TRANSPORTE']?.toString().replaceAll('.0', '') ?? '';
    final codigo = data['MATERIAL']?.toString().replaceAll('.0', '') ?? '';
    final nome = data['DESCR. DO MATERIAL']?.toString() ?? '';
    final vendpalet = data['VEND.PALET']?.toString().replaceAll('.0', '') ?? '';
    final vendcx = data['VEND.CAIXAS']?.toString().replaceAll('.0', '') ?? '';
    final venduni =
        data['VEND.UNIDADES']?.toString().replaceAll('.0', '') ?? '';
    final totalcx = data['TOTAL.CAIXAS']?.toString().replaceAll('.0', '') ?? '';
    final placa = data['Placa']?.toString() ?? '';

    return Noturn(
      Noturna: nome,
      dt: dt,
      codigo: codigo,
      vendpalet: vendpalet,
      vendcx: vendcx,
      venduni: venduni,
      totalcx: totalcx,
      placa: placa,
    );
  }).toList();

  return Noturnas;
}

class NoturnaScreen extends StatefulWidget {
  const NoturnaScreen({Key? key}) : super(key: key);

  @override
  _NoturnaScreenState createState() => _NoturnaScreenState();
}

class _NoturnaScreenState extends State<NoturnaScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  List<Noturn> Noturnas = [];
  Map<String, bool> codigoExisteMap =
      {}; // Mapa para armazenar resultados da verificação

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final dtList = await getdt();
    setState(() {
      _searchText = dtList.join(
          ', '); // Separe os valores com vírgula ou outro separador, se desejar
    });

    final excelData = await fetchDevolucoesFromFirestore();
    if (excelData != null) {
      setState(() {
        Noturnas = excelData;

        // Pré-carregue as informações do Firebase e armazene em um mapa
        Noturnas.forEach((Noturna) async {
          final exists =
              await _verificarCodigoNoFirebase(Noturna.codigo, Noturna.dt);
          setState(() {
            codigoExisteMap[Noturna.codigo] = exists;
          });
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Produtos'),
        actions: [
          IconButton(
            onPressed: () {
              //});
              Navigator.pushReplacementNamed(context, '/Noturna');
            },
            icon: const Icon(Icons.upload),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/images/back2.jpg'),
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
                    enabled: false,
                    decoration: InputDecoration(
                      hintText: 'CONFERINDO A DT: $_searchText',
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
              child: ListView.builder(
                itemCount: Noturnas.length,
                itemBuilder: (BuildContext context, int index) {
                  final Noturna = Noturnas[index];
                  final bool codigoExiste =
                      codigoExisteMap[Noturna.codigo] ?? false;
                  Color itemColor = codigoExiste ? Colors.green : Colors.white;

                  if (_searchText.isNotEmpty &&
                      !Noturna.dt
                          .toLowerCase()
                          .contains(_searchText.toLowerCase())) {
                    return const SizedBox.shrink();
                  }

                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => NoturnasScreen(
                            Noturnaselecionada: Noturna,
                          ),
                        ),
                      );
                    },
                    child: Card(
                      color:
                          itemColor, // Defina a cor do cartão com base na condição
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          ListTile(
                            title: Text(Noturna.Noturna),
                            subtitle: Text(
                                'Código: ${Noturna.codigo}, PLACA: ${Noturna.placa}'),
                          ), //\nVenda Palet: ${Noturna.vendpalet}, Venda Caixa: ${Noturna.vendcx}, \nVenda Unidade: ${Noturna.venduni}
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<List<String>> getdt() async {
  final snapshot = await FirebaseFirestore.instance
      .collection('motoristas2')
      .where('uid', isEqualTo: IdentificacaoController.idUsuario())
      .get();
  final motoristas2 = snapshot.docs.map((doc) => doc['dt'] as String).toList();
  return motoristas2;
}

Future<bool> _verificarCodigoNoFirebase(String codigo, String dt) async {
  final query = await FirebaseFirestore.instance
      .collection(
          'Noturnas') // Substitua 'DTS' pelo nome da sua coleção no Firebase
      .where('codigo', isEqualTo: codigo)
      .where('dt', isEqualTo: dt)
      .where('uid', isEqualTo: IdentificacaoController.idUsuario())
      .get();

  return query.docs.isNotEmpty;
}

String getCurrentDate() {
  DateTime now = DateTime.now();
  String formattedDate = DateFormat('dd/MM/yyyy').format(now);
  return formattedDate;
}

Future<List<String>> getDts() async {
  final snapshot = await FirebaseFirestore.instance
      .collection('motoristas2')
      .where('uid', isEqualTo: IdentificacaoController.idUsuario())
      .get();
  final dts = snapshot.docs.map((doc) => doc['dt'] as String).toList();
  return dts;
}
