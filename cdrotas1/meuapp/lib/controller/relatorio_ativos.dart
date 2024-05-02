import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class RelatorioAtivos {
  var excel;

  RelatorioAtivos() {
    lerPlanilha();
  }

  lerPlanilha() async {
    ByteData data = await rootBundle.load("lib/assets/RelatorioAtivos.xlsx");
    var bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    excel = Excel.decodeBytes(bytes);
  }

  Future<void> exportarExcel() async {
    try {
      // Exibir dados da coleção "produtos conferidos"

      QuerySnapshot conferenciaSnapshot = await FirebaseFirestore.instance
          .collection('Ativos')
          .where('data', isEqualTo: getYesterdayDate())
          .get();
      if (conferenciaSnapshot.docs.isNotEmpty) {
        int linha =
            2; // Comece a partir da linha 6 (ou qualquer outra linha desejada)
        for (DocumentSnapshot devolucaoDocument in conferenciaSnapshot.docs) {
          String dt = devolucaoDocument.get('dt');
          String data = devolucaoDocument.get('data');
          String nome = devolucaoDocument.get('nome');
          int quantidade = devolucaoDocument.get('quantidade');
          String tipo = devolucaoDocument.get('observacoes');
          String placa = devolucaoDocument.get('placa');
          String filial = devolucaoDocument.get('filial');

          // Preencher os dados da devolução na planilha
          Sheet p = excel['Ativo'];

          p.cell(CellIndex.indexByString("A$linha")).value = dt;
          p.cell(CellIndex.indexByString("B$linha")).value = nome;
          p.cell(CellIndex.indexByString("C$linha")).value = quantidade;
          p.cell(CellIndex.indexByString("D$linha")).value = tipo;
          p.cell(CellIndex.indexByString("E$linha")).value = data;
          p.cell(CellIndex.indexByString("F$linha")).value = placa;
          p.cell(CellIndex.indexByString("G$linha")).value = filial;

          linha++; // Incremente a linha para a próxima devolução
        }
      } else {
        print('A coleção "Ativos" está vazia.');
      }

      // Exibir dados da coleção "devolucoes"
      QuerySnapshot devolutivosSnapshot = await FirebaseFirestore.instance
          .collection('Devolutivos')
          .where('data', isEqualTo: getYesterdayDate())
          .get();
      if (devolutivosSnapshot.docs.isNotEmpty) {
        int linha =
            2; // Comece a partir da linha 6 (ou qualquer outra linha desejada)
        for (DocumentSnapshot devolutivoDocument in devolutivosSnapshot.docs) {
          String dt = devolutivoDocument.get('dt');
          String data = devolutivoDocument.get('data');

          String codigo = devolutivoDocument.get('codigo');
          String nome = devolutivoDocument.get('nome');
          String quantidade = devolutivoDocument.get('quantidade');
          String filial = devolutivoDocument.get('filial');
          String placa = devolutivoDocument.get('placa');

          // Preencher os dados da devolução na planilha
          Sheet p = excel['Devolucao'];

          p.cell(CellIndex.indexByString("A$linha")).value = dt;
          p.cell(CellIndex.indexByString("B$linha")).value = codigo;
          p.cell(CellIndex.indexByString("C$linha")).value = nome;
          p.cell(CellIndex.indexByString("D$linha")).value = quantidade;
          p.cell(CellIndex.indexByString("E$linha")).value = filial;
          p.cell(CellIndex.indexByString("F$linha")).value = data;
          p.cell(CellIndex.indexByString("G$linha")).value = placa;

          linha++; // Incremente a linha para a próxima devolução
        }
      } else {
        print('A coleção "Devolutivos" está vazia.');
      }

      //FIRESTORAGE

      String pasta = getCurrentDate2();

      var fileBytes = excel.save();
      var fileName = 'Rib/RelatorioRetornoDeRotas/1.$pasta.xlsx';

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

String getYesterdayDate() {
  // Obtém a data e hora atual
  DateTime now = DateTime.now();

  // Subtrai um dia da data atual para obter a data de ontem
  DateTime yesterday = now.subtract(Duration(days: 1));

  // Formata a data de ontem como uma string no formato 'dd/MM/yyyy'
  String formattedDate = DateFormat('dd/MM/yyyy').format(yesterday);

  return formattedDate;
}
