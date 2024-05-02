import 'package:flutter/material.dart';
import 'package:meuapp/controller/login_controller.dart';

class CadastrarPage extends StatefulWidget {
  const CadastrarPage({Key? key}) : super(key: key);

  @override
  State<CadastrarPage> createState() => _CadastrarPageState();
}

class _CadastrarPageState extends State<CadastrarPage> {
  var txtnome = TextEditingController();
  var txtemail = TextEditingController();
  var txtsenha = TextEditingController();
  var txtcargo = TextEditingController();
  var txtmatricula = TextEditingController();

  String email = '';
  String password = '';
  String cargo = '';
  String matricula = '';
  String admin = 'false';
  String filial = 'Ribeirao Preto';

  @override
  void initState() {
    super.initState();
  }

  Widget _body() {
    return ListView(
      children: [
        Container(
          height: 100,
        ),
        Card(
          child: Padding(
            padding:
                const EdgeInsets.only(left: 12, right: 12, top: 20, bottom: 12),
            child: Column(
              children: [
                TextField(
                  controller: txtnome,
                  decoration: const InputDecoration(
                      labelText: 'Nome',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: txtcargo,
                  decoration: const InputDecoration(
                      labelText: 'Cargo',
                      prefixIcon: Icon(Icons.person_2),
                      border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: txtmatricula,
                  decoration: const InputDecoration(
                      labelText: 'Matricula',
                      prefixIcon: Icon(Icons.person_3),
                      border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                Container(
                  color: Colors.white,
                  child: DropdownButtonFormField<String>(
                    value: filial, // Valor selecionado
                    onChanged: (newValue) {
                      setState(() {
                        filial = newValue!;
                      });
                    },
                    items: [
                      'Ribeirao Preto',
                      'Caçapava',
                      'Uberlandia',
                      'Santos',
                    ].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    decoration: const InputDecoration(
                      labelText: 'Filial',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: txtemail,
                  decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: txtsenha,
                  obscureText: true,
                  decoration: const InputDecoration(
                      labelText: 'Senha',
                      prefixIcon: Icon(Icons.password),
                      border: OutlineInputBorder()),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        LoginController().criarConta(
                          context,
                          txtnome.text,
                          txtemail.text,
                          txtsenha.text,
                          txtcargo.text,
                          txtmatricula.text,
                          admin,
                          filial,
                        );
                      },
                      child: const Text('Cadastrar'),
                    ),
                    const SizedBox(width: 140),
                    ElevatedButton(
                      child: const Text('Cancelar'),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastrar'),
      ),
      body: Stack(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Image.asset(
              'lib/images/truck.png',
              fit: BoxFit.cover,
            ),
          ),
          Container(
            color: Colors.black.withOpacity(0.5),
          ),
          _body(),
        ],
      ),
    );
  }
}
