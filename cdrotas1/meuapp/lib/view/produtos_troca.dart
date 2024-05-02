import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meuapp/view/troca.dart';

class Troc {
  final String troca;
  final String codigo;

  Troc({
    required this.troca,
    required this.codigo,
  });
}

Future<List<Troc>?> fetchDevolucoesFromExcel() async {
  // Carregue o arquivo Excel como um objeto ByteData
  final ByteData data = await rootBundle.load('lib/assets/sku.xlsx');

  // Converta o ByteData para uma lista de bytes
  final Uint8List bytes = data.buffer.asUint8List();

  // Crie um objeto Excel a partir dos bytes da planilha
  final excel = Excel.decodeBytes(bytes);

  // Obtenha a primeira planilha do arquivo Excel
  final sheet = excel.tables[excel.tables.keys.first];

  // Converta as linhas da planilha em objetos Dev
  final trocas = sheet?.rows.map((row) {
    final codigo = row[0]?.value?.toString() ?? '';
    final nome = row[1]?.value?.toString() ?? '';

    return Troc(
      troca: nome,
      codigo: codigo,
    );
  }).toList();

  return trocas;
}

class TrocaScreen extends StatefulWidget {
  const TrocaScreen({Key? key}) : super(key: key);

  @override
  _TrocaScreenState createState() => _TrocaScreenState();
}

class _TrocaScreenState extends State<TrocaScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  List<Troc> trocas = [];

  @override
  void initState() {
    super.initState();
    fetchDevolucoesFromExcel().then((trocasList) {
      if (trocasList != null) {
        setState(() {
          trocas = trocasList;
        });
      }
    }).catchError((error) {
      print('Erro ao carregar sobras: $error');
    });
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
                    decoration: const InputDecoration(
                      hintText: 'Buscar por nome do Produto',
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
                itemCount: trocas.length,
                itemBuilder: (BuildContext context, int index) {
                  final troca = trocas[index];
                  if (_searchText.isNotEmpty &&
                      !troca.troca
                          .toLowerCase()
                          .contains(_searchText.toLowerCase())) {
                    return const SizedBox.shrink();
                  }
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => TrocasScreen(
                            trocaSelecionada: troca,
                          ),
                        ),
                      );
                    },
                    child: Card(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          ListTile(
                            title: Text(troca.troca),
                            subtitle: Text('Código: ${troca.codigo}'),
                          ),
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
