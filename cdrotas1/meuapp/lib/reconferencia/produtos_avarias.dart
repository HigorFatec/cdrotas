import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meuapp/reconferencia/avarias.dart';

class Avar2 {
  final String avaria;
  final String codigo;

  Avar2({
    required this.avaria,
    required this.codigo,
  });
}

Future<List<Avar2>?> fetchDevolucoesFromExcel() async {
  // Carregue o arquivo Excel como um objeto ByteData
  final ByteData data = await rootBundle.load('lib/assets/sku.xlsx');

  // Converta o ByteData para uma lista de bytes
  final Uint8List bytes = data.buffer.asUint8List();

  // Crie um objeto Excel a partir dos bytes da planilha
  final excel = Excel.decodeBytes(bytes);

  // Obtenha a primeira planilha do arquivo Excel
  final sheet = excel.tables[excel.tables.keys.first];

  // Converta as linhas da planilha em objetos Dev
  final avarias = sheet?.rows.map((row) {
    final codigo = row[0]?.value?.toString() ?? '';
    final nome = row[1]?.value?.toString() ?? '';

    return Avar2(
      avaria: nome,
      codigo: codigo,
    );
  }).toList();

  return avarias;
}

class AvariaScreen2 extends StatefulWidget {
  const AvariaScreen2({Key? key}) : super(key: key);

  @override
  _AvariaScreen2State createState() => _AvariaScreen2State();
}

class _AvariaScreen2State extends State<AvariaScreen2> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  List<Avar2> avarias = [];

  @override
  void initState() {
    super.initState();
    fetchDevolucoesFromExcel().then((avariasList) {
      if (avariasList != null) {
        setState(() {
          avarias = avariasList;
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
                itemCount: avarias.length,
                itemBuilder: (BuildContext context, int index) {
                  final avaria = avarias[index];
                  if (_searchText.isNotEmpty &&
                      !avaria.avaria
                          .toLowerCase()
                          .contains(_searchText.toLowerCase())) {
                    return const SizedBox.shrink();
                  }
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => AvariasScreen2(
                            avariaSelecionada2: avaria,
                          ),
                        ),
                      );
                    },
                    child: Card(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          ListTile(
                            title: Text(avaria.avaria),
                            subtitle: Text('Código: ${avaria.codigo}'),
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
