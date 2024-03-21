import 'package:flutter/material.dart';
import 'package:flutter_calc/timeKeeper.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CurrencyConvertor {
  //API data
  String API_KEY = "34c2a9a9d5855d3027a8fe8c8830c853";//"516532786ebd6047df9136338cc5f3bc";
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

    //Calculate different conversion rates
    // double fromRate = _exchangeRates['rates'][fromCurrency];
    // double toRate = _exchangeRates['rates'][toCurrency];
    // Parse exchange rates to double
    double fromRate = double.tryParse(_exchangeRates['rates'][fromCurrency]) ?? 1.0;
    double toRate = double.tryParse(_exchangeRates['rates'][toCurrency]) ?? 1.0;

    // If fromCurrency is EUR convert to toCurrency
    if (fromCurrency == 'EUR') {
      double convertedAmount = amount * toRate;
      return convertedAmount.toStringAsFixed(5);
    }

    // If toCurrency is EUR, convert from fromCurrency to EUR
    if (toCurrency == 'EUR') {
      double convertedAmount = amount / fromRate;
      return convertedAmount.toStringAsFixed(5);
    }

    // If neither currency is EUR, convert fromCurrency to EUR first
    double amountInEUR = amount / fromRate; // Convert fromCurrency to EUR
    double convertedAmount = amountInEUR * toRate; // Convert EUR to toCurrency

    return convertedAmount.toStringAsFixed(5);
  }

  //Function to get widget
  //Convertor
  Widget buildConvertorLayout(String selectedFromCurrency,
      String selectedToCurrency, String calculatorOutput) {
    double _rotationAngle = 0;
    String _inputAmount = '';
    String _convertedAmount = '';
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
                      onChanged: (String newValue) {
                        setState(() {
                          _inputAmount = newValue;
                          _convertedAmount = "from:$selectedFromCurrency to $selectedToCurrency and";//on rate:${_exchangeRates['rates'][selectedFromCurrency]}++";
                          //String result= convertCurrency(double.parse(newValue),selectedFromCurrency, selectedToCurrency);
                          double result = double.parse(newValue);
                          _convertedAmount +='NV:$newValue and isEmpt: ${_convertedAmount.isEmpty} and RSC: $result and prev: <$_convertedAmount>';
                          
                          // Check if the input is a valid number before converting
                          // if (double.tryParse(newValue) != null) {
                          //   _convertedAmount = convertCurrency(
                          //     double.parse(newValue),
                          //     selectedFromCurrency,
                          //     selectedToCurrency,
                          //   );
                          //   _convertedAmount ='IF:$_inputAmount';
                          // } else {
                          //   _convertedAmount='2';
                          //   //_convertedAmount ='Val:$newValue';//''; // Reset or handle invalid input as needed
                          // }
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
              Flexible(
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 20), // Adjust padding to match TextField
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: Colors.grey), // Border color to match TextField
                    borderRadius: BorderRadius.circular(
                        4), // Border radius to match TextField
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _convertedAmount.isNotEmpty? _convertedAmount: "Enter amount to convert",
                          style: TextStyle(
                              fontSize:
                                  16), // Adjust font size to match TextField
                        ),
                      ),
                      // Mimic the dropdown button from your TextField
                      DropdownButton<String>(
                        value: selectedToCurrency,
                        icon: const Icon(Icons.arrow_drop_down,
                            color: Color.fromARGB(255, 8, 157, 176)),
                        underline: Container(),
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
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
