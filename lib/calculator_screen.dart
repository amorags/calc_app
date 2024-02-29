
import 'package:flutter/material.dart';

import 'button_values.dart';

abstract class Command {
  apply(List<num> stack);

}
abstract class Calculator {

  push(num value);
  execute(Command command);
}


class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
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
    num result = operand1 - operand2; // Rækkefølge !!
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
    num result = dividend / divisor; // Rækkefølge
    stack.add(result);
  }

}

class PushCommand implements Command {
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
    num result = dividend / divisor; // Rækkefølge
    stack.add(result);

  }

}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String number1 = ""; // . 0-9
  String operand = ""; // + - * /
  String number2 = ""; // . 0-9

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
                    "$number1$operand$number2".isEmpty
                        ? "0"
                        : "$number1$operand$number2",
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

  Widget buildButton(value) {
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

  // ########
  void onBtnTap(String value) {
    if (value == Btn.del) {
      delete();
      return;
    }

    if (value == Btn.clr) {
      clearAll();
      return;
    }

    if (value == Btn.calculate) {
      calculate();
      return;
    }

    appendValue(value);
  }

  // ##############
  // calculates the result
  void calculate() {

  }

  // clears all output
  void clearAll() {
    setState(() {
      number1 = "";
      operand = "";
      number2 = "";
    });
  }

  // delete one from the end
  void delete() {
    if (number2.isNotEmpty) {
      // 12323 => 1232
      number2 = number2.substring(0, number2.length - 1);
    } else if (operand.isNotEmpty) {
      operand = "";
    } else if (number1.isNotEmpty) {
      number1 = number1.substring(0, number1.length - 1);
    }

    setState(() {});
  }

  // #############
  // appends value to the end
  void appendValue(String value) {
    // number1 opernad number2
    // 234       +      5343

    // if is operand and not "."
    if (value != Btn.dot && int.tryParse(value) == null) {
      // operand pressed
      if (operand.isNotEmpty && number2.isNotEmpty) {
        // TODO calculate the equation before assigning new operand
        calculate();
      }
      operand = value;
    }
    // assign value to number1 variable
    else if (number1.isEmpty || operand.isEmpty) {
      // check if value is "." | ex: number1 = "1.2"
      if (value == Btn.dot && number1.contains(Btn.dot)) return;
      if (value == Btn.dot && (number1.isEmpty || number1 == Btn.n0)) {
        // ex: number1 = "" | "0"
        value = "0.";
      }
      number1 += value;
    }
    // assign value to number2 variable
    else if (number2.isEmpty || operand.isNotEmpty) {
      // check if value is "." | ex: number1 = "1.2"
      if (value == Btn.dot && number2.contains(Btn.dot)) return;
      if (value == Btn.dot && (number2.isEmpty || number2 == Btn.n0)) {
        // number1 = "" | "0"
        value = "0.";
      }
      number2 += value;
    }

    setState(() {});
  }

  // ########
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