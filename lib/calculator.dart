import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_calc/convertor.dart';
import 'package:math_expressions/math_expressions.dart';

class Calculator extends StatefulWidget {
  @override
  _CalculatorState createState() => _CalculatorState();
}

class _CalculatorState extends State<Calculator> {
  String _output = '';
  String _history = '';
  List<String> _expression_history = [];
  bool reset = false;
  int openBrackets = 0;
  int closeBrackets = 0;
  //CurrencyConverter convertor = CurrencyConverter();
  CurrencyConvertor convertor = CurrencyConvertor();
  String selectedFromCurrency = 'EUR'; // Initially selected currency
  String selectedToCurrency = 'USD'; // Initially selected currency
  String inputValue = ''; //Input value for conversion
  String conversionOutput = ''; //Input value for conversion
  final TextEditingController textEditingFromController = TextEditingController();  //Searching for DropDown
  final TextEditingController textEditingToController = TextEditingController();  //Searching for DropDown ToValue

  //Dark theme
  bool _isDarkThemeEnabled = false;

  // Function to update selectedFromCurrency
  void updateSelectedFromCurrency(String newValue) {
    setState(() {
      selectedFromCurrency = newValue;
    });
  }

  // Function to update selectedToCurrency
  void updateSelectedToCurrency(String newValue) {
    setState(() {
      selectedToCurrency = newValue;
    });
  }

  // Function to update inputValue
  void updateInputValue(String newValue) {
    setState(() {
      inputValue = newValue;
    });
  }

  // Function to update inputValue
  void updateConversionOutputValue(String newValue) {
    setState(() {
      conversionOutput = newValue;
    });
  }

  // Side Panel
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<String> _total_expression_history = [];

  //Convertor
  bool isCalculatorMode = true;

