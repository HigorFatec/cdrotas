import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_excel/excel.dart';
import 'package:meuapp/controller/drawner_controller.dart';
import 'package:meuapp/controller/excel_controller.dart';
import 'package:meuapp/reconferencia/produtos_devolucao.dart';
import 'package:meuapp/view/util.dart';

class DevolucoesScreen2 extends StatefulWidget {
  final Dev2? devolucaoSelecionada;

  const DevolucoesScreen2({Key? key, this.devolucaoSelecionada})
      : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _DevolucoesScreenState2 createState() => _DevolucoesScreenState2();
}

class _DevolucoesScreenState2 extends State<DevolucoesScreen2> {
  final List<Devolucao2> _devolucoes = [];
  final excelControl = ExcelControl();

  final _nomeController = TextEditingController();
  final _codigoController = TextEditingController();
  late final _quantidadeController = TextEditingController();

  String nome = '';
  String quantidade = '';
  // ignore: prefer_typing_uninitialized_variables
  var excel;

  @override
  @override
  void initState() {
    super.initState();
    _carregarDevolucoes();
    if (widget.devolucaoSelecionada != null) {
      _nomeController.text = widget.devolucaoSelecionada!.devolucao;
      _codigoController.text = widget.devolucaoSelecionada!.codigo;
      nome = widget.devolucaoSelecionada!.devolucao;
    }
  }

  Future<void> _carregarDevolucoes() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('devolucoes2').get();

    final devolucoes = snapshot.docs.map((doc) {
      final data = doc.data();
      return Devolucao2(
        codigo: data['codigo'],
        nome: data['nome'],
        quantidade: data['quantidade'],
        docId: doc.id, // Atribuir o ID do documento ao objeto Devolucao
      );
    }).toList();

    setState(() {
      _devolucoes.clear();
      _devolucoes.addAll(devolucoes);
    });
  }

  void _adicionarDevolucao() async {
    final novaDevolucao = Devolucao2(
      codigo: _codigoController.text,
      nome: _nomeController.text,
      quantidade: _quantidadeController.text,
      docId: '', // Será preenchido posteriormente com o ID do documento
    );

    final docRef = await FirebaseFirestore.instance
        .collection('devolucoes2')
        .add(novaDevolucao.toMap());
    final docId = docRef.id;

    novaDevolucao.docId = docId;

    setState(() {
      _devolucoes.add(novaDevolucao); // Adiciona a devolução à lista
    });

    _nomeController.clear();
    _quantidadeController.clear();
  }

  void _removerDevolucao(int index) async {
    if (index >= 0 && index < _devolucoes.length) {
      final devolucao = _devolucoes[index];
      final docId = devolucao.docId;

      final docRef =
          FirebaseFirestore.instance.collection('devolucoes2').doc(docId);
      print('Documento ID: $docId');
      await docRef.delete();

      setState(() {
        _devolucoes.removeAt(index);
      });

      //PREENCHENDO OS CAMPOS COM O NOME E QUANTIDADE EXCLUIDOS
      //_nomeController.text = devolucao.nome;
      //_quantidadeController.text = devolucao.quantidade;
    }
  }

  void _salvarDevolucoes() {
    sucesso(context, 'Devoluções salvas com Sucesso!');

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
        title: const Text('Reconferencia Devoluções'),
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
                itemCount: _devolucoes.length,
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                    child: ListTile(
                      leading: GestureDetector(
                        child: const Icon(Icons.delete, size: 40),
                        onTap: () {
                          _removerDevolucao(index);
                        },
                      ),
                      title: Text(_devolucoes[index].nome),
                      subtitle:
                          Text('${_devolucoes[index].quantidade} unidades(s)'),
                      trailing: FloatingActionButton(
                        onPressed: () {
                          _nomeController.text = _devolucoes[index].nome;
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
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Nova Devolução',
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
                        labelText: 'Nome da devolução',
                        border: const OutlineInputBorder(),
                        suffixIcon: GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/listdevolucao2');
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
                    ElevatedButton(
                      onPressed: () {
                        if (_validateFields() == true) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Devolução inserida com sucesso!'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                          _adicionarDevolucao();
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
                      child: const Text('Adicionar devolução'),
                    ),
                    const SizedBox(height: 10.0),
                    ElevatedButton(
                      onPressed: _salvarDevolucoes,
                      child: const Text('Salvar'),
                    ),
                  ],
                ),
              ),
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

class Devolucao2 {
  final String codigo;
  final String nome;
  final String quantidade;
  String? docId;

  Devolucao2({
    required this.codigo,
    required this.nome,
    required this.quantidade,
    this.docId,
  });

  Map<String, dynamic> toMap() {
    return {
      'codigo': codigo,
      'nome': nome,
      'quantidade': quantidade,
    };
  }
}

void excluirColecao() async {
  QuerySnapshot snapshot =
      await FirebaseFirestore.instance.collection('devolucoes2').get();
  for (var doc in snapshot.docs) {
    doc.reference.delete();
  }
}
