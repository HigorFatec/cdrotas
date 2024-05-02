import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:meuapp/controller/drawner_controller.dart';
import 'package:meuapp/reconferencia/produtos_caixa.dart';
import 'package:meuapp/view/util.dart';

class CaixasScreen2 extends StatefulWidget {
  final Cxs2? caixaSelecionada;

  const CaixasScreen2({Key? key, this.caixaSelecionada}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _CaixasScreen2State createState() => _CaixasScreen2State();
}

class _CaixasScreen2State extends State<CaixasScreen2> {
  final List<Caixa2> _caixas = [];

  final _nomeController = TextEditingController();
  final _quantidadeController = TextEditingController();
  final _observacoesController = TextEditingController();

  String nome = '';
  String quantidade = '';
  // ignore: prefer_typing_uninitialized_variables
  var excel;

  @override
  @override
  void initState() {
    super.initState();
    _carregarCaixas();
    if (widget.caixaSelecionada != null) {
      _nomeController.text = widget.caixaSelecionada!.caixa;
      nome = widget.caixaSelecionada!.caixa;
    }
  }

  Future<void> _carregarCaixas() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('caixas2').get();

    final caixas = snapshot.docs.map((doc) {
      final data = doc.data();
      return Caixa2(
        nome: data['nome'],
        quantidade: data['quantidade'],
        observacoes: data['observacoes'],

        docId: doc.id, // Atribuir o ID do documento ao objeto Devolucao
      );
    }).toList();

    setState(() {
      _caixas.clear();
      _caixas.addAll(caixas);
    });
  }

  void _adicionarCaixa() async {
    final novaCaixa = Caixa2(
      nome: _nomeController.text,
      quantidade: int.tryParse(_quantidadeController.text) ?? 0,
      observacoes:
          _observacoesController.text, // Adicione o valor vazio inicialmente
      docId: '', // Será preenchido posteriormente com o ID do documento
    );

    final docRef = await FirebaseFirestore.instance
        .collection('caixas2')
        .add(novaCaixa.toMap());
    final docId = docRef.id;

    novaCaixa.docId = docId;

    setState(() {
      _caixas.add(novaCaixa); // Adiciona a devolução à lista
    });

    _nomeController.clear();
    _quantidadeController.clear();
    _observacoesController.clear();
  }

  void _removerCaixa(int index) async {
    if (index >= 0 && index < _caixas.length) {
      final caixa = _caixas[index];
      final docId = caixa.docId;

      final docRef =
          FirebaseFirestore.instance.collection('caixas2').doc(docId);
      print('Documento ID: $docId');
      await docRef.delete();

      setState(() {
        _caixas.removeAt(index);
      });
    }
  }

  void _salvarCaixas() {
    sucesso(context, 'Caixas salvas com Sucesso!');

    // Navegar para a tela inicial
    Navigator.of(context).pushNamed('/home2');
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
                        Navigator.of(context).pushReplacementNamed('/home2');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.person),
                      title: const Text('Dados do Motorista'),
                      subtitle: const Text('Inserir os dados'),
                      onTap: () {
                        Navigator.of(context)
                            .pushReplacementNamed('/dados_motorista5');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.reply),
                      title: const Text('Devoluções'),
                      subtitle: const Text('Devolução de produtos'),
                      onTap: () {
                        Navigator.of(context)
                            .pushReplacementNamed('/devolucoes2');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.add),
                      title: const Text('Sobras'),
                      subtitle: const Text('Sobras de produtos'),
                      onTap: () {
                        Navigator.of(context).pushReplacementNamed('/sobras2');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.remove),
                      title: const Text('Faltas'),
                      subtitle: const Text('Faltas de produtos'),
                      onTap: () {
                        Navigator.of(context).pushReplacementNamed('/faltas2');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.swap_horiz),
                      title: const Text('Trocas'),
                      subtitle: const Text('Trocas de produtos'),
                      onTap: () {
                        Navigator.of(context).pushReplacementNamed('/trocas2');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.warning),
                      title: const Text('Avarias'),
                      subtitle: const Text('Avarias de produtos'),
                      onTap: () {
                        Navigator.of(context).pushReplacementNamed('/avarias2');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.local_shipping),
                      title: const Text('Caixas'),
                      subtitle: const Text('Caixas/Garrafas'),
                      onTap: () {
                        Navigator.of(context).pushReplacementNamed('/caixas2');
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
        title: const Text('Reconferencia Caixas'),
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
                itemCount: _caixas.length,
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                    child: ListTile(
                      leading: GestureDetector(
                        child: const Icon(Icons.delete, size: 40),
                        onTap: () {
                          _removerCaixa(index);
                        },
                      ),
                      title: Text(_caixas[index].nome),
                      subtitle: Text(
                          '${_caixas[index].quantidade} unidades(s), Observações: ${_caixas[index].observacoes}'),
                      trailing: FloatingActionButton(
                        onPressed: () {
                          _nomeController.text = _caixas[index].nome;
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
                              'Nova Caixa',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20.0,
                              ),
                            ),
                            const SizedBox(height: 16.0),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, '/listcaixa2');
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
                                    labelText: 'Nome da caixa',
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
                            const SizedBox(height: 10.0),
                            TextField(
                              onChanged: (text) {
                                quantidade = text;
                              },
                              controller: _observacoesController,
                              decoration: const InputDecoration(
                                labelText: 'Observações',
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
                                  content: Text('Caixas inserida com sucesso!'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                              _adicionarCaixa();
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
                          child: const Text('Adicionar caixa'),
                        ),
                        const SizedBox(height: 5.0),
                        ElevatedButton(
                          onPressed: _salvarCaixas,
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

class Caixa2 {
  final String nome;
  final int quantidade;
  final String observacoes; // Nova propriedade

  String? docId;

  Caixa2({
    required this.nome,
    required this.quantidade,
    required this.observacoes, // Adicione no construtor

    this.docId,
  });

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'quantidade': quantidade,
      'observacoes': observacoes, // Adicione ao mapear para o Firestore
    };
  }
}

void excluirColecao() async {
  QuerySnapshot snapshot =
      await FirebaseFirestore.instance.collection('caixas2').get();
  for (var doc in snapshot.docs) {
    doc.reference.delete();
  }
}
