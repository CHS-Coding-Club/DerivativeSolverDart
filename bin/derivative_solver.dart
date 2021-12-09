import 'dart:io';

void main() {
  Expression.fromInput();
}

class Expression {
  static Expression fromInput() {
    print("Please enter an equation to derive");
    while (true) {
      var tokens = Token.fromString(stdin.readLineSync() ?? "");
      print(tokens);
      return Expression();
    }
  }
}

class Token {
  TokenType type;
  dynamic value;
  Token(this.type, this.value);
  bool couldImplicitlyBeLeftOperator() {
    return type == TokenType.number ||
        type == TokenType.variable ||
        type == TokenType.rightParenthesis;
  }
  bool couldImplicitlyBeRightOperator() {
    return type == TokenType.number ||
        type == TokenType.variable ||
        type == TokenType.leftParenthesis;
  }
  static List<Token> fromString(String s) {
    var tokens = <Token>[];
    for (int i=0; i<s.length; i++) {
      var c = s[i];
      if (c == '+') {
        tokens.add(Token(TokenType.plus, c));
      } else if (c == '-') {
        tokens.add(Token(TokenType.minus, c));
      } else if (c == '*') {
        tokens.add(Token(TokenType.times, c));
      } else if (c == '/') {
        tokens.add(Token(TokenType.divide, c));
      } else if (c == '^') {
        tokens.add(Token(TokenType.power, c));
      } else if (c == '(') {
        tokens.add(Token(TokenType.leftParenthesis, c));
      } else if (c == ')') {
        tokens.add(Token(TokenType.rightParenthesis, c));
      } else if (c == '=') {
        tokens.add(Token(TokenType.equals, c));
      } else if (c == ' ') {
        // ignore
      } else if (isNumeric(c)) {
        // don't just add that character, but the entire number
        // find end of num
        int j = i;
        while (j < s.length && isNumeric(s[j])) {
          j++;
        }
        tokens.add(Token(TokenType.number, int.parse(s.substring(i, j))));
        i=j-1;
      } else if (isAlpha(c)) {
        tokens.add(Token(TokenType.variable, c));
      } else {
        tokens.add(Token(TokenType.unknown, c));
      }
    }
    // now we need to check for implicit multiplication and add the multiplication tokens
    // (think 10x implies multiplication, so a num or variable both could implicitly be an operator)
    // we need to diffrentiate between left and right operators because
    // (1 does not imply (*1, but 1( does imply 1*(
    for (int i=0; i<tokens.length; ++i) {
      if (tokens[i].couldImplicitlyBeRightOperator()) {
        if (i > 0 && tokens[i-1].couldImplicitlyBeLeftOperator()) {
          tokens.insert(i, Token(TokenType.times, '*'));
        }
      }
    }
    return tokens;
  }
  @override
  String toString() {
    return "{type: $type, value: $value}";
  }
}

enum TokenType {
  number,
  variable,
  leftParenthesis,
  rightParenthesis,
  equals,
  plus,
  minus,
  times,
  divide,
  power,
  unknown
}

bool isNumeric(String? s) {
  if (s == null) {return false;}
  return s.codeUnitAt(0) >= 48 && s.codeUnitAt(0) <= 57;
}

bool isAlpha(String? s) {
  if (s == null) {return false;}
  // return true if it's a letter
  return (s.codeUnitAt(0) >= 65 && s.codeUnitAt(0) <= 90) ||
      (s.codeUnitAt(0) >= 97 && s.codeUnitAt(0) <= 122);
}
