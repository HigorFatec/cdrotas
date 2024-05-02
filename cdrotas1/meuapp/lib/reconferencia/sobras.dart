import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_excel/excel.dart';
import 'package:meuapp/controller/drawner_controller.dart';
import 'package:meuapp/reconferencia/produtos_sobra.dart';
import 'package:meuapp/view/util.dart';

class SobrasScreen2 extends StatefulWidget {
  final Sob2? sobraSelecionada;

  const SobrasScreen2({Key? key, this.sobraSelecionada}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _SobrasScreenState2 createState() => _SobrasScreenState2();
}

class _SobrasScreenState2 extends State<SobrasScreen2> {
  final List<Sobra2> _sobras = [];

  final _nomeController = TextEditingController();
  final _quantidadeController = TextEditingController();
  final _codigoController = TextEditingController();

  String nome = '';
  String quantidade = '';
  // ignore: prefer_typing_uninitialized_variables
  var excel;

  @override
  @override
  void initState() {
    super.initState();
    _carregarSobras();
    if (widget.sobraSelecionada != null) {
      _codigoController.text = widget.sobraSelecionada!.codigo;
      _nomeController.text = widget.sobraSelecionada!.sobra;
      nome = widget.sobraSelecionada!.sobra;
    }
  }

  Future<void> _carregarSobras() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('sobras2').get();

    final sobras = snapshot.docs.map((doc) {
      final data = doc.data();
      return Sobra2(
        codigo: data['codigo'],
        nome: data['nome'],
        quantidade: data['quantidade'],
        docId: doc.id, // Atribuir o ID do documento ao objeto Devolucao
      );
    }).toList();

    setState(() {
      _sobras.clear();
      _sobras.addAll(sobras);
    });
  }

  void _adicionarSobra() async {
    final novaSobra = Sobra2(
      codigo: _codigoController.text,
      nome: _nomeController.text,
      quantidade: _quantidadeController.text,
      docId: '', // Será preenchido posteriormente com o ID do documento
    );

    final docRef = await FirebaseFirestore.instance
        .collection('sobras2')
        .add(novaSobra.toMap());
    final docId = docRef.id;

    novaSobra.docId = docId;

    setState(() {
      _sobras.add(novaSobra); // Adiciona a devolução à lista
    });

    _nomeController.clear();
    _quantidadeController.clear();
  }

  void _removerSobra(int index) async {
    if (index >= 0 && index < _sobras.length) {
      final sobra = _sobras[index];
      final docId = sobra.docId;

      final docRef =
          FirebaseFirestore.instance.collection('sobras2').doc(docId);
      print('Documento ID: $docId');
      await docRef.delete();

      setState(() {
        _sobras.removeAt(index);
      });
    }
  }

  void _salvarSobras() {
    sucesso(context, 'Sobras salvas com Sucesso!');

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
        title: const Text('Reconferencia Sobras'),
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
                itemCount: _sobras.length,
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                    child: ListTile(
                      leading: GestureDetector(
                        child: const Icon(Icons.delete, size: 40),
                        onTap: () {
                          _removerSobra(index);
                        },
                      ),
                      title: Text(_sobras[index].nome),
                      subtitle:
                          Text('${_sobras[index].quantidade} unidades(s)'),
                      trailing: FloatingActionButton(
                        onPressed: () {
                          _nomeController.text = _sobras[index].nome;
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
                      'Nova Sobra',
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
                        labelText: 'Nome da sobra',
                        border: const OutlineInputBorder(),
                        suffixIcon: GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/listsobra2');
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
                              content: Text('Sobras inserida com sucesso!'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                          _adicionarSobra();
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
                      child: const Text('Adicionar sobra'),
                    ),
                    const SizedBox(height: 10.0),
                    ElevatedButton(
                      onPressed: _salvarSobras,
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

class Sobra2 {
  final String codigo;
  final String nome;
  final String quantidade;
  String? docId;

  Sobra2({
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
      await FirebaseFirestore.instance.collection('sobras2').get();
  for (var doc in snapshot.docs) {
    doc.reference.delete();
  }
}
