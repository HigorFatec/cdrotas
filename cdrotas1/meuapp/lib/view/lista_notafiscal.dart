import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'devolucoes.dart';

class NotaFiscal {
  final String produto;
  final String codigo;
  final String dt;
  final String nf;

  NotaFiscal({
    required this.produto,
    required this.codigo,
    required this.dt,
    required this.nf,
  });
}

Future<List<NotaFiscal>?> NotaFiscalFromFirestore() async {
  // Obtenha uma referência para a coleção 'teste_json' no Firestore
  final collection = FirebaseFirestore.instance.collection('SaidasProdutos');

  // Obtenha a lista de strings 'dts' usando a função 'getDts()'
  final dts = await getDts();

  // Converta a lista de strings para uma lista de inteiros
  final dtsInt = dts.map(int.parse).toList();

  print(dtsInt.first);

  // Obtenha os documentos da coleção 'teste_json'
  final snapshot = await collection
      .where('DATA', isEqualTo: getCurrentDate())
      .where('TRANSPORTE', isEqualTo: dtsInt.first)
      .get();

  // Converta as linhas da planilha em objetos Dev
  final NotaFiscals = snapshot.docs.map((doc) {
    final data = doc.data();
    final dt = data['TRANSPORTE']?.toString() ?? '';
    final codigo = data['MATERIAL']?.toString() ?? '';
    final nf = data['NF']?.toString() ?? '';
    final nome = data['DESCR. DO MATERIAL']?.toString() ?? '';

    return NotaFiscal(
      produto: nome,
      dt: dt,
      codigo: codigo,
      nf: nf,
    );
  }).toList();

  return NotaFiscals;
}

class NotaFiscalScreen extends StatefulWidget {
  const NotaFiscalScreen({Key? key}) : super(key: key);

  @override
  _NotaFiscalScreenState createState() => _NotaFiscalScreenState();
}

class _NotaFiscalScreenState extends State<NotaFiscalScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  List<NotaFiscal> NotaFiscals = [];
  Map<String, bool> codigoExisteMap =
      {}; // Mapa para armazenar resultados da verificação

  Map<String, bool> dtExisteMap =
      {}; // Mapa para armazenar resultados da verificação

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final excelData = await NotaFiscalFromFirestore();
    if (excelData != null) {
      setState(() {
        NotaFiscals = excelData;
      });

      final dtList = await getdt(); // Obtenha a lista de datas uma vez aqui

      // Pré-carregue as informações do Firebase e armazene em um mapa
      for (final produto in NotaFiscals) {
        final exists = await _verificarCodigoNoFirebase(
          produto.codigo,
          dtList.join(','),
        );
        setState(() {
          codigoExisteMap[produto.codigo] = exists;
        });

        final exists2 = await _verificarDTNoFirebase(produto.dt);
        setState(() {
          dtExisteMap[produto.dt] = exists2;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Produtos'),
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
                    enabled: true,
                    decoration: const InputDecoration(
                      hintText: 'DIGITE O NUMERO DA NOTA FISCAL',
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
                itemCount: NotaFiscals.length,
                itemBuilder: (BuildContext context, int index) {
                  final produto = NotaFiscals[index];

                  final bool dtExiste = dtExisteMap[produto.dt] ?? false;

                  if (_searchText.isNotEmpty &&
                      !produto.nf
                          .toLowerCase()
                          .contains(_searchText.toLowerCase())) {
                    return const SizedBox.shrink();
                  }

                  // Verifique se o dt do produto está presente na coleção do Firebase
                  if (!dtExiste) {
                    return const SizedBox.shrink();
                  }

                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => DevolucoesScreen(
                            notaFiscalSelecionada: produto,
                          ),
                        ),
                      );
                    },
                    child: Card(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          ListTile(
                            title: Text(produto.produto),
                            subtitle: Text(
                                'NotaFiscal: ${produto.nf} \nCodigo Produto: ${produto.codigo}, DT: ${produto.dt}'),
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
  final snapshot =
      await FirebaseFirestore.instance.collection('motoristas').get();
  final dts = snapshot.docs.map((doc) => doc['dt'] as String).toList();
  return dts;
}

Future<bool> _verificarCodigoNoFirebase(String codigo, String dt) async {
  final query = await FirebaseFirestore.instance
      .collection(
          'RadioFrequencia') // Substitua 'DTS' pelo nome da sua coleção no Firebase
      .where('codigo', isEqualTo: codigo)
      .where('dt', isEqualTo: dt)
      .get();

  return query.docs.isNotEmpty;
}

Future<bool> _verificarDTNoFirebase(String dt) async {
  final query = await FirebaseFirestore.instance
      .collection('motoristas')
      .where('dt', isEqualTo: dt)
      .get();

  return query.docs.isNotEmpty;
}

String getCurrentDate() {
  DateTime now = DateTime.now();
  String formattedDate = DateFormat('dd/MM/yyyy').format(now);
  return formattedDate;
}

Future<List<String>> getDts() async {
  final snapshot =
      await FirebaseFirestore.instance.collection('motoristas').get();
  final dts = snapshot.docs.map((doc) => doc['dt'] as String).toList();
  return dts;
}
