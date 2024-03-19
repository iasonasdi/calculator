import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

//Class to store Currencies
// class CurrencyRate {
//   final double price;
//   final String symbol;

//   const CurrencyRate({
//     required this.price,
//     required this.symbol,
//   });
// }

class CurrencyConvertor {
  //API data
  String API_KEY = "516532786ebd6047df9136338cc5f3bc";
  String base_url = 'http://data.fixer.io/api/';
  String currency_base = 'EUR';
  //dynamic fetch data
  //List<CurrencyRate> currency_rates = [];
  Map<String, dynamic> _exchangeRates = {};

  //Constructor
  CurrencyConvertor() {
    _fetchExchangeRates();
  }

  //Function to fetch exchange rates
  Future<void> _fetchExchangeRates() async {
    String request_url =
        base_url + 'latest?access_key=$API_KEY&base=$currency_base';
    final response = await http.get(Uri.parse(request_url));
    //Receive response
    if (response.statusCode == 200) {
      _exchangeRates = json.decode(response.body);
      if (_exchangeRates.containsKey('rates')) {
        print('Length is: ${_exchangeRates['rates'].length}');
        //   _exchangeRates['rates'].forEach((key, value) {
        //     //print('$key: $value');
        //     //currency_rates.add(CurrencyRate(price: value, symbol: key));
        //   });
      } else {
        print('Rates not found.');
      }
    } else {
      throw Exception('Failed to load exchange rates');
    }
  }

  bool needFetching() {
    return _exchangeRates.isNotEmpty;
  }

  //Function to get widget
  //Convertor
  Widget buildConvertorLayout(
      String selectedFromCurrency, String selectedToCurrency) {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Convertor Mode',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: TextField(
                      keyboardType: TextInputType
                          .number, // Ensures only numbers can be entered
                      decoration: InputDecoration(
                        labelText: 'Convert From',
                        border: const OutlineInputBorder(),
                        suffixIcon: Container(
                          child: DropdownButton<String>(
                            value: selectedFromCurrency,
                            icon: const Icon(Icons.arrow_drop_down,
                                color: Colors.blue),
                            underline: Container(height: 0),
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedFromCurrency = newValue!;
                                print(
                                    "Currency selected: $selectedFromCurrency");
                              });
                            },
                            items: _exchangeRates['rates']
                                .keys
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold)),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  setState(() {
                    // Swap the values of selectedFromCurrency and selectedToCurrency
                    String temp = selectedFromCurrency;
                    selectedFromCurrency = selectedToCurrency;
                    selectedToCurrency = temp;
                  });
                },
                child: const Icon(Icons.swap_vert),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: TextField(
                      keyboardType: TextInputType.number,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Convert To',
                        border: const OutlineInputBorder(),
                        suffixIcon: Container(
                          //color: Color.fromARGB(153, 152, 149, 149),
                          child: DropdownButton<String>(
                            value: selectedToCurrency,
                            icon: const Icon(Icons.arrow_drop_down,
                                color: Colors.blue),
                            underline: Container(height: 0),
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedToCurrency = newValue!;
                              });
                            },
                            items: _exchangeRates['rates']
                                .keys
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold)),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}


//Class to store Currencies
