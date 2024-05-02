import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meuapp/view/sobras.dart';

class Sob {
  final String sobra;
  final String codigo;

  Sob({
    required this.sobra,
    required this.codigo,
  });
}

Future<List<Sob>?> fetchDevolucoesFromExcel() async {
  // Carregue o arquivo Excel como um objeto ByteData
  final ByteData data = await rootBundle.load('lib/assets/sku.xlsx');

  // Converta o ByteData para uma lista de bytes
  final Uint8List bytes = data.buffer.asUint8List();

  // Crie um objeto Excel a partir dos bytes da planilha
  final excel = Excel.decodeBytes(bytes);

  // Obtenha a primeira planilha do arquivo Excel
  final sheet = excel.tables[excel.tables.keys.first];

  // Converta as linhas da planilha em objetos Dev
  final sobras = sheet?.rows.map((row) {
    final codigo = row[0]?.value?.toString() ?? '';
    final nome = row[1]?.value?.toString() ?? '';

    return Sob(
      sobra: nome,
      codigo: codigo,
    );
  }).toList();

  return sobras;
}

class SobraScreen extends StatefulWidget {
  const SobraScreen({Key? key}) : super(key: key);

  @override
  _SobraScreenState createState() => _SobraScreenState();
}

class _SobraScreenState extends State<SobraScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  List<Sob> sobras = [];

  @override
  void initState() {
    super.initState();
    fetchDevolucoesFromExcel().then((sobrasList) {
      if (sobrasList != null) {
        setState(() {
          sobras = sobrasList;
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
                itemCount: sobras.length,
                itemBuilder: (BuildContext context, int index) {
                  final sobra = sobras[index];
                  if (_searchText.isNotEmpty &&
                      !sobra.sobra
                          .toLowerCase()
                          .contains(_searchText.toLowerCase())) {
                    return const SizedBox.shrink();
                  }
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => SobrasScreen(
                            sobraSelecionada: sobra,
                          ),
                        ),
                      );
                    },
                    child: Card(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          ListTile(
                            title: Text(sobra.sobra),
                            subtitle: Text('Código: ${sobra.codigo}'),
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
