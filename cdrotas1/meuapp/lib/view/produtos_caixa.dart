import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:meuapp/view/caixas.dart';

class Cxs {
  final String caixa;
  final String codigo;

  Cxs({
    required this.caixa,
    required this.codigo,
  });
}

Future<List<Cxs>?> fetchDevolucoesFromFirestore() async {
  try {
    // Obtenha a referência para a coleção "caixas" no Firestore
    CollectionReference collectionRef =
        FirebaseFirestore.instance.collection('produtoscx');

    // Obtenha os documentos da coleção em ordem alfabética pelo campo "codigo"
    QuerySnapshot querySnapshot = await collectionRef.orderBy('codigo').get();

    // Verifique se existem documentos na coleção
    if (querySnapshot.docs.isNotEmpty) {
      // Converta os documentos em objetos Cxs
      List<Cxs> caixas = querySnapshot.docs.map((doc) {
        String codigo = doc.get('codigo');
        String nome = doc.get('nome');

        return Cxs(
          codigo: codigo,
          caixa: nome,
        );
      }).toList();

      // Retorne a lista de caixas ordenada por "codigo"
      return caixas;
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

class CaixaScreen extends StatefulWidget {
  const CaixaScreen({Key? key}) : super(key: key);

  @override
  _CaixaScreenState createState() => _CaixaScreenState();
}

class _CaixaScreenState extends State<CaixaScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  List<Cxs> caixas = [];

  @override
  void initState() {
    super.initState();
    fetchDevolucoesFromFirestore().then((caixasList) {
      if (caixasList != null) {
        setState(() {
          caixas = caixasList;
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
                itemCount: caixas.length,
                itemBuilder: (BuildContext context, int index) {
                  final caixa = caixas[index];
                  if (_searchText.isNotEmpty &&
                      !caixa.caixa
                          .toLowerCase()
                          .contains(_searchText.toLowerCase())) {
                    return const SizedBox.shrink();
                  }
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => CaixasScreen(
                            caixaSelecionada: caixa,
                          ),
                        ),
                      );
                    },
                    child: Card(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          ListTile(
                            title: Text(caixa.caixa),
                            subtitle: Text('Código: ${caixa.codigo}'),
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
