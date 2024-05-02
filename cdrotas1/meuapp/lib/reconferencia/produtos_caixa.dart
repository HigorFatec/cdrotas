import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:meuapp/reconferencia/caixas.dart';

class Cxs2 {
  final String caixa;
  final String codigo;

  Cxs2({
    required this.caixa,
    required this.codigo,
  });
}

Future<List<Cxs2>?> fetchDevolucoesFromFirestore() async {
  try {
    // Obtenha a referência para a coleção "caixas" no Firestore
    CollectionReference collectionRef =
        FirebaseFirestore.instance.collection('produtoscx');

    // Obtenha os documentos da coleção em ordem alfabética pelo campo "codigo"
    QuerySnapshot querySnapshot = await collectionRef.orderBy('codigo').get();

    // Verifique se existem documentos na coleção
    if (querySnapshot.docs.isNotEmpty) {
      // Converta os documentos em objetos Cxs
      List<Cxs2> caixas = querySnapshot.docs.map((doc) {
        String codigo = doc.get('codigo');
        String nome = doc.get('nome');

        return Cxs2(
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

class CaixaScreen2 extends StatefulWidget {
  const CaixaScreen2({Key? key}) : super(key: key);

  @override
  _CaixaScreen2State createState() => _CaixaScreen2State();
}

class _CaixaScreen2State extends State<CaixaScreen2> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  List<Cxs2> caixas = [];

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
                          builder: (context) => CaixasScreen2(
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
