import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_excel/excel.dart';
import 'package:meuapp/controller/drawner_controller.dart';
import 'package:meuapp/reconferencia/produtos_avarias.dart';
import 'package:meuapp/reconferencia/util.dart';

class AvariasScreen2 extends StatefulWidget {
  final Avar2? avariaSelecionada2;

  const AvariasScreen2({Key? key, this.avariaSelecionada2}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _AvariasScreen2State createState() => _AvariasScreen2State();
}

class _AvariasScreen2State extends State<AvariasScreen2> {
  final List<Avaria2> _avarias = [];

  final _codigoController = TextEditingController();
  final _nomeController = TextEditingController();
  final _quantidadeController = TextEditingController();
  final _observacoesController = TextEditingController();

  String codigo = '';
  String nome = '';
  String quantidade = '';
  // ignore: prefer_typing_uninitialized_variables
  var excel;

  @override
  @override
  void initState() {
    super.initState();
    _carregarAvarias();
    if (widget.avariaSelecionada2 != null) {
      _codigoController.text = widget.avariaSelecionada2!.codigo;
      _nomeController.text = widget.avariaSelecionada2!.avaria;
      nome = widget.avariaSelecionada2!.avaria;
    }
  }

  Future<void> _carregarAvarias() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('avarias2').get();

    final avarias = snapshot.docs.map((doc) {
      final data = doc.data();
      return Avaria2(
        codigo: data['codigo'],
        nome: data['nome'],
        quantidade: data['quantidade'],
        observacoes: data['observacoes'],
        docId: doc.id, // Atribuir o ID do documento ao objeto Devolucao
      );
    }).toList();

    setState(() {
      _avarias.clear();
      _avarias.addAll(avarias);
    });
  }

  void _adicionarAvaria() async {
    final novaAvaria = Avaria2(
      codigo: _codigoController.text,
      nome: _nomeController.text,
      quantidade: _quantidadeController.text,
      observacoes:
          _observacoesController.text, // Adicione o valor vazio inicialmente
      docId: '', // Será preenchido posteriormente com o ID do documento
    );

    final docRef = await FirebaseFirestore.instance
        .collection('avarias2')
        .add(novaAvaria.toMap());
    final docId = docRef.id;

    novaAvaria.docId = docId;

    setState(() {
      _avarias.add(novaAvaria); // Adiciona a devolução à lista
    });

    _nomeController.clear();
    _quantidadeController.clear();
    _observacoesController.clear();
  }

  void _removerAvaria(int index) async {
    if (index >= 0 && index < _avarias.length) {
      final avaria = _avarias[index];
      final docId = avaria.docId;

      final docRef =
          FirebaseFirestore.instance.collection('avarias2').doc(docId);
      print('Documento ID: $docId');
      await docRef.delete();

      setState(() {
        _avarias.removeAt(index);
      });
    }
  }

  void _salvarAvarias() {
    sucesso(context, 'Avarias salvas com Sucesso!');

    // Navegar para a tela inicial
    Navigator.of(context).pushNamed('/home2');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    lerPlanilha();
    final args = ModalRoute.of(context)?.settings.arguments as String?;
    if (args != null) {
      setState(() {
        _nomeController.text = args;
      });
    }
  }

  lerPlanilha() async {
    ByteData data = await rootBundle.load("lib/assets/teste.xlsx");
    var bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    excel = Excel.decodeBytes(bytes);
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
        title: const Text('Reconferencia Avarias'),
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
                itemCount: _avarias.length,
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                    child: ListTile(
                      leading: GestureDetector(
                        child: const Icon(Icons.delete, size: 40),
                        onTap: () {
                          _removerAvaria(index);
                        },
                      ),
                      title: Text(_avarias[index].nome),
                      subtitle: Text(
                          '${_avarias[index].quantidade} unidades(s) , Observações: ${_avarias[index].observacoes}'),
                      trailing: FloatingActionButton(
                        onPressed: () {
                          _nomeController.text = _avarias[index].nome;
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
                              'Nova Avaria',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20.0,
                              ),
                            ),
                            const SizedBox(height: 16.0),
                            TextField(
                              onChanged: (text) {
                                nome = text;
                              },
                              controller: _nomeController,
                              decoration: InputDecoration(
                                labelText: 'Nome da avaria',
                                border: const OutlineInputBorder(),
                                suffixIcon: GestureDetector(
                                  onTap: () {
                                    Navigator.pushNamed(
                                        context, '/listavaria2');
                                  },
                                  child: const Icon(Icons.list),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16.0),
                            TextField(
                              onChanged: (text) {
                                quantidade = text;
                              },
                              controller: _quantidadeController,
                              decoration: const InputDecoration(
                                labelText: 'Quantidade',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 16.0),
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
                                      Text('Avarias inserida com sucesso!'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                              _adicionarAvaria();
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
                          child: const Text('Adicionar avaria'),
                        ),
                        const SizedBox(height: 5.0),
                        ElevatedButton(
                          onPressed: _salvarAvarias,
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

class Avaria2 {
  final String codigo;
  final String nome;
  final String quantidade;
  final String observacoes; // Nova propriedade

  String? docId;

  Avaria2({
    required this.codigo,
    required this.nome,
    required this.quantidade,
    required this.observacoes, // Adicione no construtor
    this.docId,
  });

  Map<String, dynamic> toMap() {
    return {
      'codigo': codigo,
      'nome': nome,
      'quantidade': quantidade,
      'observacoes': observacoes, // Adicione ao mapear para o Firestore
    };
  }
}

void excluirColecao() async {
  QuerySnapshot snapshot =
      await FirebaseFirestore.instance.collection('avarias2').get();
  for (var doc in snapshot.docs) {
    doc.reference.delete();
  }
}
