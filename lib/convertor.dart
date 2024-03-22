import 'package:flutter/material.dart';
import 'package:flutter_calc/timeKeeper.dart';
import 'dart:convert';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:http/http.dart' as http;

class CurrencyConvertor {
  //API data
  String API_KEY =
      "34c2a9a9d5855d3027a8fe8c8830c853"; 
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
      if (!_exchangeRates.containsKey('rates')) {
        _exchangeRates = getDefaultRates();
      }
    } else {
      _exchangeRates = getDefaultRates();
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
    return _exchangeRates.isEmpty || tk.checkElapsedTime();
  }

  //Function to return the converting rate
  String convertCurrency(
      double amount, String fromCurrency, String toCurrency) {
    // Check if either currency is not found
    if (_exchangeRates['rates'] == null ||
        _exchangeRates['rates'][fromCurrency] == null ||
        _exchangeRates['rates'][toCurrency] == null) {
      return "NaN";
    }

    // If both currencies are the same, return the amount directly
    if (fromCurrency == toCurrency) {
      //return amount.toStringAsFixed(5);
      return amount.toString();
    }

    //Calculate different conversion rates & Parse exchange rates to double
    double fromRate = _exchangeRates['rates'][fromCurrency].toDouble();
    double toRate = _exchangeRates['rates'][toCurrency].toDouble();

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
  Widget buildConvertorLayout(
      String selectedFromCurrency,
      String selectedToCurrency,
      String inputValue,
      String conversionOutput,
      void Function(String) updateSelectedFromCurrency,
      void Function(String) updateSelectedToCurrency,
      void Function(String) updateInputValue,
      void Function(String) updateConversionOutputValue,
      bool _isDarkThemeEnabled,
      TextEditingController textEditingFromController,
      TextEditingController textEditingToController,
      ) {
    double _rotationAngle = 0;
    //String _inputAmount = '';
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
              Flexible(
                child: Container(
                  width: MediaQuery.of(context).size.width *
                      0.8, // Set width to 80% of screen width
                  child: TextField(
                      keyboardType: TextInputType
                          .number, // Ensures only numbers can be entered
                      decoration: InputDecoration(
                        labelText: 'Convert From',
                        labelStyle: const TextStyle(color: Colors.black),
                        border: const OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          // Define the border when the TextField is focused
                          borderSide:
                              BorderSide(color: Color(0xFF363062), width: 2.0),
                        ),
                        suffixIcon: Container(                                
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton2<String>(
                                    isExpanded: true,
                                    hint: Text(
                                      'Select Item',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Theme.of(context).hintColor,
                                      ),
                                    ),
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
                                    value: selectedFromCurrency,
                                    onChanged: (String? newValue) {
                                        setState(() {
                                          selectedFromCurrency = newValue!;
                                          updateSelectedFromCurrency(newValue);
                                          // Update Results every time drop down changes
                                          if (containsOnlyNumbers(inputValue)) {
                                            conversionOutput = convertCurrency(
                                                double.parse(inputValue),
                                                selectedFromCurrency,
                                                selectedToCurrency);
                                          }else if(inputValue==''){
                                              conversionOutput='';
                                          } else {
                                            conversionOutput = 'ERR';
                                          }
                                            updateConversionOutputValue(conversionOutput);
                                        });
                                      },
                                    buttonStyleData: const ButtonStyleData(
                                      padding: EdgeInsets.symmetric(horizontal: 16),
                                      height: 40,
                                      width: 100,
                                    ),
                                    dropdownStyleData: const DropdownStyleData(
                                      maxHeight: 200,
                                    ),
                                    menuItemStyleData: const MenuItemStyleData(
                                      height: 40,
                                    ),
                                    dropdownSearchData: DropdownSearchData(
                                      searchController: textEditingFromController,
                                      searchInnerWidgetHeight: 50,
                                      searchInnerWidget: Container(
                                        height: 50,
                                        padding: const EdgeInsets.only(
                                          top: 8,
                                          bottom: 4,
                                          right: 8,
                                          left: 8,
                                        ),
                                        child: TextFormField(
                                          expands: true,
                                          maxLines: null,
                                          controller: textEditingFromController,
                                          decoration: InputDecoration(
                                            isDense: true,
                                            contentPadding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 8,
                                            ),
                                            hintText: 'Search for an item...',
                                            hintStyle: const TextStyle(fontSize: 12),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                          ),
                                        ),
                                      ),
                                      searchMatchFn: (item, searchValue) {
                                        return item.value.toString().toUpperCase().contains(searchValue.toUpperCase());
                                      },
                                    ),
                                    //This to clear the search value when you close the menu
                                    onMenuStateChange: (isOpen) {
                                      if (!isOpen) {
                                        textEditingFromController.clear();
                                      }
                                    },
                                  ),
                                ),


                        ),
                      ),
                      onChanged: (String newValue) {
                        setState(() {
                          inputValue = newValue;
                          if (containsOnlyNumbers(inputValue)) {
                            conversionOutput = convertCurrency(
                                double.parse(newValue),
                                selectedFromCurrency,
                                selectedToCurrency);
                          }else if(inputValue==''){
                            conversionOutput='';
                          } else {
                            conversionOutput = 'ERR';
                          }
                          updateConversionOutputValue(conversionOutput);
                          updateInputValue(inputValue);
                        });
                      },
                      style: const TextStyle(color: Colors.black)),
                ),
              ),
              const SizedBox(height: 20),
              //Animated Arrows
              Container(
                decoration: BoxDecoration(
                  color: _isDarkThemeEnabled
                      ? Color(0xFF363062)
                      : Color.fromARGB(255, 8, 157, 176),
                  border: Border.all(
                      color:
                          _isDarkThemeEnabled ? Color(0xFF4A4A82) : Colors.blue,
                      width: 2),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      // Swap the values of selectedFromCurrency and selectedToCurrency
                      String temp = selectedFromCurrency;
                      selectedFromCurrency = selectedToCurrency;
                      selectedToCurrency = temp;
                      updateSelectedFromCurrency(selectedFromCurrency);
                      updateSelectedToCurrency(selectedToCurrency);
                      //Swap Values on inputs
                      conversionOutput = '';
                      updateConversionOutputValue('');
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
              Container(
                width: MediaQuery.of(context).size.width *
                    0.8, // Set width to 80% of screen width
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
                        conversionOutput.isNotEmpty
                            ? conversionOutput
                            : "Converted amount",
                        style: TextStyle(color: Colors.black, fontSize: 18),
                      ),
                    ),
                    DropdownButtonHideUnderline(
                                  child: DropdownButton2<String>(
                                    isExpanded: true,
                                    hint: Text(
                                      'Select Item',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Theme.of(context).hintColor,
                                      ),
                                    ),
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
                                    value: selectedToCurrency,
                                     onChanged: (String? newValue) {
                                        setState(() {
                                          selectedToCurrency = newValue!;
                                          updateSelectedToCurrency(newValue);
                                          if (containsOnlyNumbers(inputValue)) {
                                            conversionOutput = convertCurrency(
                                                double.parse(inputValue),
                                                selectedFromCurrency,
                                                selectedToCurrency);
                                          }else if(inputValue==''){
                                              conversionOutput='';
                                          } else {
                                            conversionOutput = 'ERR';
                                          }
                                          updateConversionOutputValue(conversionOutput);
                                        });
                                      },
                                    buttonStyleData: const ButtonStyleData(
                                      padding: EdgeInsets.symmetric(horizontal: 16),
                                      height: 40,
                                      width: 100,
                                    ),
                                    dropdownStyleData: const DropdownStyleData(
                                      maxHeight: 200,
                                    ),
                                    menuItemStyleData: const MenuItemStyleData(
                                      height: 40,
                                    ),
                                    dropdownSearchData: DropdownSearchData(
                                      searchController: textEditingToController,
                                      searchInnerWidgetHeight: 50,
                                      searchInnerWidget: Container(
                                        height: 50,
                                        padding: const EdgeInsets.only(
                                          top: 8,
                                          bottom: 4,
                                          right: 8,
                                          left: 8,
                                        ),
                                        child: TextFormField(
                                          expands: true,
                                          maxLines: null,
                                          controller: textEditingToController,
                                          decoration: InputDecoration(
                                            isDense: true,
                                            contentPadding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 8,
                                            ),
                                            hintText: 'Search for an item...',
                                            hintStyle: const TextStyle(fontSize: 12),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                          ),
                                        ),
                                      ),
                                      searchMatchFn: (item, searchValue) {
                                        return item.value.toString().toUpperCase().contains(searchValue.toUpperCase());
                                      },
                                    ),
                                    //This to clear the search value when you close the menu
                                    onMenuStateChange: (isOpen) {
                                      if (!isOpen) {
                                        textEditingToController.clear();
                                      }
                                    },
                                  ),
                                ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  //Function that use a regular expression to match only digits (0-9)
  bool containsOnlyNumbers(String inputAmount) {
    return RegExp(r'^[0-9]+$').hasMatch(inputAmount);
  }

  Map<String, dynamic> getDefaultRates() {
    return {
      'success': true,
      'timestamp': 1711015144,
      'base': 'EUR',
      'date': '2024-03-21',
      'rates': {
        "AED": 4.007555,
        "AFN": 77.282145,
        "ALL": 102.677444,
        "AMD": 434.243349,
        "ANG": 1.950369,
        "AOA": 911.752906,
        "ARS": 931.13656,
        "AUD": 1.651461,
        "AWG": 1.964272,
        "AZN": 1.883941,
        "BAM": 1.951958,
        "BBD": 2.18499,
        "BDT": 118.766249,
        "BGN": 1.954588,
        "BHD": 0.411348,
        "BIF": 3095.777221,
        "BMD": 1.091262,
        "BND": 1.454697,
        "BOB": 7.477318,
        "BRL": 5.420074,
        "BSD": 1.082165,
        "BTC": 1.6323575e-5,
        "BTN": 89.957038,
        "BWP": 14.824638,
        "BYN": 3.541414,
        "BYR": 21388.739492,
        "BZD": 2.181297,
        "CAD": 1.471911,
        "CDF": 3040.256407,
        "CHF": 0.976085,
        "CLF": 0.038131,
        "CLP": 1052.151773,
        "CNY": 7.85589,
        "COP": 4211.311855,
        "CRC": 544.558162,
        "CUC": 1.091262,
        "CUP": 28.918449,
        "CVE": 110.04891,
        "CZK": 25.219942,
        "DJF": 192.699853,
        "DKK": 7.45809,
        "DOP": 63.947657,
        "DZD": 146.679847,
        "EGP": 50.934882,
        "ERN": 16.368933,
        "ETB": 61.466104,
        "EUR": 1,
        "FJD": 2.474055,
        "FKP": 0.858601,
        "GBP": 0.854294,
        "GEL": 2.957611,
        "GGP": 0.858601,
        "GHS": 14.087338,
        "GIP": 0.858601,
        "GMD": 74.124026,
        "GNF": 9302.203211,
        "GTQ": 8.440349,
        "GYD": 226.585082,
        "HKD": 8.535035,
        "HNL": 26.722874,
        "HRK": 7.510476,
        "HTG": 143.467632,
        "HUF": 393.945576,
        "IDR": 17101.388486,
        "ILS": 3.95361,
        "IMP": 0.858601,
        "INR": 90.741672,
        "IQD": 1417.603431,
        "IRR": 45879.391989,
        "ISK": 148.498683,
        "JEP": 0.858601,
        "JMD": 166.711052,
        "JOD": 0.773594,
        "JPY": 164.861896,
        "KES": 145.138378,
        "KGS": 97.679095,
        "KHR": 4380.438798,
        "KMF": 495.160776,
        "KPW": 982.140015,
        "KRW": 1447.678914,
        "KWD": 0.335388,
        "KYD": 0.901821,
        "KZT": 487.638015,
        "LAK": 22654.308848,
        "LBP": 96905.629998,
        "LKR": 329.14069,
        "LRD": 210.204353,
        "LSL": 20.526915,
        "LTL": 3.222214,
        "LVL": 0.660094,
        "LYD": 5.221699,
        "MAD": 10.874148,
        "MDL": 19.208107,
        "MGA": 4854.712062,
        "MKD": 61.614278,
        "MMK": 2272.516906,
        "MNT": 3704.102515,
        "MOP": 8.720257,
        "MRU": 43.519561,
        "MUR": 50.302881,
        "MVR": 16.876361,
        "MWK": 1821.714732,
        "MXN": 18.22244,
        "MYR": 5.145081,
        "MZN": 69.292124,
        "NAD": 20.52696,
        "NGN": 1543.950486,
        "NIO": 39.833791,
        "NOK": 11.506471,
        "NPR": 143.939618,
        "NZD": 1.79314,
        "OMR": 0.420099,
        "PAB": 1.08217,
        "PEN": 4.005217,
        "PGK": 4.079196,
        "PHP": 61.164183,
        "PKR": 301.240829,
        "PLN": 4.302902,
        "PYG": 7903.408598,
        "QAR": 3.973308,
        "RON": 4.974296,
        "RSD": 117.225538,
        "RUB": 100.836444,
        "RWF": 1391.737356,
        "SAR": 4.092565,
        "SBD": 9.22622,
        "SCR": 14.728226,
        "SDG": 639.479282,
        "SEK": 11.343005,
        "SGD": 1.461135,
        "SHP": 1.388037,
        "SLE": 24.680107,
        "SLL": 24680.106593,
        "SOS": 623.653249,
        "SRD": 38.331689,
        "STD": 22586.924683,
        "SVC": 9.468321,
        "SYP": 14188.43239,
        "SZL": 20.452652,
        "THB": 39.339609,
        "TJS": 11.860248,
        "TMT": 3.824874,
        "TND": 3.373143,
        "TOP": 2.5858,
        "TRY": 35.380575,
        "TTD": 7.345476,
        "TWD": 34.77351,
        "TZS": 2782.71853,
        "UAH": 42.362952,
        "UGX": 4193.765205,
        "USD": 1.091262,
        "UYU": 41.558017,
        "UZS": 13594.244323,
        "VEF": 3951769.370372,
        "VES": 39.524557,
        "VND": 27057.84672,
        "VUV": 131.73759,
        "WST": 3.008219,
        "XAF": 654.704433,
        "XAG": 0.042842,
        "XAU": 0.000495,
        "XCD": 2.94919,
        "XDR": 0.812745,
        "XOF": 654.665513,
        "XPF": 119.331742,
        "YER": 273.170257,
        "ZAR": 20.426268,
        "ZMK": 9822.625185,
        "ZMW": 27.973815,
        "ZWL": 351.385989
      },
    };
  }
}
