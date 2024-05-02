import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../controller/login_controller.dart';

final IdentificacaoController = LoginController();

class ExcelCarreta2 {
  var excel;
  var filial;

  ExcelCarreta2() {
    lerPlanilha();
  }

  lerPlanilha() async {
    ByteData data = await rootBundle.load("lib/assets/RelatorioCarretas2.xlsx");
    var bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    excel = Excel.decodeBytes(bytes);
  }

  Future<void> CriarPlanilha() async {
    try {
      Sheet p = excel['CARRETA'];

      //
      //Obtendo nome do usuario logado
      //
/*
      LoginController loginController = LoginController();

      Map<String, dynamic> usuario = await loginController.usuarioLogado();
      String nome = usuario['nome'];
      Sheet p = excel['CARRETA'];
      p.cell(CellIndex.indexByString("T2")).value = nome;
*/
      // Exibir dados da coleção "motoristas"
      QuerySnapshot entradaSnapshot = await FirebaseFirestore.instance
          .collection('Carretas')
          .where('mes', isEqualTo: getCurrentMonth())
          .get();
      if (entradaSnapshot.docs.isNotEmpty) {
        int linha =
            2; // Comece a partir da linha 6 (ou qualquer outra linha desejada)
        for (DocumentSnapshot entradaDocument in entradaSnapshot.docs) {
          String tipo = entradaDocument.get('tipo');
          String transportadora = entradaDocument.get('transportadora');
          String dt = entradaDocument.get('dt');
          String data_chegada = entradaDocument.get('data');
          String horario_chegada = entradaDocument.get('horario');
          String usuario = entradaDocument.get('usuario');

          if (entradaDocument.get('produto') != null) {
            String produto = entradaDocument.get('produto');
            p.cell(CellIndex.indexByString("F$linha")).value = produto;
          }

          if (entradaDocument.get('veiculo') != null) {
            String veiculo = entradaDocument.get('veiculo');
            p.cell(CellIndex.indexByString("E$linha")).value = veiculo;
          }

          if (entradaDocument.get('origem') != null) {
            String origem = entradaDocument.get('origem');
            p.cell(CellIndex.indexByString("H$linha")).value = origem;
          }

          if (entradaDocument.get('tipo_frete') != null) {
            String tipoFrete = entradaDocument.get('tipo_frete');
            p.cell(CellIndex.indexByString("AA$linha")).value = tipoFrete;
          }

          if (entradaDocument.get('cpf') != null) {
            String cpf = entradaDocument.get('cpf');
            p.cell(CellIndex.indexByString("AB$linha")).value = cpf;
          }

          // Preencher os dados da devolução na planilha
          p.cell(CellIndex.indexByString("A$linha")).value = 'Ribeirão Preto';
          p.cell(CellIndex.indexByString("B$linha")).value = dt;
          p.cell(CellIndex.indexByString("C$linha")).value = transportadora;
          p.cell(CellIndex.indexByString("D$linha")).value = tipo;

          p.cell(CellIndex.indexByString("J$linha")).value = data_chegada;
          p.cell(CellIndex.indexByString("K$linha")).value = horario_chegada;
          p.cell(CellIndex.indexByString("W$linha")).value = usuario;

          //INCLUINDO A SAIDA DE CARRETA
          QuerySnapshot descargaSnapshot = await FirebaseFirestore.instance
              .collection('InfoCarretas')
              .where('dt', isEqualTo: dt)
              .where('operacao', isEqualTo: 'descarga')
              .where('mes', isEqualTo: getCurrentMonth())
              .get();

          for (DocumentSnapshot descargaDocument in descargaSnapshot.docs) {
            String data_entrada = descargaDocument.get('data_descarga');
            String horario_entrada = descargaDocument.get('horario_descarga');
            String usuario = descargaDocument.get('usuario');

            p.cell(CellIndex.indexByString("L$linha")).value = data_entrada;
            p.cell(CellIndex.indexByString("M$linha")).value = horario_entrada;
            p.cell(CellIndex.indexByString("X$linha")).value = usuario;
          }

          QuerySnapshot saidaSnapshot = await FirebaseFirestore.instance
              .collection('InfoCarretas')
              .where('dt', isEqualTo: dt)
              .where('operacao', isEqualTo: 'saida')
              .where('mes', isEqualTo: getCurrentMonth())
              .get();

          for (DocumentSnapshot saidaDocument in saidaSnapshot.docs) {
            String data_saida = saidaDocument.get('data_saida');
            String horario_saida = saidaDocument.get('horario_saida');
            String palets_quebrado = saidaDocument.get('palets_quebrados');
            String fita_estourada = saidaDocument.get('fita_estourada');
            String usuario = saidaDocument.get('usuario');

            if (saidaDocument.get('palets') != null) {
              String palets = saidaDocument.get('palets');
              p.cell(CellIndex.indexByString("G$linha")).value = palets;
            }

            if (saidaDocument.get('cheia') != null) {
              String cheia = saidaDocument.get('cheia');
              p.cell(CellIndex.indexByString("I$linha")).value = cheia;
            }

            p.cell(CellIndex.indexByString("Q$linha")).value = data_saida;
            p.cell(CellIndex.indexByString("R$linha")).value = horario_saida;

            p.cell(CellIndex.indexByString("AF$linha")).value = palets_quebrado;
            p.cell(CellIndex.indexByString("AG$linha")).value = fita_estourada;
            p.cell(CellIndex.indexByString("Y$linha")).value = usuario;

            // OCORRENCIAS NA SAIDA
          }
          linha++;
        }

        // ARMAZENANDO TODO TIPO DE DEVOLUÇÃO EM UMA SÓ COLEÇÃO

        QuerySnapshot motoristasSnapshot2 = await FirebaseFirestore.instance
            .collection('Carretas')
            .where('mes', isEqualTo: getCurrentMonth())
            .get();
        if (motoristasSnapshot2.docs.isNotEmpty) {
          DocumentSnapshot motoristaDocument = motoristasSnapshot2.docs[0];

          String pasta = getCurrentDate2();
          String motorista = motoristaDocument.get('dt');

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
          var fileName =
              '$filial/Controle_Carretas/$pasta/$getCurrentDate2().xlsx';
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
        } else {
          print('A coleção "motoristas" está vazia.');
        }
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

String getYesterdayDate() {
  // Obtém a data e hora atual
  DateTime now = DateTime.now();

  // Subtrai um dia da data atual para obter a data de ontem
  DateTime yesterday = now.subtract(Duration(days: 1));

  // Formata a data de ontem como uma string no formato 'dd/MM/yyyy'
  String formattedDate = DateFormat('dd/MM/yyyy').format(yesterday);

  return formattedDate;
}

String getCurrentMonth() {
  DateTime now = DateTime.now();
  String formattedMonth = DateFormat('MM').format(now);
  return formattedMonth;
}
