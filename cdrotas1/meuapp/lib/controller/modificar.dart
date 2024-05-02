import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AtualizarInformacoesUsuarioScreen extends StatefulWidget {
  const AtualizarInformacoesUsuarioScreen({super.key});

  @override
  _AtualizarInformacoesUsuarioScreenState createState() =>
      _AtualizarInformacoesUsuarioScreenState();
}

class _AtualizarInformacoesUsuarioScreenState
    extends State<AtualizarInformacoesUsuarioScreen> {
  final _nomeController = TextEditingController();
  final _matriculaController = TextEditingController();
  final _cargoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Recuperar os dados do Firestore e preencher os campos de texto
    _recuperarDadosUsuario();
  }

  void _recuperarDadosUsuario() {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    FirebaseFirestore.instance
        .collection('usuarios')
        .where('uid', isEqualTo: uid)
        .get()
        .then((resultado) {
      if (resultado.docs.isNotEmpty) {
        final usuario = resultado.docs[0].data();
        _nomeController.text = usuario['nome'] ?? '';
        _matriculaController.text = usuario['matricula'] ?? '';
        _cargoController.text = usuario['cargo'] ?? '';
      }
    }).catchError((e) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Erro'),
          content:
              Text('Erro ao buscar informações do usuário: ${e.toString()}'),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            ),
          ],
        ),
      );
    });
  }

  void _atualizarInformacoesUsuario() {
    String nome = _nomeController.text.trim();
    String matricula = _matriculaController.text.trim();
    String cargo = _cargoController.text.trim();

    if (nome.isEmpty || matricula.isEmpty || cargo.isEmpty) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Erro'),
          content: const Text('Por favor, preencha todos os campos.'),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            ),
          ],
        ),
      );
      return;
    }

    String uid = FirebaseAuth.instance.currentUser!.uid;

    FirebaseFirestore.instance
        .collection('usuarios')
        .where('uid', isEqualTo: uid)
        .get()
        .then((resultado) {
      final docId = resultado.docs[0].id;

      FirebaseFirestore.instance.collection('usuarios').doc(docId).update({
        'nome': nome,
        'matricula': matricula,
        'cargo': cargo,
      }).then((_) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Sucesso'),
            content: const Text('Informações atualizadas com sucesso.'),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      }).catchError((e) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Erro'),
            content: Text('Erro ao atualizar informações: ${e.toString()}'),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
              ),
            ],
          ),
        );
      });
    }).catchError((e) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Erro'),
          content:
              Text('Erro ao buscar informações do usuário: ${e.toString()}'),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            ),
          ],
        ),
      );
    });
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _matriculaController.dispose();
    _cargoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Atualizar Informações do Usuário'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("lib/images/back.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Card(
            margin: const EdgeInsets.all(16.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _nomeController,
                    decoration: const InputDecoration(
                      labelText: 'Nome',
                    ),
                  ),
                  TextField(
                    controller: _matriculaController,
                    decoration: const InputDecoration(
                      labelText: 'Matrícula',
                    ),
                  ),
                  TextField(
                    controller: _cargoController,
                    decoration: const InputDecoration(
                      labelText: 'Cargo',
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: _atualizarInformacoesUsuario,
                    child: const Text('Atualizar Informações'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
