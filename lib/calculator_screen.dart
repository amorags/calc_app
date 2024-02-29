import 'package:flutter/material.dart';
import 'button_values.dart';

abstract class Command {
  void apply(List<num> stack);
}

class AddCommand implements Command {
  @override
  void apply(List<num> stack) {
    if (stack.length < 2) {
      throw Exception("Insufficient operands for addition");
    }
    num operand2 = stack.removeLast();
    num operand1 = stack.removeLast();
    num result = operand1 + operand2;
    stack.add(result);
  }
}

class SubCommand implements Command {
  @override
  void apply(List<num> stack) {
    if (stack.length < 2) {
      throw Exception("Insufficient operands for subtraction");
    }
    num operand2 = stack.removeLast();
    num operand1 = stack.removeLast();
    num result = operand1 - operand2;
    stack.add(result);
  }
}

class MultiCommand implements Command {
  @override
  void apply(List<num> stack) {
    if (stack.length < 2) {
      throw Exception("Insufficient operands for multiplication");
    }
    num operand2 = stack.removeLast();
    num operand1 = stack.removeLast();
    num result = operand1 * operand2;
    stack.add(result);
  }
}

class DivideCommand implements Command {
  @override
  void apply(List<num> stack) {
    if (stack.length < 2) {
      throw Exception("Insufficient operands for division");
    }
    num divisor = stack.removeLast();
    num dividend = stack.removeLast();
    if (divisor == 0) {
      throw Exception("Division by zero error");
    }
    num result = dividend / divisor;
    stack.add(result);
  }
}

class Calculator {
  List<num> stack = [];

  void push(num value) {
    stack.add(value);
  }

  void execute(Command command) {
    command.apply(stack);
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({Key? key}) : super(key: key);

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final Calculator calculator = Calculator();
  String displayValue = "0";

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // output
            Expanded(
              child: SingleChildScrollView(
                reverse: true,
                child: Container(
                  alignment: Alignment.bottomRight,
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    displayValue,
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
              ),
            ),

            // buttons
            Wrap(
              children: Btn.buttonValues
                  .map(
                    (value) => SizedBox(
                  width: value == Btn.n0
                      ? screenSize.width / 2
                      : (screenSize.width / 4),
                  height: screenSize.width / 5,
                  child: buildButton(value),
                ),
              )
                  .toList(),
            )
          ],
        ),
      ),
    );
  }

  Widget buildButton(String value) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Material(
        color: getBtnColor(value),
        clipBehavior: Clip.hardEdge,
        shape: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Colors.white24,
          ),
          borderRadius: BorderRadius.circular(100),
        ),
        child: InkWell(
          onTap: () => onBtnTap(value),
          child: Center(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void onBtnTap(String value) {
    if (value == Btn.del) {
      delete();
    } else if (value == Btn.clr) {
      clearAll();
    } else if (value == Btn.calculate) {
      calculate();
    } else if (value == Btn.add) {
      calculator.execute(AddCommand());
      updateDisplay(calculator.stack.last);
    } else if (value == Btn.subtract) {
      calculator.execute(SubCommand());
      updateDisplay(calculator.stack.last);
    } else if (value == Btn.multiply) {
      calculator.execute(MultiCommand());
      updateDisplay(calculator.stack.last);
    } else if (value == Btn.divide) {
      calculator.execute(DivideCommand());
      updateDisplay(calculator.stack.last);
    } else {
      appendValue(value);
    }
  }

  void calculate() {
    calculator.push(double.parse(displayValue));
    displayValue = "0";
  }

  void clearAll() {
    setState(() {
      calculator.stack.clear();
      displayValue = "0";
    });
  }

  void delete() {
    setState(() {
      if (displayValue.length > 1) {
        displayValue = displayValue.substring(0, displayValue.length - 1);
      } else {
        displayValue = "0";
      }
    });
  }

  void appendValue(String value) {
    setState(() {
      if (displayValue == "0") {
        displayValue = value;
      } else {
        displayValue += value;
      }
    });
  }

  void updateDisplay(num value) {
    setState(() {
      displayValue = value.toString();
    });
  }

  Color getBtnColor(value) {
    return [Btn.del, Btn.clr, Btn.calculate].contains(value)
        ? Colors.deepOrangeAccent
        : [
      Btn.multiply,
      Btn.add,
      Btn.subtract,
      Btn.divide
    ].contains(value)
        ? Colors.white12
        : Colors.blueGrey;
  }
}

