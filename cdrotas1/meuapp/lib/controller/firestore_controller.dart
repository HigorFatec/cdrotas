import 'package:cloud_firestore/cloud_firestore.dart';

import 'login_controller.dart';

final IdentificacaoController = LoginController();

class FirestoreController {
  Future<void> exibirDadosColecao() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('motoristas')
          .where('uid', isEqualTo: IdentificacaoController.idUsuario())
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Primeiro documento da coleção
        DocumentSnapshot firstDocument = querySnapshot.docs[0];

        // Acessar os campos e armazenar em variáveis
        String dt = firstDocument.get('dt');
        String km = firstDocument.get('km');
        String motorista = firstDocument.get('motorista');
        String placa = firstDocument.get('placa');

        // Fazer algo com as variáveis
        print('Dt: $dt');
        print('Kilometragem: $km');
        print('Motorista: $motorista');
        print('Placa: $placa');
      } else {
        print('A coleção está vazia.');
      }
    } catch (error) {
      print('Erro ao obter os documentos da coleção: $error');
    }
  }

  Future<void> salvarDadosMotorista(
      String dt, String km, String motorista, String placa) async {
    try {
      // Obtenha uma referência para a coleção "motoristas"
      CollectionReference motoristasCollection =
          FirebaseFirestore.instance.collection('motoristas');

      // Crie um novo documento na coleção usando o método "add()"
      await motoristasCollection.add({
        'dt': dt,
        'km': km,
        'motorista': motorista,
        'placa': placa,
        'uid': IdentificacaoController.idUsuario(),
      });

      print('Dados do motorista salvos com sucesso!');
    } catch (error) {
      print('Erro ao salvar os dados do motorista: $error');
    }
  }

  Future<void> salvarDadosMotorista2(String dt, String placa, String km) async {
    try {
      // Obtenha uma referência para a coleção "motoristas"
      CollectionReference motoristasCollection =
          FirebaseFirestore.instance.collection('motoristas2');

      // Crie um novo documento na coleção usando o método "add()"
      await motoristasCollection.add({
        'dt': dt,
        'placa': placa,
        'km': km,
        'uid': IdentificacaoController.idUsuario(),
      });

      print('Dados do motorista salvos com sucesso!');
    } catch (error) {
      print('Erro ao salvar os dados do motorista: $error');
    }
  }
}
