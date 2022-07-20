grammar Project;

start: require* class+;

//************************************************** Parser rules ******************************************************//

// library (require) define //
require: ValidName (',' ValidName)* '=' (require1 | require2 | require3) (',' (require1 | require2 | require3))* SEMICOLON;
require1: REQUIRE ValidName;
require2: FROM ValidName REQUIRE ValidName;
require3: FROM ValidName '=>' ValidName;


// class define //
class: CLASS ValidName extends? implements? BEGIN class_body END;
extends: '(' ValidName ')';
implements: IMPLEMENTS ValidName (',' ValidName)*;
class_body: (constructor | function | variable_def | class_instantiation)*;
constructor: LevelAccess? ValidName '(' function_parameters? ')' block;
class_instantiation: LevelAccess? CONST? ValidName ValidName ('=' (NULL | (ValidName '(' class_parameters? ')')))? SEMICOLON;
class_parameters: expression (',' expression)*;


// varible define //
variable_def: LevelAccess? CONST? datatype ValidName (variable | array) SEMICOLON;
variable: ('=' expression)? (',' ValidName ('=' expression)?)*;
array: '[]' '=' (array_def1 | array_def2);
array_def1:'new' datatype '[' expression ']';
array_def2: '[' expression (',' expression)* ']';


// loop define //
for_statement: (for1 | for2) block;
for1: FOR '(' datatype? initialization SEMICOLON expression (SEMICOLON expression)? ')';
for2: FOR ValidName IN ValidName;
initialization: ValidName '=' expression;
while_statement: WHILE '(' expression ')' block;
dowhile_statement: DO block WHILE '(' expression ')' SEMICOLON;


// if_statement define //
if_statement: if elif* else?;
if: IF '(' expression ')' block;
elif: ELIF '(' expression ')' block;
else: ELSE block;


// ternary expression define //
ternary: '(' expression '?' expression ':' expression ')';


// switch/case define //
switch_case: SWITCH expression BEGIN (CASE expression ':' line* (BREAK SEMICOLON)?)+ (DEFAULT ':' line+ (BREAK SEMICOLON)?)? END;


// function define //
function: LevelAccess? (datatype | 'void') ValidName '(' function_parameters? ')' block;
functionCall: ValidName ('.' ValidName)? '(' ( (expression | ValidName ('.' ValidName)?) (',' expression | ValidName ('.' ValidName)?)* )? ')' SEMICOLON?;
function_parameters: datatype ValidName ('=' expression)? (',' datatype ValidName ('=' expression)?)*;


// exception define //
exception: TRY block CATCH '(' ValidName (',' ValidName)* ')' block;


// other statements //
print_statement: 'print' '(' (expression (',' expression)*)? ')' SEMICOLON;
this_statement: THIS '.' ValidName (('=' | Assignment) expression)? SEMICOLON?; // this.age = 2 ,,, print(this.name);
return_statement: RETURN expression SEMICOLON;
variableCall: ValidName '.' ValidName (ValidName '.')*; // car1.speed
array_element: ValidName '[' expression ']' ('.' expression)?; // array1[2].name

line: return_statement | this_statement | class_instantiation | variable_def | for_statement | while_statement | dowhile_statement | if_statement | switch_case | exception | function | functionCall | print_statement | expression SEMICOLON;
block: BEGIN line* END;
datatype: INT | FLOAT | DOUBLE | BOOL | CHAR | STRING;
value: Boolean | String | Int | Float | Double | Char | SCIENTIFIC | NULL;

expression:

            '(' expression ')'                            #parenthesisExpression
            | expression '**' expression                  #powerExpression
            | '~' expression                              #notExpression
            | PosNeg expression                           #unary1Expression
            | expression UNARY                            #unary21Expression
            | UNARY expression                            #unary22Expression
            | expression ARITHMETIC expression            #arithmetic1Expression
            | expression PosNeg expression                #arithmetic2Expression
            | expression BITWISE1 expression              #bitwise1Expression
            | expression BITWISE2 expression              #bitwise2Expression
            | expression COMPARE1 expression              #compare1Expression
            | expression COMPARE2 expression              #compare2Expression
            | LOGICAL1 expression                         #logical1Expression
            | expression LOGICAL2 expression              #logical2Expression
            | expression ('=' | Assignment) expression    #assignmentExpression
            | ternary                                     #ternaryExpression
            | functionCall                                #functionCallExpression
            | variableCall                                #variableCallExpression
            | array_element                               #array_elementExpression
            | this_statement                              #this_statementExpression
            | value                                       #valueExpression
            | ValidName                                   #identifierExpression
            ;

//************************************************** Lexer rules *******************************************************//

// fragments //
fragment LETTER: [a-zA-Z];
fragment DIGIT: [0-9];

// lexers for keywords
REQUIRE: 'require';
LevelAccess: 'public' | 'private';
FROM: 'from';
CONST: 'const';
STRING: 'string';
INT: 'int';
FLOAT: 'float';
BOOL: 'bool';
CHAR: 'char';
DOUBLE: 'double';
NULL: 'Null';
Boolean: 'true' |  'false';
CLASS: 'class';
IMPLEMENTS: 'implements';
BEGIN: 'begin';
END: 'end';
THIS: 'this';
RETURN: 'return';
FOR: 'for';
IN: 'in';
WHILE: 'while';
DO: 'do';
IF: 'if';
ELIF: 'else if';
ELSE: 'else';
SWITCH: 'switch';
CASE: 'case';
BREAK: 'break';
DEFAULT: 'default';
TRY: 'try';
CATCH: 'catch';

// lexers for expressions
PosNeg: '+' | '-';
UNARY: '++' | '--';
ARITHMETIC: '*'| '/' | '//' | '%';
BITWISE1: '<<' | '>>';
BITWISE2: '&' | '^' | '|';
COMPARE1: '==' | '!=' | '<>';
COMPARE2: '>=' | '<=' | '>' | '<';
LOGICAL1: 'not' | '!';
LOGICAL2: 'and' | 'or' | '||' | '&&';
Assignment: '+=' | '-=' | '*=' | '//=' | '/=' |'%=' | '&=' | '|=' | '^=' | '>>=' | '<<=';

// lexers for values
Int : PosNeg? (DIGIT | ([1-9]DIGIT+));
Float: PosNeg? (DIGIT* '.' DIGIT+);
Double: PosNeg? (DIGIT* '.' DIGIT+);
Char: '\'' LETTER '\'';
String: '"' .*? '"';
SCIENTIFIC: DIGIT+|(DIGIT('.'DIGIT+)?'e'('-'|'+')? Int);

SEMICOLON: ';';
ValidName: (LETTER | '$') (LETTER | DIGIT | '$' | '_')+;

BlockComment: '/*' .*? '*/' -> skip;
SingleLineComment: '#' ~[\r\n]* -> skip;

WhiteSpace: [ \t\r\n]+ -> skip;