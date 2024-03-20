import 'package:flutter/material.dart';
import 'package:flutter_calc/timeKeeper.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CurrencyConvertor {
  //API data
  String API_KEY = "516532786ebd6047df9136338cc5f3bc";
  String base_url = 'http://data.fixer.io/api/';
  String currency_base = 'EUR';
  //dynamic fetch data
  Map<String, dynamic> _exchangeRates = {};

  TimeKeeper tk = TimeKeeper();
  //Constructor
  CurrencyConvertor() {
    _fetchExchangeRates();
  }

  //Function to fetch exchange rates
  Future<void> _fetchExchangeRates() async {
    tk.updateLastCalledTime();
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

  //Function to check if rates are needed
  void checkRates() {
    if (needFetching()) {
      _fetchExchangeRates();
    }
  }

  //Function to check if rates are needed
  bool needFetching() {
    print('Checking need of rates');
    print("Current rates:" + _exchangeRates.toString());
    return _exchangeRates.isEmpty || tk.checkElapsedTime();
  }

  //Function to return the converting rate
  String convertCurrency(
      double amount, String fromCurrency, String toCurrency) {
    // Check if either currency is not found
    if (_exchangeRates['rates'][fromCurrency] == null ||
        _exchangeRates['rates'][toCurrency] == null) {
      return "NaN";
    }

    // If both currencies are the same, return the amount directly
    if (fromCurrency == toCurrency) {
      return amount.toStringAsFixed(5);
    }

    double fromRate = _exchangeRates['rates'][fromCurrency];
    double toRate = _exchangeRates['rates'][toCurrency];

    // If fromCurrency is EUR, directly convert to toCurrency
    if (fromCurrency == 'EUR') {
      double convertedAmount = amount * toRate;
      return convertedAmount.toStringAsFixed(5);
    }

    // If toCurrency is EUR, directly convert from fromCurrency to EUR
    if (toCurrency == 'EUR') {
      double convertedAmount = amount / fromRate;
      return convertedAmount.toStringAsFixed(5);
    }

    // If neither currency is EUR, convert fromCurrency to EUR first, then to toCurrency
    double amountInEUR = amount / fromRate; // Convert fromCurrency to EUR
    double convertedAmount = amountInEUR * toRate; // Convert EUR to toCurrency

    return convertedAmount.toStringAsFixed(5);
  }

  //Function to get widget
  //Convertor
  Widget buildConvertorLayout(
      String selectedFromCurrency, String selectedToCurrency) {
    double _rotationAngle = 0;
    TextEditingController _fromCurrencyController = TextEditingController();
    TextEditingController _toCurrencyController = TextEditingController();
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
                      controller: _fromCurrencyController,
                      keyboardType: TextInputType.number,
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
                                // Perform conversion only if there's a valid amount
                                String amountStr = _fromCurrencyController.text;
                                double amount = double.tryParse(amountStr) ??
                                    0; // Default to 0 if parsing fails
                                if (amount > 0) {
                                  String convertedAmount = convertCurrency(
                                      amount,
                                      selectedFromCurrency,
                                      selectedToCurrency);
                                  _toCurrencyController.text = convertedAmount;
                                }
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
                      onChanged: (String newValue) {
                        setState(() {
                          _fromCurrencyController.text = newValue;
                          // Check if the input is a valid number before converting
                          if (double.tryParse(newValue) != null) {
                            _toCurrencyController.text = convertCurrency(
                              double.parse(newValue),
                              selectedFromCurrency,
                              selectedToCurrency,
                            );
                          } else {
                            _toCurrencyController.text =
                                ''; // Reset or handle invalid input as needed
                          }
                        });
                      },
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
                      String tempCurrency = selectedFromCurrency;
                      selectedFromCurrency = selectedToCurrency;
                      selectedToCurrency = tempCurrency;

                      // Swap the TextField values for From Currency and To Currency
                      String tempAmount = _fromCurrencyController.text;
                      _fromCurrencyController.text = _toCurrencyController.text;
                      _toCurrencyController.text = tempAmount;

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
                      controller: _toCurrencyController,
                      keyboardType: TextInputType.number,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Convert To',
                        border: const OutlineInputBorder(),
                        suffixIcon: Container(
                          child: DropdownButton<String>(
                            value: selectedToCurrency,
                            icon: const Icon(Icons.arrow_drop_down,
                                color: Color.fromARGB(255, 8, 157, 176)),
                            underline: Container(height: 0),
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedToCurrency = newValue!;
                                // Reuse the existing amount in the from currency field for conversion
                                String amountStr = _fromCurrencyController.text;
                                double amount = double.tryParse(amountStr) ??
                                    0; // Default to 0 if parsing fails
                                // Perform conversion only if there's a valid amount
                                if (amount > 0) {
                                  String convertedAmount = convertCurrency(
                                      amount,
                                      selectedFromCurrency,
                                      selectedToCurrency);
                                  _toCurrencyController.text = convertedAmount;
                                }
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
