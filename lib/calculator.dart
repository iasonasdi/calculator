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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simple Calculator'),
      ),
      body: Column(
        children: [          
          Expanded(
              child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 50),
              child: Container(
                alignment: Alignment.bottomRight,
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  //_history,
                   _history.split('\n').reversed.take(4).toList().reversed.join('\n'),
                  style: const TextStyle(
                    fontSize: 28.0,
                    fontWeight: FontWeight.normal,
                  ),
                  textAlign: TextAlign.right,
                  maxLines: 4, 
                  overflow: TextOverflow.ellipsis, 
                ),
              ),
            ),
          ),
          Expanded(
              child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 100),
              child: Container(
                alignment: Alignment.bottomRight,
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  _output,
                  style: const TextStyle(
                    fontSize: 48.0,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1, // Limit text to 1 line
                  overflow: TextOverflow.ellipsis, // Show ellipsis if text overflows
                ),
              ),
            ),
          ),          
          //Devider for output and Buttons
          const Divider(
            height: 1, 
            color: Color.fromARGB(173, 158, 158, 158),
          ),
          const SizedBox(height: 10), // Add space here
          //Buttons
          _buildRow('C','()','%','÷'),
          _buildRow('7','8','9','×'),
          _buildRow('4','5','6','-'),
          _buildRow('1','2','3','+'),
          _buildRow('AC','0','.','='),
        ],
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

  String _calculateResult() {
    try {
      String expression = _output.replaceAll('÷', '/').replaceAll('×', '*').replaceAll('%', '/100');
      print("Expression is: $expression");
      //Check if Empty
      if( expression =='')
      {
        return '';
      }
      //Display last 3 history expressions
      _expression_history.add(_output);
      if( _expression_history.length > 4)
      {
        _history = _expression_history.sublist(_expression_history.length-4).take(4).join('\n');
      }
      else
      {
        _history = _expression_history.take(4).join('\n');
      }

      //Parse expression
      Parser p = Parser();
      Expression exp = p.parse(expression);
      ContextModel cm = ContextModel();
      double result = exp.evaluate(EvaluationType.REAL, cm);
      print("Result: $result");
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


}