  @override
  Widget build(BuildContext context) {
    Color backgroundColor =
        _isDarkThemeEnabled ? Color(0xFF435585) : Colors.white;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: _isDarkThemeEnabled ? Color(0xFF363062) : Colors.blue,
        title: const Text('Simple Calculator',
            style: TextStyle(color: Colors.black)),
        automaticallyImplyLeading: false,
        leading: Theme(
          data: Theme.of(context).copyWith(
            popupMenuTheme: PopupMenuThemeData(
              color: _isDarkThemeEnabled ? Color(0xFF435585) : Colors.white,
            ),
          ),
          child: PopupMenuButton<int>(
            onSelected: (item) => _onSelectMenuItem(item),
            itemBuilder: (context) => [
              const PopupMenuItem<int>(
                value: 0,
                child: Row(
                  children: [
                    Icon(Icons.lightbulb_outline, color: Colors.black),
                    SizedBox(width: 8),
                    Text('Theme', style: TextStyle(color: Colors.black)),
                  ],
                ),
              ),
              const PopupMenuItem<int>(
                value: 1,
                child: Row(
                  children: [
                    Icon(Icons.help_outline, color: Colors.black),
                    SizedBox(width: 8),
                    Text('Help', style: TextStyle(color: Colors.black)),
                  ],
                ),
              ),
            ],
            icon: const Icon(Icons.settings, color: Colors.black),
          ),
        ),
        actions: <Widget>[
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: IconButton(
                icon: const Icon(Icons.access_time, color: Colors.black),
                onPressed: () {
                  _openSidePanel();
                },
              ),
            ),
          ),
          // Toggle button for convertor or calculator
          IconButton(
            icon: const Icon(Icons.swap_horiz, color: Colors.black),
            onPressed: () {
              setState(() {
                convertor.checkRates();
                isCalculatorMode = !isCalculatorMode;
              });
            },
          ),
        ],
      ),
      body: isCalculatorMode
          ? _buildCalculatorLayout()
          : convertor.buildConvertorLayout(
              selectedFromCurrency,
              selectedToCurrency,
              inputValue,
              conversionOutput,
              updateSelectedFromCurrency,
              updateSelectedToCurrency,
              updateInputValue,
              updateConversionOutputValue,
              _isDarkThemeEnabled,
              textEditingFromController,
              textEditingToController,
            ),
      //Side Panel
      endDrawer: Drawer(
        child: Container(
          color: _isDarkThemeEnabled ? Color(0xFF435585) : Colors.white,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: _isDarkThemeEnabled ? Color(0xFF363062) : Colors.blue,
                ),
                child: Text(
                  'History',
                  style: TextStyle(
                    color:
                        _isDarkThemeEnabled ? Color(0xFF818FB4) : Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
              for (var expression in _total_expression_history.reversed)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _output = expression;
                      // Reset & Count brackets
                      openBrackets = 0;
                      closeBrackets = 0;
                      for (int i = 0; i < _output.length; i++) {
                        if (_output[i] == ')') {
                          closeBrackets++;
                        } else if (_output[i] == '(') {
                          openBrackets++;
                        }
                      }
                    });
                    _closeSidePanel(); //Close panel
                  },
                  child: ListTile(
                    title: Text(
                      expression,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ListTile(
                title: TextButton(
                  onPressed: () {
                    setState(() {
                      _total_expression_history.clear();
                    });
                  },
                  child: Text(
                    'Clear History',
                    style: TextStyle(
                      color: _isDarkThemeEnabled
                          ? Color(0xFF818FB4)
                          : Color.fromARGB(255, 128, 24, 24),
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //Function to get Calculator layout of screen
  Widget _buildCalculatorLayout() {
    return Column(
      children: [
        // Result ouput
        Expanded(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 100),
            child: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.all(20.0),
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  double fontSize = constraints.maxWidth * 0.1;
                  return FittedBox(
                    fit: BoxFit
                        .scaleDown, // Ensures the text scales down to fit within the container
                    alignment: Alignment.centerRight,
                    child: Text(
                      _output,
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                },
              ),
            ),
          ),
        ),

        //Divider for output and Buttons
        const Divider(
          height: 1,
          color: Color.fromARGB(173, 158, 158, 158),
        ),
        const SizedBox(height: 10), // Add space
        //Buttons
        _buildRow('C', '()', '%', '÷'),
        _buildRow('7', '8', '9', '×'),
        _buildRow('4', '5', '6', '-'),
        _buildRow('1', '2', '3', '+'),
        _buildRow('AC', '0', '.', '='),
      ],
    );
  }

  //Function to return a row with 4 specific elements
  Widget _buildRow(String text1, String text2, String text3, String text4) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildButton(text1),
        _buildButton(text2),
        _buildButton(text3),
        _buildButton(text4),
      ],
    );
  }

  //Function to build a calculator's button based on text
  Widget _buildButton(String text) {
    // Get the screen width
    double screenWidth = MediaQuery.of(context).size.width;

    // Calculate button size based on screen width
    double buttonSize = screenWidth /
        5; // Example: divide screen width into 5 parts for button size

    return Container(
      margin: EdgeInsets.only(bottom: 20.0), // Add margin bottom of 10 pixels
      // Adjust the size of the button based on the screen size
      width: buttonSize,
      height: buttonSize,
      child: RawMaterialButton(
        onPressed: () {
          _handleButtonPressed(text);
        },
        elevation: 2.0,
        fillColor: text == '='
            ? _isDarkThemeEnabled
                ? Color(0xFF818FB4) // Bright teal for '=' button in dark theme
                : Color.fromARGB(
                    255, 8, 180, 200) // Original color for light theme
            : _isDarkThemeEnabled
                ? Color(0xFF363062) // Dark theme color for other buttons
                : Color.fromARGB(255, 8, 157,
                    176), // Light theme color for other buttons // Light theme color for other buttons
        // Adjust padding to be proportional to the button size
        padding:
            EdgeInsets.all(buttonSize * 0.2), // Example: 20% of button size
        shape: CircleBorder(),
        child: Text(
          text,
          style: TextStyle(
            color: text == 'C' || text == 'AC'
                ? _isDarkThemeEnabled
                    ? Color(0xFF818FB4)
                    : Color.fromARGB(255, 128, 24, 24)
                : Colors.black,
            // Adjust font size to be proportional to the button size
            fontSize: buttonSize * 0.3, // Example: 30% of button size
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  //Function to handle the Press of a button.
  void _handleButtonPressed(String text) {
    setState(() {
      if (text == '=') {
        _output = _calculateResult();
      } else if (text == '()') {
        if (_output.isEmpty) {
          openBrackets += 1;
          _output += '(';
        } else {
          //Non empty input. Compare current brackets
          //Check last digit. If number or non
          if (isNumber(_output.substring(_output.length - 1))) {
            // If digit is number then
            //Check if amount of '(' is equal to ')' and non equal amount of brackets add closing
            if (openBrackets == 0 || openBrackets == closeBrackets) {
              openBrackets += 1;
              _output += '×(';
            } else {
              closeBrackets += 1;
              _output += ')';
            }
          } else {
            //if no number then if last digit is ')' and non equal amount of brackets add add closing
            if (_output.substring(_output.length - 1) == ')' &&
                openBrackets != closeBrackets) {
              closeBrackets += 1;
              _output += ')';
            } else {
              //if last is ')' then add 'x('
              if (_output.substring(_output.length - 1) == ')' ||
                  _output.substring(_output.length - 1) == '%') {
                _output += '×';
              }
              _output += '(';
              openBrackets += 1;
            }
          }
        }
      } else if (text == 'AC') {
        _output = '';
        reset = false;
        openBrackets = 0;
        closeBrackets = 0;
      } else if (text == 'C') {
        //Check if bracket is deleted
        if (_output.isNotEmpty) {
          if (_output.substring(_output.length - 1) == '(') {
            openBrackets--;
          } else if (_output.substring(_output.length - 1) == ')') {
            closeBrackets--;
          }
          if (_output.substring(_output.length - 1) == 'r' ||
              _output.substring(_output.length - 1) == 'y') {
            //Capture Error
            _output = "";
          } else {
            _output = _output.substring(0, _output.length - 1);
          }
        }
      } else {
        //Reset output after showing previous result
        if (reset) {
          reset = false;
          openBrackets = 0;
          closeBrackets = 0;
          //Keep previous result
          if (isNumber(text)) {
            _output = '';
          }
        }
        if (isOperator(text)) {
          //Cannot start with operator or have two operators side by side
          if (_output.isEmpty ||
              (_output.isNotEmpty &&
                  isOperator(_output.substring(_output.length - 1)))) {
            return;
          }
        }
        _output += text;
      }
    });
  }

  //Function to calculate result and return as String
  String _calculateResult() {
    try {
      //Check if Empty
      if (_output == '') {
        return '';
      }
      print("Fixed _output is: $_output");

      //Fix missing brackets on end
      while (openBrackets > closeBrackets) {
        _output += ')';
        closeBrackets++;
      }
      String expression = _output
          .replaceAll('÷', '/')
          .replaceAll('×', '*')
          .replaceAll('%', '/100');

      //Display last 3 history expressions
      _expression_history.add(_output);
      _total_expression_history.add(_output);
      if (_expression_history.length > 3) {
        _history = _expression_history
            .sublist(_expression_history.length - 3)
            .take(3)
            .join('\n');
      } else {
        _history = _expression_history.take(3).join('\n');
      }

      //Parse expression
      Parser p = Parser();
      Expression exp = p.parse(expression);
      ContextModel cm = ContextModel();
      double result = exp.evaluate(EvaluationType.REAL, cm);
      reset = true;
      return result
          .toStringAsFixed(result.truncateToDouble() == result ? 0 : 10);
    } catch (e) {
      reset = true;
      return 'Error';
    }
  }

  //Check if a String is a number
  bool isNumber(String value) {
    final RegExp numberRegex = RegExp(r'^-?[0-9]+\.?[0-9]*$');
    return numberRegex.hasMatch(value);
  }

  //Check if a String is a Operator
  bool isOperator(String value) {
    RegExp regex = RegExp(r'[%÷×\-+]');
    return regex.hasMatch(value);
  }

  // Function to open Side Panel
  void _openSidePanel() {
    _scaffoldKey.currentState?.openEndDrawer();
  }

  //Function to close the side panel
  void _closeSidePanel() {
    _scaffoldKey.currentState?.openDrawer();
  }

  //Modal for Help
  void _showHelpPanel() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(20),
          color: _isDarkThemeEnabled ? Color(0xFF435585) : Colors.white,
          child: const Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.info_outline, color: Colors.black),
                title: Text('This is a simple calculator',
                    style: TextStyle(color: Colors.black)),
              ),
              ListTile(
                leading: Icon(Icons.history, color: Colors.black),
                title: Text('Click on any item in history to use it again.',
                    style: TextStyle(color: Colors.black)),
              ),
              ListTile(
                leading: Icon(Icons.swap_horiz, color: Colors.black),
                title: Text(
                    'You can use the arrows top right to perform various currency conversions.',
                    style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
        );
      },
    );
  }

  void _onSelectMenuItem(int item) {
    switch (item) {
      case 0:
        // Handle light bulb (Theme) action
        setState(() {
          _isDarkThemeEnabled = !_isDarkThemeEnabled;
        });
        break;
      case 1:
        // Handle question mark (Help) action
        _showHelpPanel();
        break;
      default:
    }
  }
}
