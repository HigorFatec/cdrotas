import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:meuapp/controller/login_controller.dart';

final IdentificacaoController = LoginController();

class ConferenciaControl {
  var excel;
  var filial;

  //PROJETO PARA CONFERIR VARIOS CAMINHAO

  ConferenciaControl() {
    lerPlanilha();
  }

  lerPlanilha() async {
    ByteData data =
        await rootBundle.load("lib/assets/BaseConferenciaNoturna.xlsx");
    var bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    excel = Excel.decodeBytes(bytes);
  }

  Future<void> exportarExcel() async {
    try {
      // OBTENDO VALOR DE DT
      QuerySnapshot ValorDTSnapshot = await FirebaseFirestore.instance
          .collection('motoristas2')
          .where('uid', isEqualTo: IdentificacaoController.idUsuario())
          .get();
      if (ValorDTSnapshot.docs.isNotEmpty) {
        DocumentSnapshot motoristaDocument2 = ValorDTSnapshot.docs[0];
        String dt = motoristaDocument2.get('dt');
        //FIM

        // Obtém todos os documentos da coleção "Noturnas"
        QuerySnapshot noturnasQuery = await FirebaseFirestore.instance
            .collection('Noturnas')
            .where('uid', isEqualTo: IdentificacaoController.idUsuario())
            .get();

        // Itera sobre cada documento na coleção "Noturnas" e os clona na subcoleção "Produtos"
        for (QueryDocumentSnapshot noturnaDoc in noturnasQuery.docs) {
          // Obtém os dados do documento da coleção "Noturnas"
          Map<String, dynamic> dadosNoturna =
              noturnaDoc.data() as Map<String, dynamic>;

          // Cria um novo documento na subcoleção "Produtos" com os mesmos dados
          await FirebaseFirestore.instance
              .collection('SaidasConferidas') // Coleção "DTS"
              .add(dadosNoturna);

          // Você também pode adicionar campos adicionais ou modificar os dados antes de adicionar na subcoleção

          // //ADICIONANDO OS PRODUTOS NA COLEÇÃO ONDE SÃO RETORNAVEIS
          // // Exibir dados da coleção "Noturnas"
          // QuerySnapshot noturnasSnapshot =
          //     await FirebaseFirestore.instance.collection('Noturnas').get();
          // if (noturnasSnapshot.docs.isNotEmpty) {
          //   for (DocumentSnapshot devolucaoDocument in noturnasSnapshot.docs) {
          //     String codigo = devolucaoDocument.get('codigo');
          //     String nome = devolucaoDocument.get('nome');
          //     String quantidade = devolucaoDocument.get('quantidade');
          //     String observacoes = devolucaoDocument.get('observacoes');

          //     // OBTENDO OS DADOS PARA INSERIR NA COLEÇÃO ATIVOS "ConfNoturna"
          //     if (codigo == '904502' ||
          //         codigo == '904213' ||
          //         codigo == '903061' ||
          //         codigo == '903171' ||
          //         codigo == '900090' ||
          //         codigo == '901133' ||
          //         codigo == '903482' ||
          //         codigo == '902411' ||
          //         codigo == '902432' ||
          //         codigo == '904507' ||
          //         codigo == '903949' ||
          //         codigo == '903486' ||
          //         codigo == '903489' ||
          //         codigo == '904711' ||
          //         codigo == '903950' ||
          //         codigo == '904611') {
          //       QuerySnapshot motoristasSnapshot2 = await FirebaseFirestore
          //           .instance
          //           .collection('motoristas2')
          //           .get();
          //       if (motoristasSnapshot2.docs.isNotEmpty) {
          //         DocumentSnapshot motoristaDocument =
          //             motoristasSnapshot2.docs[0];
          //         String dt = motoristaDocument.get('dt');

          //         await FirebaseFirestore.instance
          //             .collection('ConfNoturna')
          //             .add({
          //           'data': getCurrentDate(),
          //           'codigo': codigo,
          //           'dt': dt,
          //           'nome': nome,
          //           'quantidade': quantidade,
          //           'observacoes': observacoes,
          //         });
          //       }
          //     }
          //     //FIM DA FUNÇÃO PARA INSERIR OS DADOS NA COLEÇÃO "ConfNoturna"

          // AQUI É AONDE SERÁ A COLEÇÃO QUE SERÁ VERIFICADA SE JA FOI CONFERIDA!!!
          await FirebaseFirestore.instance.collection('Conferencia').add({
            'dt': dt,
          });
          //     //FIM DA ONDE SERÁ ADICIONADA AS DTS DE CONFERENCIA
          //   }
          // }
        }
      }

      //FIM DA CONVERSÃO

      // Exibir dados da coleção "dt" "placa"
      QuerySnapshot motoristasSnapshot = await FirebaseFirestore.instance
          .collection('motoristas2')
          .where('uid', isEqualTo: IdentificacaoController.idUsuario())
          .get();
      if (motoristasSnapshot.docs.isNotEmpty) {
        DocumentSnapshot motoristaDocument = motoristasSnapshot.docs[0];

        String dt = motoristaDocument.get('dt');
        String placa = motoristaDocument.get('placa');

        Sheet p = excel['Planilha1'];
        p.cell(CellIndex.indexByString("L2")).value = dt;
        p.cell(CellIndex.indexByString("M2")).value = placa;
        p.cell(CellIndex.indexByString("N2")).value = getCurrentDate();
        p.cell(CellIndex.indexByString("O2")).value = getCurrentTime();
      } else {
        print('A coleção "Noturnas" está vazia.');
      }

      //
      //Obtendo nome do usuario logado
      //

      LoginController loginController = LoginController();

      Map<String, dynamic> usuario = await loginController.usuarioLogado();
      String nome = usuario['nome'];
      Sheet p = excel['Planilha1'];
      p.cell(CellIndex.indexByString("P2")).value = nome;

      // Exibir dados da coleção "produtos conferidos"

      QuerySnapshot conferenciaSnapshot = await FirebaseFirestore.instance
          .collection('Noturnas')
          .where('uid', isEqualTo: IdentificacaoController.idUsuario())
          .get();
      if (conferenciaSnapshot.docs.isNotEmpty) {
        int linha =
            2; // Comece a partir da linha 6 (ou qualquer outra linha desejada)
        for (DocumentSnapshot devolucaoDocument in conferenciaSnapshot.docs) {
          String codigo = devolucaoDocument.get('codigo');
          String nome = devolucaoDocument.get('nome');
          String quantidade = devolucaoDocument.get('quantidade');
          String tipo = devolucaoDocument.get('observacoes');

          // Preencher os dados da devolução na planilha
          Sheet p = excel['Planilha1'];

          p.cell(CellIndex.indexByString("A$linha")).value = codigo;
          p.cell(CellIndex.indexByString("B$linha")).value = nome;
          if (tipo == 'palet') {
            p.cell(CellIndex.indexByString("C$linha")).value = quantidade;
          } else if (tipo == 'caixa') {
            p.cell(CellIndex.indexByString("D$linha")).value = quantidade;
          } else {
            p.cell(CellIndex.indexByString("E$linha")).value = quantidade;
          }

          linha++; // Incremente a linha para a próxima devolução
        }
      } else {
        print('A coleção "Noturnas" está vazia.');
      }

      // Exibir dados da coleção "Palets"
      QuerySnapshot paletsSnapshot = await FirebaseFirestore.instance
          .collection('palets')
          .where('uid', isEqualTo: IdentificacaoController.idUsuario())
          .get();

      for (QueryDocumentSnapshot paletDoc in paletsSnapshot.docs) {
        // Obtém os dados do documento da coleção "Palets"
        Map<String, dynamic> dadosPalet =
            paletDoc.data() as Map<String, dynamic>;

        // Cria um novo documento na subcoleção "Produtos" com os mesmos dados
        await FirebaseFirestore.instance
            .collection('SaidasConferidas') // Coleção "DTS"
            .add(dadosPalet);

        // Você também pode adicionar campos adicionais ou modificar os dados antes de adicionar na subcoleção
      }

      if (paletsSnapshot.docs.isNotEmpty) {
        Map<String, int> quantidadePorNome =
            {}; // Mapa para armazenar a quantidade por nome
        String linha = ''; // Valor inicial da linha
        int a = 1;
        int b = 2;
        for (DocumentSnapshot paletDocument in paletsSnapshot.docs) {
          String nome = paletDocument.get('nome');
          int quantidade = paletDocument.get('quantidade');

          if (quantidadePorNome.containsKey(nome)) {
            // Se o nome já estiver no mapa, soma a quantidade
            quantidadePorNome[nome] =
                (quantidadePorNome[nome] ?? 0) + quantidade;
          } else {
            // Se o nome ainda não estiver no mapa, adiciona com a quantidade atual
            quantidadePorNome[nome] = quantidade;
          }

          if (nome == 'PALET PBR1') {
            linha =
                'H'; // Atribui o valor 28 para a variável linha se o nome for 'CAIXA PLAST AMARELA 0,60L 24UN (IM)'
          } else if (nome == 'PALET PBR2') {
            linha =
                'I'; // Atribui outro valor para a variável linha se o nome for 'CAIXA PLAST HEINEKEN 0,60L 24UN (IM)'
          } else if (nome == 'PALET PADRAO') {
            linha = 'J';
          } else if (nome == 'PALET AZUL') {
            linha = 'K';
          }

          // Preencher os dados da devolução na planilha
          Sheet p = excel['Planilha1'];
          p.cell(CellIndex.indexByString("$linha$a")).value = nome;
          p.cell(CellIndex.indexByString("$linha$b")).value =
              quantidadePorNome[nome]; // Usar a quantidade do mapa
        }
      } else {
        print('A coleção "palets" está vazia.');
      }

      //FIRESTORAGE
      QuerySnapshot motoristasSnapshot2 = await FirebaseFirestore.instance
          .collection('motoristas2')
          .where('uid', isEqualTo: IdentificacaoController.idUsuario())
          .get();
      if (motoristasSnapshot2.docs.isNotEmpty) {
        DocumentSnapshot motoristaDocument2 = motoristasSnapshot2.docs[0];

        String pasta = getCurrentDate2();
        String dt = motoristaDocument2.get('dt');
        String placa = motoristaDocument2.get('placa');

        if (await IdentificacaoController.filial() == 'Ribeirao Preto') {
          filial = 'Rib';
        } else if (await IdentificacaoController.filial() == 'Caçapava') {
          filial = 'Caçapava';
        } else if (await IdentificacaoController.filial() == 'Santos') {
          filial = 'Santos';
        } else if (await IdentificacaoController.filial() == 'Uberlandia') {
          filial = 'Uberlandia';
        } else {
          filial = 'Nulo';
        }

        var fileBytes = excel.save();
        var fileName = '$filial/ConfNoturna/$pasta/$dt.$placa.xlsx';

        var storage = FirebaseStorage.instance;
        var reference = storage.ref().child(fileName);

        try {
          await reference.putData(fileBytes);

          var downloadUrl = await reference.getDownloadURL();

          print(
              'O arquivo foi enviado com sucesso para o Firebase Cloud Storage.');
          print('URL de download: $downloadUrl');
        } catch (e) {
          print('Ocorreu um erro durante o envio do arquivo: $e');
        }
      }
      excluirColecao();
      excluirMotoristas();
      excluirPalets();
    } catch (e) {
      print('Falha ao envio do arquivo: $e');
    }
  }
}

String getCurrentDate2() {
  DateTime now = DateTime.now();
  String formattedDate = DateFormat('dd.MM.yyyy').format(now);
  return formattedDate;
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

void excluirColecao() async {
  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection('Noturnas')
      .where('uid', isEqualTo: IdentificacaoController.idUsuario())
      .get();
  for (var doc in snapshot.docs) {
    doc.reference.delete();
  }
}

void excluirMotoristas() async {
  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection('motoristas2')
      .where('uid', isEqualTo: IdentificacaoController.idUsuario())
      .get();
  for (var doc in snapshot.docs) {
    doc.reference.delete();
  }
}

void excluirPalets() async {
  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection('palets')
      .where('uid', isEqualTo: IdentificacaoController.idUsuario())
      .get();
  for (var doc in snapshot.docs) {
    doc.reference.delete();
  }
}
