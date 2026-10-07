import 'dart:math' as math;

import 'package:flutter/material.dart';

void main() => runApp(const CalculatorStudioApp());

class CalculatorStudioApp extends StatelessWidget {
  const CalculatorStudioApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Calculator Studio',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF295CFF)),
      useMaterial3: true,
    ),
    home: const CalculatorPage(),
  );
}

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String _display = '0';
  double? _storedValue;
  String? _pendingOperator;
  bool _replaceDisplay = false;
  String? _message;
  final List<Calculation> _history = [];

  void _enterDigit(String digit) {
    setState(() {
      if (_message != null) _message = null;
      if (_replaceDisplay || _display == '0') {
        _display = digit;
        _replaceDisplay = false;
      } else if (_display.length < 16) {
        _display += digit;
      }
    });
  }

  void _enterDecimal() {
    setState(() {
      if (_message != null) _message = null;
      if (_replaceDisplay) {
        _display = '0.';
        _replaceDisplay = false;
      } else if (!_display.contains('.')) {
        _display += '.';
      }
    });
  }

  void _chooseOperator(String operator) {
    final current = double.tryParse(_display);
    if (current == null) return _showError('Enter a valid number first.');
    setState(() {
      if (_pendingOperator != null &&
          _storedValue != null &&
          !_replaceDisplay) {
        final result = CalculatorEngine.apply(
          _storedValue!,
          current,
          _pendingOperator!,
        );
        if (result == null) {
          _display = '0';
          _storedValue = null;
          _pendingOperator = null;
          _replaceDisplay = true;
          _message = 'Cannot divide by zero.';
          return;
        }
        _record(_storedValue!, _pendingOperator!, current, result);
        _storedValue = result;
        _display = CalculatorEngine.format(result);
      } else {
        _storedValue = current;
      }
      _pendingOperator = operator;
      _replaceDisplay = true;
      _message = 'Running total: ${CalculatorEngine.format(_storedValue!)}';
    });
  }

  void _equals() {
    if (_storedValue == null || _pendingOperator == null || _replaceDisplay) {
      _showError('Choose an operator and a second number.');
      return;
    }
    final second = double.tryParse(_display);
    if (second == null) return _showError('Enter a valid second number.');
    final result = CalculatorEngine.apply(
      _storedValue!,
      second,
      _pendingOperator!,
    );
    if (result == null) return _resetWithError('Cannot divide by zero.');
    if (!result.isFinite || result.abs() > 999999999999999) {
      return _resetWithError('Result is too large. Tap AC to start again.');
    }
    setState(() {
      _record(_storedValue!, _pendingOperator!, second, result);
      _display = CalculatorEngine.format(result);
      _storedValue = null;
      _pendingOperator = null;
      _replaceDisplay = true;
      _message = 'Result calculated.';
    });
  }

  void _record(double first, String operator, double second, double result) {
    _history.insert(0, Calculation(first, operator, second, result));
  }

  void _backspace() {
    setState(() {
      if (_message != null) _message = null;
      if (_replaceDisplay ||
          _display.length <= 1 ||
          (_display.length == 2 && _display.startsWith('-'))) {
        _display = '0';
        _replaceDisplay = false;
      } else {
        _display = _display.substring(0, _display.length - 1);
      }
    });
  }

  void _clearAll() => setState(() {
    _display = '0';
    _storedValue = null;
    _pendingOperator = null;
    _replaceDisplay = false;
    _message = null;
  });

  void _clearHistory() => setState(_history.clear);

  void _reuseResult(Calculation item) => setState(() {
    _display = CalculatorEngine.format(item.result);
    _storedValue = null;
    _pendingOperator = null;
    _replaceDisplay = true;
    _message = 'Reused ${CalculatorEngine.format(item.result)} from history.';
  });

  void _showError(String text) => setState(() => _message = text);

  void _resetWithError(String text) => setState(() {
    _display = '0';
    _storedValue = null;
    _pendingOperator = null;
    _replaceDisplay = true;
    _message = text;
  });

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Calculator Studio'),
      centerTitle: true,
      actions: [
        IconButton(
          tooltip: 'Clear calculation history',
          onPressed: _history.isEmpty ? null : _clearHistory,
          icon: const Icon(Icons.delete_sweep_outlined),
        ),
      ],
    ),
    body: SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) => constraints.maxWidth > 650
            ? Row(
                children: [
                  Expanded(flex: 3, child: _calculator()),
                  _historyPanel(),
                ],
              )
            : Column(
                children: [
                  Expanded(child: _calculator()),
                  _historyPanel(height: 180),
                ],
              ),
      ),
    ),
  );

  Widget _calculator() => Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          liveRegion: true,
          label: 'Calculator display: $_display',
          child: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _display,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.displaySmall,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Semantics(
          liveRegion: true,
          child: Text(
            _message ?? 'Ready',
            textAlign: TextAlign.right,
            style: TextStyle(
              color:
                  _message?.contains('Cannot') == true ||
                      _message?.contains('too large') == true
                  ? Theme.of(context).colorScheme.error
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: GridView.count(
            crossAxisCount: 4,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1.18,
            children: [
              _key('AC', _clearAll, semantic: 'All clear'),
              _key('⌫', _backspace, semantic: 'Delete last digit'),
              _key('÷', () => _chooseOperator('÷'), operator: true),
              _key('×', () => _chooseOperator('×'), operator: true),
              for (final digit in ['7', '8', '9'])
                _key(digit, () => _enterDigit(digit)),
              _key('−', () => _chooseOperator('−'), operator: true),
              for (final digit in ['4', '5', '6'])
                _key(digit, () => _enterDigit(digit)),
              _key('+', () => _chooseOperator('+'), operator: true),
              for (final digit in ['1', '2', '3'])
                _key(digit, () => _enterDigit(digit)),
              _key('=', _equals, operator: true),
              _key('0', () => _enterDigit('0')),
              _key('.', _enterDecimal, semantic: 'Decimal point'),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _key(
    String label,
    VoidCallback onTap, {
    bool operator = false,
    String? semantic,
  }) => Semantics(
    button: true,
    label: semantic ?? label,
    child: FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: operator
            ? Theme.of(context).colorScheme.primary
            : null,
        foregroundColor: operator
            ? Theme.of(context).colorScheme.onPrimary
            : null,
        textStyle: Theme.of(context).textTheme.titleLarge,
      ),
      onPressed: onTap,
      child: Text(label),
    ),
  );

  Widget _historyPanel({double? height}) => SizedBox(
    width: 280,
    height: height,
    child: Card(
      margin: const EdgeInsets.fromLTRB(8, 8, 16, 16),
      child: Column(
        children: [
          const ListTile(title: Text('Calculation history'), dense: true),
          Expanded(
            child: _history.isEmpty
                ? const Center(
                    child: Text('Completed calculations appear here.'),
                  )
                : ListView.builder(
                    itemCount: _history.length,
                    itemBuilder: (context, index) {
                      final item = _history[index];
                      return ListTile(
                        dense: true,
                        title: Text(item.expression),
                        trailing: Text(CalculatorEngine.format(item.result)),
                        onTap: () => _reuseResult(item),
                      );
                    },
                  ),
          ),
        ],
      ),
    ),
  );
}

class CalculatorEngine {
  static double? apply(double first, double second, String operator) =>
      switch (operator) {
        '+' => first + second,
        '−' => first - second,
        '×' => first * second,
        '÷' when second != 0 => first / second,
        _ => null,
      };

  static String format(double value) {
    if (value == value.roundToDouble()) return value.toInt().toString();
    final rounded = value.toStringAsPrecision(
      math.min(12, value.abs() >= 1 ? 12 : 8),
    );
    return double.parse(rounded).toString();
  }
}

class Calculation {
  const Calculation(this.first, this.operator, this.second, this.result);
  final double first;
  final String operator;
  final double second;
  final double result;

  String get expression =>
      '${CalculatorEngine.format(first)} $operator ${CalculatorEngine.format(second)}';
}
