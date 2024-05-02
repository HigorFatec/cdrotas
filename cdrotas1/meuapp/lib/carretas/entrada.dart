import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:meuapp/controller/drawner_controller.dart';

import '../view/util.dart';

import 'carreta_dt.dart';
import 'entrada_controller.dart';

class EntradaScreen extends StatefulWidget {
  final CarretaDT? motoristaSelecionado;

  const EntradaScreen({Key? key, this.motoristaSelecionado}) : super(key: key);

  @override
  State<EntradaScreen> createState() => EntradaScreenState();
}

class EntradaScreenState extends State<EntradaScreen> {
  final firestoreController = EntradaController();

  final _nomeController = TextEditingController();
  final _dtController = TextEditingController();

  List<String> motoristas = [];

  String placaCarreta = '';
  String transportadora = 'Cargo Polo Comércio, Logística e';
  String tipo = 'DEDICADA';
  String dt = '';
  String telefone = '';
  String motorista = '';
  String placa = '';
  String data = '';
  String horario = '';
  String veiculo = 'ASA DELTA';
  String produto = 'DESCARTAVEL';
  String origem = 'Itu/SP';
  String tipoFrete = 'T1';
  String cpf = '';

  @override
  void initState() {
    super.initState();
    data = getCurrentDate();
    horario = getCurrentTime();
    if (widget.motoristaSelecionado != null) {
      _dtController.text = widget.motoristaSelecionado!.dt;
      _nomeController.text = widget.motoristaSelecionado!.nome;
      transportadora = _nomeController.text;
      dt = _dtController.text;
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
                        Navigator.of(context).pushReplacementNamed('/carretas');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.add),
                      title: const Text('Nova Entrada'),
                      subtitle: const Text('Registrar nova entrada'),
                      onTap: () {
                        Navigator.of(context).pushReplacementNamed('/entrada');
                      },
                    ),
                    //DESCARGA DE CARRETAS
                    ListTile(
                      leading: const Icon(Icons.arrow_downward),
                      title: const Text('Descarga'),
                      subtitle: const Text('Registrar descarga de carreta'),
                      onTap: () {
                        Navigator.of(context)
                            .pushReplacementNamed('/descargaCarreta');
                      },
                    ),
                    //SAIDA DE CARRETAS
                    ListTile(
                      leading: const Icon(Icons.arrow_upward),
                      title: const Text('Saida'),
                      subtitle: const Text('Registrar saída de carreta'),
                      onTap: () {
                        Navigator.of(context)
                            .pushReplacementNamed('/saidaCarreta');
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
        title: const Text('Entrada de Carreta'),
        actions: [
          IconButton(
            onPressed: () {
              if (_validateFields()) {
                // SALVAR DADOS NO FIREBASE
                firestoreController.salvarDadosCarreta(
                  tipo,
                  _nomeController.text,
                  dt,
                  placa,
                  placaCarreta,
                  motorista,
                  telefone,
                  data,
                  horario,
                  produto,
                  veiculo,
                  origem,
                  tipoFrete,
                  cpf,
                );
                //});
                Navigator.pushReplacementNamed(context, '/carretas');
              }
            },
            icon: const Icon(Icons.upload),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
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
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 16.0),
                      Card(
                        child: TextFormField(
                          onChanged: (text) {
                            setState(() {
                              dt = text;
                            });
                          },
                          controller: _dtController,
                          decoration: InputDecoration(
                            labelText: 'Número da DT',
                            border: const OutlineInputBorder(),
                            suffixIcon: GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, '/listCarretas');
                              },
                              child: const Icon(
                                Icons.list,
                                color: Colors.black,
                                size: 30.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      Container(
                        color: Colors.white,
                        child: DropdownButtonFormField<String>(
                          value: transportadora, // Valor selecionado
                          onChanged: (newValue) {
                            setState(() {
                              transportadora = newValue!;
                            });
                          },
                          items: [
                            'Cargo Polo Comércio, Logística e',
                            'Asus Transportes Ltda.',
                            'Transportadora Almeida de Marília L',
                            'Usina de Laticínios Jussara S.A.',
                            'Ritmo Logística S.A.',
                            'Jsl S.A.',
                            'Cooperativa de Transporte Rodoviári',
                            'Ghelere Transportes Ltda.',
                            'Aga Armazéns Gerais e Logística Ltd',
                            'Tecom Materiais de Construção e',
                            'Transportadora Gobor Ltda.',
                            'Carsten Serviços e Transportes Ltda',
                            'Transportadora Gobor Ltda.',
                            'Transporte Rodoviário 1500 Ltda.',
                            'Jbs S.A.',
                            'Itaobi Transportes Ltda.',
                            'Transporte Rodoviario 1500 Ltda.',
                            'Ritmo Logistica S.A.',
                            'Transporte Rodoviário 1500 Ltda.',
                          ].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          decoration: const InputDecoration(
                            labelText: 'Transportadora',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Card(
                        child: TextFormField(
                          onChanged: (text) {
                            placaCarreta = text;
                          },
                          inputFormatters: [
                            UpperCaseTextFormatter(),
                            LengthLimitingTextInputFormatter(7),
                          ],
                          decoration: const InputDecoration(
                            labelText: 'Placa Carreta',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.directions_car),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      Card(
                        child: TextFormField(
                          onChanged: (text) {
                            motorista = text;
                          },
                          inputFormatters: [UpperCaseTextFormatter()],
                          decoration: const InputDecoration(
                            labelText: 'Motorista',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.person),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      Card(
                        child: TextFormField(
                          onChanged: (text) {
                            cpf = text;
                          },
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(11),
                          ],
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'CPF do motorista',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.phone),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      Card(
                        child: TextFormField(
                          onChanged: (text) {
                            telefone = text;
                          },
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(11),
                          ],
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'Telefone do motorista',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.phone),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      Container(
                        color: Colors.white,
                        child: DropdownButtonFormField<String>(
                          value: origem, // Valor selecionado
                          onChanged: (newValue) {
                            setState(() {
                              origem = newValue!;
                            });
                          },
                          items: [
                            'Recolha de Vasilhame',
                            'Alagoinhas/BA',
                            'Alexânia/GO',
                            'Araraquara/SP',
                            'Arujá/SP',
                            'Gravataí/RS',
                            'Igrejinha/RS',
                            'Jacareí/SP',
                            'Pacatuba/CE',
                            'Ponta Grossa/PR',
                            'Recife/PE',
                            'São Carlos/SP',
                            'São José Dos Campos/SP',
                            'Itaitinga/CE',
                            'Itapissuma/PE',
                            'Itu/SP',
                          ].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          decoration: const InputDecoration(
                            labelText: 'Origem da Carreta',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Container(
                        color: Colors.white,
                        child: DropdownButtonFormField<String>(
                          value: tipo, // Valor selecionado
                          onChanged: (newValue) {
                            setState(() {
                              tipo = newValue!;
                            });
                          },
                          items: ['DEDICADA', 'SPOT'].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          decoration: const InputDecoration(
                            labelText: 'A Carreta é TRT?',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Container(
                        color: Colors.white,
                        child: DropdownButtonFormField<String>(
                          value: produto, // Valor selecionado
                          onChanged: (newValue) {
                            setState(() {
                              produto = newValue!;
                            });
                          },
                          items:
                              ['RETORNAVEL', 'DESCARTAVEL'].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          decoration: const InputDecoration(
                            labelText: 'Tipo de Produto',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Container(
                        color: Colors.white,
                        child: DropdownButtonFormField<String>(
                          value: tipoFrete, // Valor selecionado
                          onChanged: (newValue) {
                            setState(() {
                              tipoFrete = newValue!;
                            });
                          },
                          items: ['T1', 'T2'].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          decoration: const InputDecoration(
                            labelText: 'Tipo de Frete',
                            border: OutlineInputBorder(),
                            hintText: 'T2 = Voltar carregado', // Texto de dica
                          ),
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Container(
                        color: Colors.white,
                        child: DropdownButtonFormField<String>(
                          value: veiculo, // Valor selecionado
                          onChanged: (newValue) {
                            setState(() {
                              veiculo = newValue!;
                            });
                          },
                          items: [
                            'OCO',
                            'ASA DELTA',
                            'BITREM',
                            'RODOTREM',
                            'GRANILEIRO (GRADE ALTA)',
                            'GRANILEIRO (GRADE BAIXA)'
                          ].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          decoration: const InputDecoration(
                            labelText: 'Perfil do Veiculo',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Card(
                        color: Colors.grey[400],
                        child: TextFormField(
                          initialValue: getCurrentDate(),
                          onChanged: (text) {
                            data = text;
                          },
                          enabled: true,
                          decoration: const InputDecoration(
                            labelText: 'Data Chegada',
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
                          onChanged: (text) {
                            horario = text;
                          },
                          enabled: true,
                          decoration: const InputDecoration(
                            labelText: 'Hora Chegada',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.access_time),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _validateFields() {
    if (_dtController.text.isEmpty ||
        transportadora.isEmpty ||
        placaCarreta.isEmpty ||
        motorista.isEmpty ||
        cpf.isEmpty ||
        telefone.isEmpty ||
        veiculo.isEmpty ||
        produto.isEmpty ||
        origem.isEmpty ||
        tipoFrete.isEmpty) {
      erro(context, 'Preencha todos os campos.');
      return false;
    } else {
      sucesso(context, 'Dados salvos com sucesso.');
      Navigator.of(context).pushNamed('/carretas');
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
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
