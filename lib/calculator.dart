import 'package:flutter/material.dart';
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

  // Side Panel
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<String> _total_expression_history = [];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Simple Calculator'),
        automaticallyImplyLeading: false,
        actions: 
            //Clickable Clock icon for History
            <Widget>[
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: IconButton(
                      icon: Icon(Icons.access_time),
                      onPressed: () {
                        _openSidePanel();
                      },
                    ),
                  ),
                ),
              ],
      ),
      body: Column(
        children: [    
            //Clickable Clock icon for History
          //    GestureDetector(
          //       onTap: () {
          //         _openSidePanel();
          //       },
          //       child: const Padding(
          //         padding: EdgeInsets.symmetric(horizontal: 20.0),
          //         child: Row(
          //           children: [
          //             Spacer(), // Make it float right
          //             Icon(
          //               Icons.access_time,
          //               size: 24,
          //             ),
          //           ],
          //         ),
          //       ),
          // ),
     
          //Clickable History      
          Expanded(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 150),
                child: SingleChildScrollView( // Wrap with SingleChildScrollView
                  child: Container(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(
                        _expression_history.length >= 3 ? 3 : _expression_history.length, 
                        (index) => GestureDetector(
                          onTap: () {
                            setState(() {
                              _output = _expression_history[_expression_history.length - index - 1];
                              // Reset & Count brackets
                              openBrackets = 0;
                              closeBrackets = 0;
                              for(int i = 0; i < _output.length; i ++) {
                                if (_output[i] == ')') {
                                  closeBrackets ++;
                                } else if (_output[i] == '(') {
                                  openBrackets ++;
                                }
                              }
                            });
                          },
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              _expression_history[_expression_history.length - index - 1],
                              style: const TextStyle(
                                fontSize: 25.0,
                                fontWeight: FontWeight.normal,
                                decoration: TextDecoration.none,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ).reversed.toList(),
                    ),
                  ),
                ),
              ),
          ),
          //Divider for history and Output
          const Divider(
            height: 1, 
            color: Color.fromARGB(173, 158, 158, 158),
          ),
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
                    return Text(
                      _output,
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
          _buildRow('7','8','9','×'),
          _buildRow('4','5','6','-'),
          _buildRow('1','2','3','+'),
          _buildRow('AC','0','.','='),
        ],
      ),

      //Side Panel
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'History',
                style: TextStyle(
                  color: Colors.white,
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
                    for(int i = 0; i < _output.length; i ++) {
                        if (_output[i] == ')') {
                          closeBrackets ++;
                        } else if (_output[i] == '(') {
                          openBrackets ++;
                        }
                    }
                  });
                  _closeSidePanel();  //Close panel
                },
                child: ListTile(
                  title: Text(
                    expression,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
          ],
        ),
      ),

    );
  }

  
  //Function to return a row with 4 specific elements
  Widget _buildRow(String text1,String text2,String text3,String text4 )
  {
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
    return Container(
      margin: EdgeInsets.only(bottom: 20.0), // Add margin bottom of 10 pixels
      child: RawMaterialButton(
        onPressed: () {
          _handleButtonPressed(text);
        },
        elevation: 2.0,
        fillColor: Color.fromARGB(255, 8, 157, 176),
        padding: EdgeInsets.all(20.0),
        shape: CircleBorder(),
        child: Text(
          text,
          style: TextStyle(
            color: text == 'C' || text == 'AC' ? const Color.fromARGB(255, 245, 28, 13) : Colors.black,
            fontSize: 30,
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
            openBrackets+=1;
            _output += '(';
        }else{
            //Non empty input. Compare current brackets
            //Check last digit. If number or non
            if(isNumber(_output.substring(_output.length - 1)))
            { 
                // If digit is number then
                //Check if amount of '(' is equal to ')'. 
                //If first time add openBracket
                if(openBrackets == 0 || openBrackets == closeBrackets)
                { 
                  openBrackets += 1;
                  _output += '×(';
                }else{
                  closeBrackets+=1;
                  _output += ')';
                }
            }else{
              //if no number then if last digit is ')' and non euqal amount of bracketsadd add clossing
              if(_output.substring(_output.length - 1) == ')' && openBrackets != closeBrackets)
              {
                  closeBrackets+=1;
                  _output += ')';
              }
              else
              {
                //if last is ')' then add 'x('
                if(_output.substring(_output.length - 1) == ')')
                {
                  _output += '×';
                }
                _output += '(';
                openBrackets+=1;
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
        if( _output.isNotEmpty)
        {
            if( _output.substring(_output.length - 1) == '(')
            {
              openBrackets --;
            } else if( _output.substring(_output.length - 1) == ')')
            {
              closeBrackets --;
            }
          _output = _output.substring(0, _output.length - 1);
        }
        
      } else {
        //Reset output after showing previous result
        if( reset )
        {
          reset = false;
          openBrackets = 0;
          closeBrackets = 0;
          //Keep previous result
          if( isNumber(text))
          {
            _output = '';
          }
        }
        if( isOperator(text))
        {
            //Cannot start with operator or have two operators side by side 
            if( _output.isEmpty || (_output.isNotEmpty && isOperator(_output.substring(_output.length - 1))))
            {
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
      if( _output =='')
      {
        return '';
      }
      print("Fixed _output is: $_output");

      //Fix missing brackets on end
      while(openBrackets > closeBrackets)
      {
        _output += ')';
        closeBrackets++;
      }
      String expression = _output.replaceAll('÷', '/').replaceAll('×', '*').replaceAll('%', '/100');

      //Display last 3 history expressions
      _expression_history.add(_output);
      _total_expression_history.add(_output);
      if( _expression_history.length > 3)
      {
        _history = _expression_history.sublist(_expression_history.length-3).take(3).join('\n');
      }
      else
      {
        _history = _expression_history.take(3).join('\n');
      }

      //Parse expression
      Parser p = Parser();
      Expression exp = p.parse(expression);
      ContextModel cm = ContextModel();
      double result = exp.evaluate(EvaluationType.REAL, cm);
      //print("Result: $result");
      reset = true;
      return (result.truncate() == result ? result.truncate() : result).toString();
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




}
