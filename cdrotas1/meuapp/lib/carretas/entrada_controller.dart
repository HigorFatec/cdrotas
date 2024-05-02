import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../controller/login_controller.dart';

final IdentificacaoController = LoginController();

class EntradaController {
  Future<void> salvarDadosDescarga(
      String dt, String data_descarga, String horario_descarga) async {
    try {
      LoginController loginController = LoginController();
      Map<String, dynamic> usuario = await loginController.usuarioLogado();
      String nome = usuario['nome'];

      // Obtenha uma referência para a coleção "motoristas"
      CollectionReference carretaCollection =
          FirebaseFirestore.instance.collection('DescargaCarreta');

      // Crie um novo documento na coleção usando o método "add()"
      await carretaCollection.add({
        'operacao': 'descarga',
        'dt': dt,
        'data_descarga': data_descarga,
        'horario_descarga': horario_descarga,
        'mes': getCurrentMonth(),
        'usuario': nome,
        'filial': await IdentificacaoController.filial(),
      });

      await moverDados('DescargaCarreta', 'InfoCarretas', dt);

      print('Dados do motorista salvos com sucesso!');
    } catch (error) {
      print('Erro ao salvar os dados do motorista: $error');
    }
  }

  Future<void> salvarDadosCarreta(
    String tipo,
    String transportadora,
    String dt,
    String placa,
    String placaCarreta,
    String motorista,
    String telefone,
    String data,
    String horario,
    String produto,
    String veiculo,
    String origem,
    String tipoFrete,
    String cpf,
  ) async {
    try {
      LoginController loginController = LoginController();
      Map<String, dynamic> usuario = await loginController.usuarioLogado();
      String nome = usuario['nome'];

      // Obtenha uma referência para a coleção "motoristas"
      CollectionReference carretaCollection =
          FirebaseFirestore.instance.collection('EntradaCarreta');

      // Crie um novo documento na coleção usando o método "add()"
      await carretaCollection.add({
        'operacao': 'entrada',
        'tipo': tipo,
        'transportadora': transportadora,
        'dt': dt,
        'placa_cavalo': placa,
        'placa_carreta': placaCarreta,
        'motorista': motorista,
        'telefone': telefone,
        'data': data,
        'horario': horario,
        'produto': produto,
        'veiculo': veiculo,
        'origem': origem,
        'mes': getCurrentMonth(),
        'tipo_frete': tipoFrete,
        'cpf': cpf,
        'usuario': nome,
        'filial': await IdentificacaoController.filial(),
      });

      CollectionReference dtCollection =
          FirebaseFirestore.instance.collection('CarretasComEntrada');
      await dtCollection.add({
        'dt': dt,
        'data': data,
        'horario': horario,
        'mes': getCurrentMonth(),
        'usuario': nome,
        'filial': await IdentificacaoController.filial(),
      });

      print('Dados do motorista salvos com sucesso!');
    } catch (error) {
      print('Erro ao salvar os dados do motorista: $error');
    }
  }

  Future<void> salvarDadosSaida(
    String dt,
    String data_saida,
    String horario_saida,
    String palets,
    String cheia,
    String palets_quebrado,
    String fita_estourada,
    String teve,
  ) async {
    try {
      LoginController loginController = LoginController();
      Map<String, dynamic> usuario = await loginController.usuarioLogado();
      String nome = usuario['nome'];

      // Obtenha uma referência para a coleção "motoristas"
      CollectionReference carretaCollection =
          FirebaseFirestore.instance.collection('DescargaCarreta');

      // Crie um novo documento na coleção usando o método "add()"
      await carretaCollection.add({
        'operacao': 'saida',
        'dt': dt,
        'palets': palets,
        'cheia': cheia,
        'palets_quebrados': palets_quebrado,
        'fita_estourada': fita_estourada,
        'data_saida': data_saida,
        'horario_saida': horario_saida,
        'mes': getCurrentMonth(),
        'usuario': nome,
        'ocorrencias': teve,
        'filial': await IdentificacaoController.filial(),
      });
      await moverDados('DescargaCarreta', 'InfoCarretas', dt);
      await moverDados('SaidaCarreta', 'Carretas', dt);

      print('Dados do motorista salvos com sucesso!');
    } catch (error) {
      print('Erro ao salvar os dados do motorista: $error');
    }
  }

  Future<void> salvarOcorrencias(
    String dt,
    String ocorrencia,
    String acao,
  ) async {
    try {
      LoginController loginController = LoginController();
      Map<String, dynamic> usuario = await loginController.usuarioLogado();
      String nome = usuario['nome'];

      // Obtenha uma referência para a coleção "motoristas"
      CollectionReference carretaCollection =
          FirebaseFirestore.instance.collection('OcorrenciasCarreta');

      // Crie um novo documento na coleção usando o método "add()"
      await carretaCollection.add({
        'dt': dt,
        'ocorrencia': ocorrencia,
        'acao': acao,
        'data': getCurrentDate(),
        'horario': getCurrentTime(),
        'mes': getCurrentMonth(),
        'usuario': nome,
        'filial': await IdentificacaoController.filial(),
      });

      print('Dados salvos com sucesso!');
    } catch (error) {
      print('Erro ao salvar os dados: $error');
    }
  }
}

Future<void> moverDados(
    String colecaoOrigem, String colecaoDestino, String dt) async {
  try {
    // Obtenha a referência da coleção de origem
    CollectionReference origem =
        FirebaseFirestore.instance.collection(colecaoOrigem);

    // Obtenha os documentos da coleção de origem
    QuerySnapshot querySnapshot = await origem.where('dt', isEqualTo: dt).get();

    // Obtenha a referência da coleção de destino
    CollectionReference destino =
        FirebaseFirestore.instance.collection(colecaoDestino);

    // Lista de operações assíncronas
    List<Future<void>> operacoes = [];

    // Itere sobre os documentos da coleção de origem
    querySnapshot.docs.forEach((QueryDocumentSnapshot document) {
      // Crie um novo documento na coleção de destino com os mesmos dados
      operacoes.add(destino.doc(document.id).set(document.data()));

      // Exclua o documento da coleção de origem
      operacoes.add(origem.doc(document.id).delete());
    });

    // Aguarde a conclusão de todas as operações
    await Future.wait(operacoes);

    print('Dados movidos com sucesso!');
  } catch (e) {
    print('Erro ao mover dados: $e');
  }
}

String getCurrentMonth() {
  DateTime now = DateTime.now();
  String formattedMonth = DateFormat('MM').format(now);
  return formattedMonth;
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
