import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:meuapp/carretas/principal_c.dart';
import 'package:meuapp/model/admin.dart';
import 'package:meuapp/model/dados_gravados.dart';
import 'package:meuapp/model/escolher.dart';
import 'package:meuapp/model/lista_modificar.dart';
import 'package:meuapp/model/noturno.dart';
import 'package:meuapp/model/palets.dart';
import 'package:meuapp/model/principal.dart';
import 'package:meuapp/model/produtos_noturno.dart';
import 'package:meuapp/model/produtos_palets.dart';
import 'package:meuapp/model/selecionar.dart';
import 'package:meuapp/reconferencia/avarias.dart';
import 'package:meuapp/reconferencia/caixas.dart';
import 'package:meuapp/reconferencia/dados_motorista.dart';
import 'package:meuapp/reconferencia/devolucoes.dart';
import 'package:meuapp/reconferencia/falta.dart';
import 'package:meuapp/reconferencia/home_page.dart';
import 'package:meuapp/reconferencia/motorista_dt.dart';
import 'package:meuapp/reconferencia/produtos_avarias.dart';
import 'package:meuapp/reconferencia/produtos_caixa.dart';
import 'package:meuapp/reconferencia/produtos_devolucao.dart';
import 'package:meuapp/reconferencia/produtos_falta.dart';
import 'package:meuapp/reconferencia/produtos_sobra.dart';
import 'package:meuapp/reconferencia/produtos_troca.dart';
import 'package:meuapp/reconferencia/sobras.dart';
import 'package:meuapp/reconferencia/troca.dart';
import 'package:meuapp/view/avarias.dart';
import 'package:meuapp/view/cadastrar.dart';
import 'package:meuapp/view/caixas.dart';
import 'package:meuapp/view/dados_motorista.dart';
import 'package:meuapp/view/devolucoes.dart';
import 'package:meuapp/view/falta.dart';
import 'package:meuapp/view/home_page.dart';
import 'package:meuapp/view/login_page.dart';
import 'package:meuapp/view/motorista_dt.dart';
import 'package:meuapp/view/produtos_avarias.dart';
import 'package:meuapp/view/produtos_caixa.dart';
import 'package:meuapp/view/produtos_devolucao.dart';
import 'package:meuapp/view/produtos_falta.dart';
import 'package:meuapp/view/produtos_sobra.dart';
import 'package:meuapp/view/produtos_troca.dart';
import 'package:meuapp/view/recuperar_senha.dart';
import 'package:meuapp/view/sobras.dart';
import 'package:meuapp/view/sobre.dart';
import 'package:meuapp/view/troca.dart';

import 'carretas/carreta_dt.dart';
import 'carretas/entrada.dart';
import 'carretas/descarga.dart';
import 'carretas/descarga_controller.dart';
import 'carretas/saida.dart';
import 'carretas/saida_controller.dart';
import 'view/lista_notafiscal.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Check if a Firebase app has already been initialized
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp();
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
        '/cadastrar': (context) => const CadastrarPage(),
        '/recuperar_senha': (context) => const RecuperarSenhaPage(),
        '/dados_motorista': (context) => const DadosMotoristaScreen(),
        '/sobre': (context) => const SobrePage(),
        '/dts': (context) => const MotoristasScreen(),
        '/devolucoes': (context) => const DevolucoesScreen(),
        '/listdevolucao': (context) => const DevolucaoScreen(),
        '/sobras': (context) => const SobrasScreen(),
        '/listsobra': (context) => const SobraScreen(),
        '/faltas': (context) => const FaltasScreen(),
        '/listfalta': (context) => const FaltaScreen(),
        '/trocas': (context) => const TrocasScreen(),
        '/listtroca': (context) => const TrocaScreen(),
        '/avarias': (context) => const AvariasScreen(),
        '/listavaria': (context) => const AvariaScreen(),
        '/caixas': (context) => const CaixasScreen(),
        '/listcaixa': (context) => const CaixaScreen(),

        //CONFERENCIA DE MAPAS
        '/Noturna': (context) => const NoturnasScreen(),
        '/listNoturna': (context) => const NoturnaScreen(),
        '/principal': (context) => const PrincipalPage(),
        '/dados_dt': (context) => const SelecionarDTScreen(),
        '/lista_dts': (context) => const MotoristasScreen2(),
        '/servidor': (context) => const EscolherPage(),
        '/palets': (context) => const PaletsScreen(),
        '/listpalet': (context) => const PaletScreen(),

        //ADMIN PAGINA
        '/admin': (context) => const AdminPage(),
        '/recuperar': (context) => const DadosGerais(),

        //RECONFERENCIA DE RETORNO DE ROTAS
        '/home2': (context) => const HomePage2(),
        '/dados_motorista5': (context) => const DadosMotoristaScreen5(),
        '/dts2': (context) => const MotoristasScreen5(),
        '/devolucoes2': (context) => const DevolucoesScreen2(),
        '/listdevolucao2': (context) => const DevolucaoScreen2(),
        '/sobras2': (context) => const SobrasScreen2(),
        '/listsobra2': (context) => const SobraScreen2(),
        '/faltas2': (context) => const FaltasScreen2(),
        '/listfalta2': (context) => const FaltaScreen2(),
        '/trocas2': (context) => const TrocasScreen2(),
        '/listtroca2': (context) => const TrocaScreen2(),
        '/avarias2': (context) => const AvariasScreen2(),
        '/listavaria2': (context) => const AvariaScreen2(),
        '/caixas2': (context) => const CaixasScreen2(),
        '/listcaixa2': (context) => const CaixaScreen2(),

        //CARRETAS

        '/carretas': (context) => const PrincipalCarretas(),
        '/entrada': (context) => const EntradaScreen(),
        '/descarga': (context) => const DescargaGerais(),
        '/descargaCarreta': (context) => const DescargaScreen(),
        '/saida': (context) => const SaidaGerais(),
        '/saidaCarreta': (context) => const SaidaScreen(),
        '/listCarretas': (context) => const CarretaDTScreen(),

        //RADIO FREQUENCIA
        '/nf': (context) => const NotaFiscalScreen(),
      },
    );
  }
}
