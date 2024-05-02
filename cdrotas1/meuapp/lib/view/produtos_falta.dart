import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meuapp/view/falta.dart';

class Falt {
  final String falta;
  final String codigo;

  Falt({
    required this.falta,
    required this.codigo,
  });
}

Future<List<Falt>?> fetchDevolucoesFromExcel() async {
  // Carregue o arquivo Excel como um objeto ByteData
  final ByteData data = await rootBundle.load('lib/assets/sku.xlsx');

  // Converta o ByteData para uma lista de bytes
  final Uint8List bytes = data.buffer.asUint8List();

  // Crie um objeto Excel a partir dos bytes da planilha
  final excel = Excel.decodeBytes(bytes);

  // Obtenha a primeira planilha do arquivo Excel
  final sheet = excel.tables[excel.tables.keys.first];

  // Converta as linhas da planilha em objetos Dev
  final faltas = sheet?.rows.map((row) {
    final codigo = row[0]?.value?.toString() ?? '';
    final nome = row[1]?.value?.toString() ?? '';

    return Falt(
      falta: nome,
      codigo: codigo,
    );
  }).toList();

  return faltas;
}

class FaltaScreen extends StatefulWidget {
  const FaltaScreen({Key? key}) : super(key: key);

  @override
  _FaltaScreenState createState() => _FaltaScreenState();
}

class _FaltaScreenState extends State<FaltaScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  List<Falt> faltas = [];

  @override
  void initState() {
    super.initState();
    fetchDevolucoesFromExcel().then((faltasList) {
      if (faltasList != null) {
        setState(() {
          faltas = faltasList;
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
                itemCount: faltas.length,
                itemBuilder: (BuildContext context, int index) {
                  final falta = faltas[index];
                  if (_searchText.isNotEmpty &&
                      !falta.falta
                          .toLowerCase()
                          .contains(_searchText.toLowerCase())) {
                    return const SizedBox.shrink();
                  }
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => FaltasScreen(
                            faltaSelecionada: falta,
                          ),
                        ),
                      );
                    },
                    child: Card(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          ListTile(
                            title: Text(falta.falta),
                            subtitle: Text('Código: ${falta.codigo}'),
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
