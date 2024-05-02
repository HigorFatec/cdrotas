import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meuapp/controller/drawner_controller.dart';
import 'package:meuapp/controller/excel_controller.dart';
import 'package:meuapp/controller/firestore_controller.dart';
import 'package:meuapp/model/lista_modificar.dart';
import '../controller/login_controller.dart';
import '../view/util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SelecionarDTScreen extends StatefulWidget {
  const SelecionarDTScreen({Key? key}) : super(key: key);

  @override
  State<SelecionarDTScreen> createState() => _SelecionarDTScreenState();
}

class _SelecionarDTScreenState extends State<SelecionarDTScreen> {
  final excelControl = ExcelControl();
  final firestoreController = FirestoreController();
  //PROJETO PARA CONFERIR VARIOS CAMINHAO
  final IdentificacaoController = LoginController();

  List<String> motoristas = [];

  String dt = '';
  String km = '';
  String placa = '';
  String data = '';
  String horario = '';
  var excel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Motorista2?;
    if (args != null) {
      setState(() {
        dt = args.dt;
        placa = args.placa;
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
        title: const Text('Dados do Veiculo/DT'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            FutureBuilder<List<String>>(
              future: getMotoristas(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasData) {
                  motoristas = snapshot.data!; // Atualiza a lista de motoristas
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: motoristas.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.delete),
                          title: Text(motoristas[index]),
                          onTap: () {
                            _removerMotorista(index);
                          },
                        ),
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return const Text('Erro ao carregar motoristas');
                } else {
                  return const CircularProgressIndicator();
                }
              },
            ),
            Container(
              height: MediaQuery.of(context)
                  .size
                  .height, // Define a altura do contêiner igual à altura da tela
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('lib/images/new3.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16.0),
                    Card(
                      child: TextFormField(
                        initialValue: dt,
                        onChanged: (text) {
                          setState(() {
                            dt = text;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Número da DT',
                          border: const OutlineInputBorder(),
                          suffixIcon: GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, '/lista_dts');
                            },
                            child: const Icon(Icons.list),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    Card(
                      child: TextFormField(
                        initialValue: placa,
                        onChanged: (text) {
                          placa = text;
                        },
                        decoration: const InputDecoration(
                          labelText: 'Placa',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.directions_car),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    Card(
                      child: TextFormField(
                        onChanged: (text) {
                          km = text;
                        },
                        decoration: const InputDecoration(
                          labelText: 'KM',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.directions_car),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    Card(
                      color: Colors.grey[400],
                      child: TextFormField(
                        initialValue: getCurrentDate(),
                        enabled: false,
                        decoration: const InputDecoration(
                          labelText: 'Data',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    Card(
                      color: Colors.grey[400],
                      child: TextFormField(
                        initialValue: getCurrentTime(),
                        enabled: false,
                        decoration: const InputDecoration(
                          labelText: 'Hora',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.access_time),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    ElevatedButton(
                      onPressed: () {
                        if (_validateFields()) {
                          // SALVAR DADOS NO FIREBASE
                          firestoreController.salvarDadosMotorista2(
                              dt, placa, km);
                          //});
                          Navigator.pushNamed(context, '/principal');
                        }
                      },
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

  Future<List<String>> getMotoristas() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('motoristas2')
        .where('uid', isEqualTo: IdentificacaoController.idUsuario())
        .get();
    final motoristas2 =
        snapshot.docs.map((doc) => doc['placa'] as String).toList();
    return motoristas2;
  }

  bool _validateFields() {
    if (dt.isEmpty ||
//        data.isEmpty ||
        placa.isEmpty) {
//        horario.isEmpty
      erro(context, 'Preencha todos os campos.');
      return false;
    } else {
      sucesso(context, 'Dados salvos com sucesso.');
      Navigator.of(context).pushNamed('/principal');
      return true;
    }
  }

  String getCurrentDate() {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('dd/MM/yyyy').format(now);
    return formattedDate;
  }

  String getCurrentTime() {
    DateTime now = DateTime.now();
    String formattedTime = DateFormat('HH:mm:ss').format(now);
    return formattedTime;
  }

  void _removerMotorista(int index) async {
    if (index >= 0 && index < motoristas.length) {
      String motoristaRemover = motoristas[index];

      // Remover motorista do Firestore
      await FirebaseFirestore.instance
          .collection('motoristas2')
          .where('placa', isEqualTo: motoristaRemover)
          .get()
          .then((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          String docId = snapshot.docs.first.id;
          FirebaseFirestore.instance
              .collection('motoristas2')
              .doc(docId)
              .delete();
        }
      });

      // Remover motorista da lista
      setState(() {
        motoristas.removeAt(index);
      });
    }
  }
}
