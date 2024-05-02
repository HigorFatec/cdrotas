import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:meuapp/controller/drawner_controller.dart';
import 'package:meuapp/model/produtos_palets.dart';
import 'package:meuapp/view/util.dart';

import '../controller/login_controller.dart';

class PaletsScreen extends StatefulWidget {
  final Plts? paletSelecionado;

  const PaletsScreen({Key? key, this.paletSelecionado}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _PaletsScreenState createState() => _PaletsScreenState();
}

class _PaletsScreenState extends State<PaletsScreen> {
  final List<Palets> _palets = [];

  final _nomeController = TextEditingController();
  final _quantidadeController = TextEditingController();

  String nome = '';
  String quantidade = '';
  String filial = 'RPU';

  //PROJETO PARA CONFERIR VARIOS CAMINHAO
  final IdentificacaoController = LoginController();

  @override
  @override
  void initState() {
    super.initState();
    _carregarPalets();
    if (widget.paletSelecionado != null) {
      _nomeController.text = widget.paletSelecionado!.palet;
      nome = widget.paletSelecionado!.palet;
    }
  }

  Future<void> _carregarPalets() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('palets')
        .where('uid', isEqualTo: IdentificacaoController.idUsuario())
        .get();

    final palets = snapshot.docs.map((doc) {
      final data = doc.data();
      return Palets(
        dt: data['dt'],
        filial: data['filial'],
        nome: data['nome'],
        quantidade: data['quantidade'],
        uid: data['uid'],
        docId: doc.id, // Atribuir o ID do documento ao objeto Devolucao
      );
    }).toList();

    setState(() {
      _palets.clear();
      _palets.addAll(palets);
    });
  }

  void _adicionarPalet() async {
    List<String> dts = await getDts();

    final novaPalet = Palets(
      dt: dts.first,
      filial: filial,
      nome: _nomeController.text,
      quantidade: int.tryParse(_quantidadeController.text) ?? 0,
      uid: IdentificacaoController.idUsuario(),
      docId: '', // Será preenchido posteriormente com o ID do documento
    );

    final docRef = await FirebaseFirestore.instance
        .collection('palets')
        .add(novaPalet.toMap());
    final docId = docRef.id;

    novaPalet.docId = docId;

    setState(() {
      _palets.add(novaPalet); // Adiciona a devolução à lista
    });

    _nomeController.clear();
    _quantidadeController.clear();
  }

  void _removerPalet(int index) async {
    if (index >= 0 && index < _palets.length) {
      final palet = _palets[index];
      final docId = palet.docId;

      final docRef = FirebaseFirestore.instance.collection('palets').doc(docId);
      print('Documento ID: $docId');
      await docRef.delete();

      setState(() {
        _palets.removeAt(index);
      });
    }
  }

  void _salvarPalets() {
    sucesso(context, 'Palets salvos com Sucesso!');

    // Navegar para a tela inicial
    Navigator.of(context).pushNamed('/principal');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as String?;
    if (args != null) {
      setState(() {
        _nomeController.text = args;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Column(
          children: [
            CustomDrawerHeader.getHeader(context),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.home),
                      title: const Text('Inicio'),
                      subtitle: const Text('Tela Inicial'),
                      onTap: () {
                        Navigator.of(context)
                            .pushReplacementNamed('/principal');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.person),
                      title: const Text('Selecionar DT'),
                      subtitle: const Text('Escolher a DT a conferir'),
                      onTap: () {
                        Navigator.of(context).pushReplacementNamed('/dados_dt');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.local_shipping),
                      title: const Text('Confêrencia'),
                      subtitle: const Text('Conferir os produtos da DT'),
                      onTap: () {
                        Navigator.of(context).pushReplacementNamed('/Noturna');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.control_point_rounded),
                      title: const Text('Palets'),
                      subtitle: const Text('Saida de palets'),
                      onTap: () {
                        Navigator.of(context).pushReplacementNamed('/palets');
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text('Palets'),
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
            Expanded(
              child: ListView.builder(
                itemCount: _palets.length,
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                    child: ListTile(
                      leading: GestureDetector(
                        child: const Icon(Icons.delete, size: 40),
                        onTap: () {
                          _removerPalet(index);
                        },
                      ),
                      title: Text(_palets[index].nome),
                      subtitle:
                          Text('${_palets[index].quantidade} unidades(s)'),
                      trailing: FloatingActionButton(
                        onPressed: () {
                          _nomeController.text = _palets[index].nome;
                          // Ação adicional ao pressionar o botão "+" dentro do Card
                        },
                        mini: true,
                        child: const Icon(Icons.add),
                      ),
                    ),
                  );
                },
              ),
            ),
            const Divider(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 200,
                  child: SingleChildScrollView(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Adicionar Palets',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20.0,
                              ),
                            ),
                            const SizedBox(height: 16.0),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, '/listpalet');
                              },
                              child: AbsorbPointer(
                                absorbing: true,
                                child: TextField(
                                  onChanged: (text) {
                                    nome = text;
                                  },
                                  controller: _nomeController,
                                  enabled: false,
                                  decoration: const InputDecoration(
                                    labelText: 'Tipo de palet',
                                    border: OutlineInputBorder(),
                                    suffixIcon: Icon(Icons.list),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10.0),
                            TextField(
                              onChanged: (text) {
                                quantidade = text;
                              },
                              controller: _quantidadeController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Quantidade',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                //const SizedBox(height: 10.0),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            if (_validateFields() == true) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Palets inseridos com sucesso!'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                              _adicionarPalet();
                            } else {
                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('Campos incompletos'),
                                  content: const Text(
                                      'Por favor, preencha todos os campos.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
                          child: const Text('Adicionar Item'),
                        ),
                        const SizedBox(height: 5.0),
                        ElevatedButton(
                          onPressed: _salvarPalets,
                          child: const Text('Salvar'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool _validateFields() {
    if (nome.isEmpty || quantidade.isEmpty) {
      return false;
    } else {
      return true;
    }
  }
}

class Palets {
  final String dt;
  final String filial;
  final String nome;
  final int quantidade;
  final String uid;
  String? docId;

  Palets({
    required this.dt,
    required this.filial,
    required this.nome,
    required this.quantidade,
    required this.uid,
    this.docId,
  });

  Map<String, dynamic> toMap() {
    return {
      'dt': dt,
      'filial': filial,
      'nome': nome,
      'quantidade': quantidade,
      'uid': uid,
    };
  }
}

Future<List<String>> getDts() async {
  final snapshot =
      await FirebaseFirestore.instance.collection('motoristas2').get();
  final dts = snapshot.docs.map((doc) => doc['dt'] as String).toList();
  return dts;
}
