// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ale_calculator/main.dart';

void main() {
  group('PushCommand', () {
    test('Pushes a value to the stack', () {
      final stack = [1, 2];
      PushCommand(3).apply(stack);
      expect(stack, [1, 2, 3]);
    });
  });

  group('AddCommand', () {
    test('Remove the top two numbers and push the result', () {
      final stack = [1, 2];
      AddCommand().apply(stack);
      expect(stack, [3]);
    });

    test('Nothing if there are less than two numbers', () {
      final stack = [1];
      final copy = [...stack];
      AddCommand().apply(stack);
      expect(stack, copy);
    });
  });
}

// Abstract Command class
abstract class Command {
  void apply(List<num> stack);
  void unapply(List<num> stack);
}

class PushCommand implements Command {
  final num value;

  PushCommand(this.value);

  @override
  void apply(List<num> stack) {
    stack.add(value);
  }

  @override
  void unapply(List<num> stack) {
    stack.removeLast();
  }
}

// Avoid duplicating logic for each operation
abstract class OperatorCommand implements Command {
  late num operand1;
  late num operand2;

  num operate(num operand1, num operand2);

  @override
  void apply(List<num> stack) {
    if (stack.length >= 2) {
      operand2 = stack.removeLast();
      operand1 = stack.removeLast();
      stack.add(operate(operand1, operand2));
    }
  }

  @override
  void unapply(List<num> stack) {
    stack.removeLast();
    stack.addAll([operand1, operand2]);
  }
}

class AddCommand extends OperatorCommand {
  @override
  num operate(num operand1, num operand2) => operand1 + operand2;
}
