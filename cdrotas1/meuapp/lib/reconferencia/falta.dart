import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_excel/excel.dart';
import 'package:meuapp/controller/drawner_controller.dart';
import 'package:meuapp/reconferencia/produtos_falta.dart';
import 'package:meuapp/view/util.dart';

class FaltasScreen2 extends StatefulWidget {
  final Falt2? faltaSelecionada;

  const FaltasScreen2({Key? key, this.faltaSelecionada}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _FaltasScreenState2 createState() => _FaltasScreenState2();
}

class _FaltasScreenState2 extends State<FaltasScreen2> {
  final List<Falta2> _faltas = [];

  final _nomeController = TextEditingController();
  final _quantidadeController = TextEditingController();

  String nome = '';
  String quantidade = '';
  // ignore: prefer_typing_uninitialized_variables
  var excel;

  @override
  @override
  void initState() {
    super.initState();
    _carregarFaltas();
    if (widget.faltaSelecionada != null) {
      _nomeController.text = widget.faltaSelecionada!.falta;
      nome = widget.faltaSelecionada!.falta;
    }
  }

  Future<void> _carregarFaltas() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('faltas2').get();

    final faltas = snapshot.docs.map((doc) {
      final data = doc.data();
      return Falta2(
        nome: data['nome'],
        quantidade: data['quantidade'],
        docId: doc.id, // Atribuir o ID do documento ao objeto Devolucao
      );
    }).toList();

    setState(() {
      _faltas.clear();
      _faltas.addAll(faltas);
    });
  }

  void _adicionarFalta() async {
    final novaFalta = Falta2(
      nome: _nomeController.text,
      quantidade: _quantidadeController.text,
      docId: '', // Será preenchido posteriormente com o ID do documento
    );

    final docRef = await FirebaseFirestore.instance
        .collection('faltas2')
        .add(novaFalta.toMap());
    final docId = docRef.id;

    novaFalta.docId = docId;

    setState(() {
      _faltas.add(novaFalta); // Adiciona a devolução à lista
    });

    _nomeController.clear();
    _quantidadeController.clear();
  }

  void _removerFalta(int index) async {
    if (index >= 0 && index < _faltas.length) {
      final falta = _faltas[index];
      final docId = falta.docId;

      final docRef =
          FirebaseFirestore.instance.collection('faltas2').doc(docId);
      print('Documento ID: $docId');
      await docRef.delete();

      setState(() {
        _faltas.removeAt(index);
      });
    }
  }

  void _salvarFaltas() {
    sucesso(context, 'Faltas salvas com Sucesso!');

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
        title: const Text('Reconferencia Faltas'),
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
                itemCount: _faltas.length,
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                    child: ListTile(
                      leading: GestureDetector(
                        child: const Icon(Icons.delete, size: 40),
                        onTap: () {
                          _removerFalta(index);
                        },
                      ),
                      title: Text(_faltas[index].nome),
                      subtitle:
                          Text('${_faltas[index].quantidade} unidades(s)'),
                      trailing: FloatingActionButton(
                        onPressed: () {
                          _nomeController.text = _faltas[index].nome;
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
                      'Nova Falta',
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
                        labelText: 'Nome da falta',
                        border: const OutlineInputBorder(),
                        suffixIcon: GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/listfalta2');
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
                              content: Text('Faltas inserida com sucesso!'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                          _adicionarFalta();
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
                      child: const Text('Adicionar falta'),
                    ),
                    const SizedBox(height: 10.0),
                    ElevatedButton(
                      onPressed: _salvarFaltas,
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

class Falta2 {
  final String nome;
  final String quantidade;
  String? docId;

  Falta2({
    required this.nome,
    required this.quantidade,
    this.docId,
  });

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'quantidade': quantidade,
    };
  }
}

void excluirColecao() async {
  QuerySnapshot snapshot =
      await FirebaseFirestore.instance.collection('faltas2').get();
  for (var doc in snapshot.docs) {
    doc.reference.delete();
  }
}
