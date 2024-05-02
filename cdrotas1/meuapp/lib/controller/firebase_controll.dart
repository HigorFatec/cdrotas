import 'package:cloud_firestore/cloud_firestore.dart';

class firebase_controller {
  _adicionarDevolucao(Devolucao, nomeController, quantidadeController,
      devolucoes, setState) async {
    final novaDevolucao = Devolucao(
      nome: nomeController.text,
      quantidade: quantidadeController.text,
      docId: '', // Será preenchido posteriormente com o ID do documento
    );

    final docRef = await FirebaseFirestore.instance
        .collection('devolucoes')
        .add(novaDevolucao.toMap());
    final docId = docRef.id;

    novaDevolucao.docId = docId;

    setState(() {
      devolucoes.add(novaDevolucao); // Adiciona a devolução à lista
    });

    nomeController.clear();
    quantidadeController.clear();
  }
}
