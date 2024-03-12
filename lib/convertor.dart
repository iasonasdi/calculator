
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;



class CurrencyConverter extends StatefulWidget {
  @override
  _CurrencyConverterState createState() => _CurrencyConverterState();
}


class _CurrencyConverterState extends State<CurrencyConverter> {
  String API_KEY = "516532786ebd6047df9136338cc5f3bc";
  String base_url = 'http://data.fixer.io/api/';
  String currency_base = 'EUR';
  List<String> currency_symbols = ['GBP','JPY','USD'];
  Map<String, dynamic> _exchangeRates = {};
  // List<CurrencyRate> currencyRates = [];

  //Function to perform Requests to receive Rates
  Future<void> _fetchExchangeRates() async {
    String request_url = base_url+'latest?access_key=$API_KEY&base=$currency_base';
    final response = await http.get(Uri.parse(request_url));
    //Receive response
    if (response.statusCode == 200) {
      setState(() {
        _exchangeRates = json.decode(response.body);
        if (_exchangeRates.containsKey('rates')) {
          print('Length is: ${_exchangeRates['rates'].length}');
          _exchangeRates['rates'].forEach((key, value) {
            print('$key: $value');
          });
        } else {
          print('Rates not found.');
        }       
      });
    } else {
      throw Exception('Failed to load exchange rates');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchExchangeRates();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Currency Converter (EUR)'),
      ),
      body: _exchangeRates.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '1 EUR =',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: _exchangeRates['rates'].length,
                  itemBuilder: (context, index) {
                    final currency = _exchangeRates['rates'].keys.elementAt(index);
                    final rate = _exchangeRates['rates'][currency];
                    return ListTile(
                      title: Text(currency),
                      subtitle: Text(rate.toString()),
                    );
                  },
                ),
              ),
            ],
          ),


    );
  }
}





//Class to store currency rates. Can be deducted for better optimization
class CurrencyRate {
  final double price;
  final String symbol;

  const CurrencyRate({
    required this.price,
    required this.symbol,
  });
}