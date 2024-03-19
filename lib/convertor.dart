import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CurrencyConvertor {
  //API data
  String API_KEY = "516532786ebd6047df9136338cc5f3bc";
  String base_url = 'http://data.fixer.io/api/';
  String currency_base = 'EUR';
  //dynamic fetch data
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
    double _rotationAngle = 0;
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
                                color: Color.fromARGB(255, 8, 157, 176)),
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
                                    style: const TextStyle(
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
              //Animated Arrows
              Container(
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 8, 157, 176),
                  border: Border.all(color: Colors.blue, width: 2),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      // Swap the values of selectedFromCurrency and selectedToCurrency
                      String temp = selectedFromCurrency;
                      selectedFromCurrency = selectedToCurrency;
                      selectedToCurrency = temp;
                      // Update the rotation angle for the animation
                      _rotationAngle += 180;
                    });
                  },
                  child: AnimatedRotation(
                    //Add animation
                    duration: const Duration(milliseconds: 500),
                    turns: _rotationAngle / 360,
                    child: Transform.scale(
                      scale: 1.2,
                      child: const Icon(Icons.swap_vert),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              //Converted Result
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
                                color: Color.fromARGB(255, 8, 157, 176)),
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
                                    style: const TextStyle(
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
