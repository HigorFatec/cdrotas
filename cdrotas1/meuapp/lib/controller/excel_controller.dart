import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:meuapp/controller/login_controller.dart';

import 'firestore_controller.dart';

class ExcelControl {
  var excel;
  var filial;

  // PROJETO PARA CONFERIR VARIOS CAMINHOES DE UMA SO VEZ
  final IdentificacaoController = LoginController();

  ExcelControl() {
    lerPlanilha();
  }

  lerPlanilha() async {
    ByteData data = await rootBundle.load("lib/assets/teste.xlsx");
    var bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    excel = Excel.decodeBytes(bytes);
  }

  Future<void> exibirDadosECriarPlanilha() async {
    try {
      // Exibir dados da coleção "motoristas"
      QuerySnapshot motoristasSnapshot = await FirebaseFirestore.instance
          .collection('motoristas')
          .where('uid', isEqualTo: IdentificacaoController.idUsuario())
          .get();
      if (motoristasSnapshot.docs.isNotEmpty) {
        DocumentSnapshot motoristaDocument = motoristasSnapshot.docs[0];

        String dt = motoristaDocument.get('dt');
        String km = motoristaDocument.get('km');
        String motorista = motoristaDocument.get('motorista');
        String placa = motoristaDocument.get('placa');
        String uid = motoristaDocument.get('uid');

        Sheet p = excel['Plan1'];
        p.cell(CellIndex.indexByString("A3")).value = dt;
        p.cell(CellIndex.indexByString("C3")).value = km;
        p.cell(CellIndex.indexByString("D3")).value = motorista;
        p.cell(CellIndex.indexByString("G3")).value = placa;
        p.cell(CellIndex.indexByString("I3")).value = getCurrentDate();
        p.cell(CellIndex.indexByString("J3")).value = getCurrentTime();

        // ARMAZENANDO TODO TIPO DE MOTORISTAS EM UMA SÓ COLEÇÃO

        await FirebaseFirestore.instance.collection('MotoristasGerais').add({
          'hora': getCurrentTime(),
          'data': getCurrentDate(),
          'dt': dt,
          'km': km,
          'placa': placa,
          'motorista': motorista,
          'filial': await IdentificacaoController.filial(),
          'uid': uid,
        });

        // FIM DO ARMAZENAMENTO DE MOTORISTAS

        //ARMAZENANDO DT's
        // Verificar se o documento já existe
        bool isDocumentExists = false;
        final querySnapshot = await FirebaseFirestore.instance
            .collection('DTSConferidas')
            .where('data', isEqualTo: getCurrentDate())
            .where('dt', isEqualTo: dt)
            .where('uid', isEqualTo: IdentificacaoController.idUsuario())
            .get();
        if (querySnapshot.docs.isNotEmpty) {
          isDocumentExists = true;
        }
        if (!isDocumentExists) {
          await FirebaseFirestore.instance.collection('DTSConferidas').add({
            'data': getCurrentDate(),
            'dt': dt,
            'motorista': motorista,
            'uid': uid,
          });
        }
        //FIM DO ARMAZENAMENTO DE DT
      } else {
        print('A coleção "motoristas" está vazia.');
      }

      //
      //Obtendo nome do usuario logado
      //

      LoginController loginController = LoginController();

      Map<String, dynamic> usuario = await loginController.usuarioLogado();
      String nome = usuario['nome'];
      Sheet p = excel['Plan1'];
      p.cell(CellIndex.indexByString("B43")).value = nome;

      // Exibir dados da coleção "devolucoes"
      QuerySnapshot devolucoesSnapshot = await FirebaseFirestore.instance
          .collection('devolucoes')
          .where('uid', isEqualTo: IdentificacaoController.idUsuario())
          .get();
      if (devolucoesSnapshot.docs.isNotEmpty) {
        int linha =
            6; // Comece a partir da linha 6 (ou qualquer outra linha desejada)
        for (DocumentSnapshot devolucaoDocument in devolucoesSnapshot.docs) {
          String observacoes = '';
          String codigo = devolucaoDocument.get('codigo');
          String nome = devolucaoDocument.get('nome');
          String quantidade = devolucaoDocument.get('quantidade');

          // Preencher os dados da devolução na planilha
          Sheet p = excel['Plan1'];
          p.cell(CellIndex.indexByString("A$linha")).value = nome;
          p.cell(CellIndex.indexByString("D$linha")).value = quantidade;

          linha++; // Incremente a linha para a próxima devolução

          // ARMAZENANDO TODO TIPO DE DEVOLUÇÃO EM UMA SÓ COLEÇÃO

          QuerySnapshot motoristasSnapshot2 = await FirebaseFirestore.instance
              .collection('motoristas')
              .where('uid', isEqualTo: IdentificacaoController.idUsuario())
              .get();
          if (motoristasSnapshot2.docs.isNotEmpty) {
            DocumentSnapshot motoristaDocument = motoristasSnapshot2.docs[0];
            String dt = motoristaDocument.get('dt');
            String placa = motoristaDocument.get('placa');

            await FirebaseFirestore.instance
                .collection('DevolucoesGerais')
                .add({
              'data': getCurrentDate(),
              'codigo': codigo,
              'dt': dt,
              'placa': placa,
              'nome': nome,
              'quantidade': quantidade,
              'observacoes': observacoes,
              'filial': await IdentificacaoController.filial(),
            });

            // FIM DO ARMAZENAMENTO DE DEVOLUÇÕES

            // OBTENDO OS DADOS PARA INSERIR NA COLEÇÃO ATIVOS "ATIVOS"
            if (codigo == '904502' ||
                codigo == '904213' ||
                codigo == '903061' ||
                codigo == '903171' ||
                codigo == '900090' ||
                codigo == '901133' ||
                codigo == '903482' ||
                codigo == '902411' ||
                codigo == '902432' ||
                codigo == '904507' ||
                codigo == '903949' ||
                codigo == '903486' ||
                codigo == '903489' ||
                codigo == '904711' ||
                codigo == '903950' ||
                codigo == '904611') {
              QuerySnapshot motoristasSnapshot2 = await FirebaseFirestore
                  .instance
                  .collection('motoristas')
                  .where('uid', isEqualTo: IdentificacaoController.idUsuario())
                  .get();
              if (motoristasSnapshot2.docs.isNotEmpty) {
                DocumentSnapshot motoristaDocument =
                    motoristasSnapshot2.docs[0];
                String dt = motoristaDocument.get('dt');
                String placa = motoristaDocument.get('placa');
                String uid = motoristaDocument.get('uid');

                await FirebaseFirestore.instance.collection('Devolutivos').add({
                  'hora': getCurrentTime(),
                  'data': getCurrentDate(),
                  'codigo': codigo,
                  'dt': dt,
                  'nome': nome,
                  'placa': placa,
                  'quantidade': quantidade,
                  'observacoes': observacoes,
                  'filial': await IdentificacaoController.filial(),
                  'uid': uid,
                });
              }
            }
            //FIM DA FUNÇÃO PARA INSERIR OS DADOS NA COLEÇÃO "ATIVOS"
          }
        }
      } else {
        print('A coleção "devolucoes" está vazia.');
      }

      // Exibir dados da coleção "Sobras"
      QuerySnapshot sobrasSnapshot = await FirebaseFirestore.instance
          .collection('sobras')
          .where('uid', isEqualTo: IdentificacaoController.idUsuario())
          .get();

      if (sobrasSnapshot.docs.isNotEmpty) {
        int linha =
            6; // Comece a partir da linha 6 (ou qualquer outra linha desejada)
        for (DocumentSnapshot sobraDocument in sobrasSnapshot.docs) {
          String observacoes = '';
          String codigo = sobraDocument.get('codigo');
          String nome = sobraDocument.get('nome');
          String quantidade = sobraDocument.get('quantidade');

          // Preencher os dados da devolução na planilha
          Sheet p = excel['Plan1'];
          p.cell(CellIndex.indexByString("E$linha")).value = nome;
          p.cell(CellIndex.indexByString("F$linha")).value = quantidade;

          linha++; // Incremente a linha para a próxima sobras

          // ARMAZENANDO TODO TIPO DE SOBRAS EM UMA SÓ COLEÇÃO

          QuerySnapshot motoristasSnapshot2 = await FirebaseFirestore.instance
              .collection('motoristas')
              .where('uid', isEqualTo: IdentificacaoController.idUsuario())
              .get();
          if (motoristasSnapshot2.docs.isNotEmpty) {
            DocumentSnapshot motoristaDocument = motoristasSnapshot2.docs[0];
            String dt = motoristaDocument.get('dt');
            String placa = motoristaDocument.get('placa');
            String uid = motoristaDocument.get('uid');

            await FirebaseFirestore.instance.collection('SobrasGerais').add({
              'data': getCurrentDate(),
              'codigo': codigo,
              'dt': dt,
              'placa': placa,
              'nome': nome,
              'quantidade': quantidade,
              'observacoes': observacoes,
              'filial': await IdentificacaoController.filial(),
              'uid': uid,
            });
          }

          // FIM DO ARMAZENAMENTO DE SOBRAS

          // OBTENDO OS DADOS PARA INSERIR NA COLEÇÃO ATIVOS "ATIVOS"
          if (codigo == '904502' ||
              codigo == '904213' ||
              codigo == '903061' ||
              codigo == '903171' ||
              codigo == '900090' ||
              codigo == '901133' ||
              codigo == '903482' ||
              codigo == '902411' ||
              codigo == '902432' ||
              codigo == '904507' ||
              codigo == '903949' ||
              codigo == '903486' ||
              codigo == '903489' ||
              codigo == '904711' ||
              codigo == '903950' ||
              codigo == '904611') {
            QuerySnapshot motoristasSnapshot2 = await FirebaseFirestore.instance
                .collection('motoristas')
                .where('uid', isEqualTo: IdentificacaoController.idUsuario())
                .get();
            if (motoristasSnapshot2.docs.isNotEmpty) {
              DocumentSnapshot motoristaDocument = motoristasSnapshot2.docs[0];
              String dt = motoristaDocument.get('dt');
              String uid = motoristaDocument.get('uid');

              await FirebaseFirestore.instance.collection('Devolutivos').add({
                'hora': getCurrentTime(),
                'data': getCurrentDate(),
                'codigo': codigo,
                'dt': dt,
                'nome': nome,
                'quantidade': quantidade,
                'observacoes': observacoes,
                'filial': await IdentificacaoController.filial(),
                'uid': uid,
              });
            }
          }
          //FIM DA FUNÇÃO PARA INSERIR OS DADOS NA COLEÇÃO "ATIVOS"
        }
      }

      // Exibir dados da coleção "Faltas"
      QuerySnapshot faltasSnapshot = await FirebaseFirestore.instance
          .collection('faltas')
          .where('uid', isEqualTo: IdentificacaoController.idUsuario())
          .get();

      if (faltasSnapshot.docs.isNotEmpty) {
        int linha = 6;
        for (DocumentSnapshot faltaDocument in faltasSnapshot.docs) {
          String nome = faltaDocument.get('nome');
          String quantidade = faltaDocument.get('quantidade');

          // Preencher os dados da devolução na planilha
          Sheet p = excel['Plan1'];
          p.cell(CellIndex.indexByString("G$linha")).value = nome;
          p.cell(CellIndex.indexByString("H$linha")).value = quantidade;

          linha++; // Incremente a linha para a próxima faltas

          // ARMAZENANDO TODO TIPO DE SOBRAS EM UMA SÓ COLEÇÃO

          QuerySnapshot motoristasSnapshot2 =
              await FirebaseFirestore.instance.collection('motoristas').get();
          if (motoristasSnapshot2.docs.isNotEmpty) {
            DocumentSnapshot motoristaDocument = motoristasSnapshot2.docs[0];
            String dt = motoristaDocument.get('dt');
            String placa = motoristaDocument.get('placa');
            String uid = motoristaDocument.get('uid');

            await FirebaseFirestore.instance.collection('FaltasGerais').add({
              'data': getCurrentDate(),
              'dt': dt,
              'placa': placa,
              'nome': nome,
              'quantidade': quantidade,
              'filial': await IdentificacaoController.filial(),
              'uid': uid,
            });
          }

          // FIM DO ARMAZENAMENTO DE SOBRAS
        }
      }

      // Exibir dados da coleção "Trocas"
      QuerySnapshot trocasSnapshot = await FirebaseFirestore.instance
          .collection('trocas')
          .where('uid', isEqualTo: IdentificacaoController.idUsuario())
          .get();
      if (trocasSnapshot.docs.isNotEmpty) {
        int linha = 6;
        for (DocumentSnapshot trocaDocument in trocasSnapshot.docs) {
          String nome = trocaDocument.get('nome');
          String quantidade = trocaDocument.get('quantidade');

          // Preencher os dados da devolução na planilha
          Sheet p = excel['Plan1'];
          p.cell(CellIndex.indexByString("I$linha")).value = nome;
          p.cell(CellIndex.indexByString("J$linha")).value = quantidade;

          linha++; // Incremente a linha para a próxima devolução

          // ARMAZENANDO TODO TIPO DE TROCAS EM UMA SÓ COLEÇÃO

          QuerySnapshot motoristasSnapshot2 =
              await FirebaseFirestore.instance.collection('motoristas').get();
          if (motoristasSnapshot2.docs.isNotEmpty) {
            DocumentSnapshot motoristaDocument = motoristasSnapshot2.docs[0];
            String dt = motoristaDocument.get('dt');
            String placa = motoristaDocument.get('placa');
            String uid = motoristaDocument.get('uid');

            await FirebaseFirestore.instance.collection('TrocasGerais').add({
              'data': getCurrentDate(),
              'dt': dt,
              'placa': placa,
              'nome': nome,
              'quantidade': quantidade,
              'filial': await IdentificacaoController.filial(),
              'uid': uid,
            });
          }

          // FIM DO ARMAZENAMENTO DE SOBRAS
        }
      }

      // Exibir dados da coleção "Avarias"
      QuerySnapshot avariasSnapshot = await FirebaseFirestore.instance
          .collection('avarias')
          .where('uid', isEqualTo: IdentificacaoController.idUsuario())
          .get();
      if (avariasSnapshot.docs.isNotEmpty) {
        int linha = 20;
        for (DocumentSnapshot avariaDocument in avariasSnapshot.docs) {
          String nome = avariaDocument.get('nome');
          String quantidade = avariaDocument.get('quantidade');
          String observacao = avariaDocument.get('observacoes');

          // Preencher os dados da devolução na planilha
          Sheet p = excel['Plan1'];
          p.cell(CellIndex.indexByString("A$linha")).value = nome;
          p.cell(CellIndex.indexByString("D$linha")).value = quantidade;
          p.cell(CellIndex.indexByString("E$linha")).value = observacao;

          linha++; // Incremente a linha para a próxima devolução

          // ARMAZENANDO TODO TIPO DE AVARIAS EM UMA SÓ COLEÇÃO

          QuerySnapshot motoristasSnapshot2 = await FirebaseFirestore.instance
              .collection('motoristas')
              .where('uid', isEqualTo: IdentificacaoController.idUsuario())
              .get();

          if (motoristasSnapshot2.docs.isNotEmpty) {
            DocumentSnapshot motoristaDocument = motoristasSnapshot2.docs[0];
            String dt = motoristaDocument.get('dt');
            String uid = motoristaDocument.get('uid');

            await FirebaseFirestore.instance.collection('AvariadosGerais').add({
              'data': getCurrentDate(),
              'dt': dt,
              'nome': nome,
              'quantidade': quantidade,
              'observacoes': observacao,
              'filial': await IdentificacaoController.filial(),
              'uid': uid,
            });

            // FIM DO ARMAZENAMENTO DE DEVOLUÇÕES
          }
        }
      } else {
        print('A coleção "devolucoes" está vazia.');
      }

// Exibir dados da coleção "Caixas"
      QuerySnapshot caixasSnapshot = await FirebaseFirestore.instance
          .collection('caixas')
          .where('uid', isEqualTo: IdentificacaoController.idUsuario())
          .get();

      if (caixasSnapshot.docs.isNotEmpty) {
        Map<String, int> quantidadePorNome =
            {}; // Mapa para armazenar a quantidade por nome
        int linha = 0; // Valor inicial da linha
        for (DocumentSnapshot caixaDocument in caixasSnapshot.docs) {
          String nome = caixaDocument.get('nome');
          int quantidade = caixaDocument.get('quantidade');
          String observacao = caixaDocument.get('observacoes');

          if (quantidadePorNome.containsKey(nome)) {
            // Se o nome já estiver no mapa, soma a quantidade
            quantidadePorNome[nome] =
                (quantidadePorNome[nome] ?? 0) + quantidade;
          } else {
            // Se o nome ainda não estiver no mapa, adiciona com a quantidade atual
            quantidadePorNome[nome] = quantidade;
          }

          if (nome == 'CAIXA PLAST AMARELA 0,60L 24UN (IM)') {
            linha =
                28; // Atribui o valor 28 para a variável linha se o nome for 'CAIXA PLAST AMARELA 0,60L 24UN (IM)'
          } else if (nome == 'CAIXA PLAST HEINEKEN 0,60L 24UN (IM)') {
            linha =
                29; // Atribui outro valor para a variável linha se o nome for 'CAIXA PLAST HEINEKEN 0,60L 24UN (IM)'
          } else if (nome == 'CAIXA PLASTICA 1L (IM)') {
            linha = 30;
          } else if (nome == 'CAIXA PLASTICA 24 UN 0,30L (IM)') {
            linha = 31;
          } else if (nome == 'GARRAFA 0,30L (IM)') {
            linha = 32;
          } else if (nome == 'GARRAFA 0,60L (IM)') {
            linha = 33;
          } else if (nome == 'GARRAFA CERVEJA 1L (IM)') {
            linha = 34;
          } else if (nome == 'GARRAFA HEINEKEN 0,60L (IM)') {
            linha = 35;
          } else if (nome == 'PALETE MAD PBR 2 (IM)') {
            linha = 36;
          } else if (nome == 'PALETE MAD PBR (IM)') {
            linha = 37;
          } else if (nome == 'PALETE MAD RETORNAVEL (IM)') {
            linha = 38;
          } else if (nome == 'BARRIL 30L') {
            linha = 39;
          } else if (nome == 'BARRIL 50L') {
            linha = 40;
          } else if (nome == 'CARRINHO DE MÃO') {
            linha = 41;
          }

          // Preencher os dados da devolução na planilha
          Sheet p = excel['Plan1'];
          p.cell(CellIndex.indexByString("A$linha")).value = nome;
          p.cell(CellIndex.indexByString("B$linha")).value =
              quantidadePorNome[nome]; // Usar a quantidade do mapa
          p.cell(CellIndex.indexByString("C$linha")).value = observacao;

          // Armazenando os Ativos em uma coleção no firebase

          // Obtém a data do motorista
          QuerySnapshot motoristasSnapshot2 =
              await FirebaseFirestore.instance.collection('motoristas').get();
          if (motoristasSnapshot2.docs.isNotEmpty) {
            DocumentSnapshot motoristaDocument = motoristasSnapshot2.docs[0];
            String dt = motoristaDocument.get('dt');
            String placa = motoristaDocument.get('placa');
            String uid = motoristaDocument.get('uid');

            await FirebaseFirestore.instance.collection('Ativos').add({
              'hora': getCurrentTime(),
              'data': getCurrentDate(),
              'dt': dt,
              'placa': placa,
              'nome': nome,
              'quantidade': quantidade,
              'observacoes': observacao,
              'filial': await IdentificacaoController.filial(),
              'uid': uid,
            });
          }
        }
      } else {
        print('A coleção "caixas" está vazia.');
      }

      QuerySnapshot motoristasSnapshot2 = await FirebaseFirestore.instance
          .collection('motoristas')
          .where('uid', isEqualTo: IdentificacaoController.idUsuario())
          .get();

      if (motoristasSnapshot2.docs.isNotEmpty) {
        DocumentSnapshot motoristaDocument = motoristasSnapshot2.docs[0];

        String pasta = getCurrentDate2();
        String motorista = motoristaDocument.get('motorista');

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
        var fileName = '$filial/RetornoDeRotas/$pasta/$motorista.xlsx';
        print(motorista);

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

        excluirMotoristas();
        excluirDevolucoes();
        excluirAvarias();
        excluirCaixas();
        excluirSobras();
        excluirFaltas();
        excluirTrocas();
      } else {
        print('A coleção "motoristas" está vazia.');
      }
    } catch (error) {
      print(error);
    }
  }
}

