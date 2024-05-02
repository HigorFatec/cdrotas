import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:meuapp/model/palets.dart';

class Plts {
  final String palet;
  final String codigo;

  Plts({
    required this.palet,
    required this.codigo,
  });
}

Future<List<Plts>?> fetchDevolucoesFromFirestore() async {
  try {
    // Obtenha a referência para a coleção "caixas" no Firestore
    CollectionReference collectionRef =
        FirebaseFirestore.instance.collection('produtospalets');

    // Obtenha os documentos da coleção em ordem alfabética pelo campo "codigo"
    QuerySnapshot querySnapshot = await collectionRef.orderBy('codigo').get();

    // Verifique se existem documentos na coleção
    if (querySnapshot.docs.isNotEmpty) {
      // Converta os documentos em objetos Plts
      List<Plts> palets = querySnapshot.docs.map((doc) {
        String codigo = doc.get('codigo');
        String nome = doc.get('nome');

        return Plts(
          codigo: codigo,
          palet: nome,
        );
      }).toList();

      // Retorne a lista de caixas ordenada por "codigo"
      return palets;
    } else {
      // Caso a coleção esteja vazia, retorne uma lista vazia ou null, dependendo do seu caso
      return null;
    }
  } catch (error) {
    // Lide com qualquer erro que ocorra durante a obtenção dos dados do Firestore
    print('Erro ao obter dados do Firestore: $error');
    return null;
  }
}

class PaletScreen extends StatefulWidget {
  const PaletScreen({Key? key}) : super(key: key);

  @override
  _PaletScreenState createState() => _PaletScreenState();
}

class _PaletScreenState extends State<PaletScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  List<Plts> palets = [];

  @override
  void initState() {
    super.initState();
    fetchDevolucoesFromFirestore().then((paletsList) {
      if (paletsList != null) {
        setState(() {
          palets = paletsList;
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
                itemCount: palets.length,
                itemBuilder: (BuildContext context, int index) {
                  final palet = palets[index];
                  if (_searchText.isNotEmpty &&
                      !palet.palet
                          .toLowerCase()
                          .contains(_searchText.toLowerCase())) {
                    return const SizedBox.shrink();
                  }
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => PaletsScreen(
                            paletSelecionado: palet,
                          ),
                        ),
                      );
                    },
                    child: Card(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          ListTile(
                            title: Text(palet.palet),
                            subtitle: Text('Código: ${palet.codigo}'),
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
