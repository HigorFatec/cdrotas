import 'package:flutter/material.dart';

class MinhaSplashScreen extends StatefulWidget {
  const MinhaSplashScreen({super.key});

  @override
  _MinhaSplashScreenState createState() => _MinhaSplashScreenState();
}

class _MinhaSplashScreenState extends State<MinhaSplashScreen> {
  @override
  void initState() {
    super.initState();
    // Defina a duração da SplashScreen (em segundos)
    Future.delayed(const Duration(seconds: 3), () {
      // Navegue para a próxima tela após a duração especificada
      Navigator.pushReplacementNamed(context, '/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Aqui você pode personalizar o layout da sua SplashScreen
      body: Container(
        color: Colors.white, // Defina a cor de fundo da tela, se necessário
        child: Center(
          child: Image.asset(
            'lib/images/inicialtela.png',
            fit: BoxFit
                .cover, // Ajusta o tamanho da imagem para preencher a tela
            height: MediaQuery.of(context)
                .size
                .height, // Define a altura da imagem como a altura da tela
            width: MediaQuery.of(context)
                .size
                .width, // Define a largura da imagem como a largura da tela
          ),
        ),
      ),
    );
  }
}