String getCurrentDate() {
  DateTime now = DateTime.now();
  String formattedDate = DateFormat('dd/MM/yyyy').format(now);
  return formattedDate;
}

String getCurrentDate2() {
  DateTime now = DateTime.now();
  String formattedDate = DateFormat('dd.MM.yyyy').format(now);
  return formattedDate;
}

String getCurrentTime() {
  DateTime now = DateTime.now();
  String formattedTime = DateFormat('HH:mm:ss').format(now);
  return formattedTime;
}

void excluirMotoristas() async {
  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection('motoristas')
      .where('uid', isEqualTo: IdentificacaoController.idUsuario())
      .get();
  for (var doc in snapshot.docs) {
    doc.reference.delete();
  }
}

void excluirDevolucoes() async {
  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection('devolucoes')
      .where('uid', isEqualTo: IdentificacaoController.idUsuario())
      .get();
  for (var doc in snapshot.docs) {
    doc.reference.delete();
  }
}

void excluirSobras() async {
  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection('sobras')
      .where('uid', isEqualTo: IdentificacaoController.idUsuario())
      .get();
  for (var doc in snapshot.docs) {
    doc.reference.delete();
  }
}

void excluirFaltas() async {
  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection('faltas')
      .where('uid', isEqualTo: IdentificacaoController.idUsuario())
      .get();
  for (var doc in snapshot.docs) {
    doc.reference.delete();
  }
}

void excluirTrocas() async {
  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection('trocas')
      .where('uid', isEqualTo: IdentificacaoController.idUsuario())
      .get();
  for (var doc in snapshot.docs) {
    doc.reference.delete();
  }
}

void excluirAvarias() async {
  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection('avarias')
      .where('uid', isEqualTo: IdentificacaoController.idUsuario())
      .get();
  for (var doc in snapshot.docs) {
    doc.reference.delete();
  }
}

void excluirCaixas() async {
  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection('caixas')
      .where('uid', isEqualTo: IdentificacaoController.idUsuario())
      .get();
  for (var doc in snapshot.docs) {
    doc.reference.delete();
  }
}
