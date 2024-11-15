import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const request = 'https://api.hgbrasil.com/finance?key=4d70caa1';

void main() async {
  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(
      primaryColor: Colors.amber,
    ),
  ));
}

Future<Map> getData() async {
  http.Response response = await http.get(Uri.parse(request));
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController brlController = TextEditingController();
  final TextEditingController usdController = TextEditingController();
  final TextEditingController btcController = TextEditingController();

  double? dolar;
  double? bitcoin;

  void _clearAll() {
    brlController.clear();
    usdController.clear();
    btcController.clear();
  }

  void _brlChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }
    double brl = double.parse(text);
    usdController.text = (brl / dolar!).toStringAsFixed(2);
    btcController.text = (brl / bitcoin!).toStringAsFixed(8);
  }

  void _usdChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }
    double usd = double.parse(text);
    brlController.text = (usd * dolar!).toStringAsFixed(2);
    btcController.text = (usd * dolar! / bitcoin!).toStringAsFixed(8);
  }

  void _btcChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }
    double btc = double.parse(text);
    brlController.text = (btc * bitcoin!).toStringAsFixed(2);
    usdController.text = (btc * bitcoin! / dolar!).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("\$ Conversor \$"),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: FutureBuilder<Map>(
          future: getData(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return Center(
                  child: Text(
                    "Carregando dados...",
                    style: TextStyle(color: Colors.amber, fontSize: 25),
                    textAlign: TextAlign.center,
                  ),
                );
              case ConnectionState.done:
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Erro ao carregar dados!",
                      style: TextStyle(color: Colors.amber, fontSize: 25),
                      textAlign: TextAlign.center,
                    ),
                  );
                } else {
                  dolar = snapshot.data!["results"]["currencies"]["USD"]["buy"];
                  bitcoin =
                      snapshot.data!["results"]["currencies"]["BTC"]["buy"];

                  // Mostrar os campos de texto
                  return SingleChildScrollView(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.currency_exchange,
                          size: 120,
                          color: Colors.black,
                        ),
                        SizedBox(height: 20),
                        buildTextField(
                            "BRL", "R\$ ", brlController, _brlChanged),
                        SizedBox(height: 10),
                        buildTextField(
                            "USD", "US\$ ", usdController, _usdChanged),
                        SizedBox(height: 10),
                        buildTextField("BTC", "₿ ", btcController, _btcChanged),
                      ],
                    ),
                  );
                }
              default:
                return Center(child: CircularProgressIndicator());
            }
          }),
    );
  }

  //Criacao dos campos de texto
  Widget buildTextField(String label, String prefix,
      TextEditingController controller, Function(String) onChanged) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.black, fontSize: 20),
        prefixText: prefix,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onChanged: onChanged,
    );
  }
}
