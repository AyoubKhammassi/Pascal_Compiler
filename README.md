# Simple Pascal Compiler

A basic compiler for the **Pascal** programming language made using Flex and Bison Yacc.

## Lexical Phase
implemented in the file **src/parser.lex**. Responsible of parsing the source files and returning different tokens. 

### Tokens:

* **Identifiers:** Represent variables and functions names. They must start by a letter and can contain any string of alphanumeric characters.

* **Numbers:** Represent number literals. Only digits combinations are allowed.

* **Keywords:** The different keywords reserved by the language. The list is (*program, var, function, begin, end, integer, real, if, then, else, while, return*)

* **Single character operators:** The operators that are represented by a single character: (*-, +, \*, <, >, \(, \), [, ]*). These are not represented by a token but they're sent as is (char) from the lexer to the next phase.

* **Double character operators:** The operators that are represented by a two characters: (*--, ++, \*=, +=, -=, <=, >=, ||, &&*).

### Errors:

The compiler terminates whenever a lexical error occurs, and that's to avoid the propagation of the errors to the next phase.

The list of errors is as follow:

* **Identifier error:** Identifiers that start with a digit are not allowed.

* **Unexpected end of comment:** When the lexer parses an end of comment token *) while there's no open comment that needs to be closed.

* **Open comment:** The lexer reaches the end of file token EOF but a comment is still not closed.

* **Unexpected character:** When the lexer parses something that doesn't match any of the above tokens.

**NB:** The used tokens are not defined in the **parser.lex** file, but they're defined in the yacc file **parser.y**, which when built generates the header file that contains the definitions for all the tokens. That header is then included in the lex file.

## Syntactic Phase
Implemented in the yacc file **src/parser.y**. The tokens coming from the lexer are consumed here while it's asserted that they match the grammar of the language.

### Rules:

* **prog:** The start rule of the grammer. Represents the programs as a whole from start to end.

* **functions:** A recursive rule to support multiple function definitions.

* **function:** A rule to represent the structure of a single function and how to define it.

* **paramdecls:** A recursive rule used in the function rule to represent multiple paramter declarations.

* **paramdecl:** Single function paramter declaration.

* **type:** A simple rule used to declare the type of a variable, parameter, or a function return type.

* **var_defs:** Used to represent the structure of the variable declarations section.

* **rec_var_defs:** Recursive rule used to support multiple variable declarations with different types.

* **stmnt:** Representation of different statements, like the if then else, while, return, a simple expression or an empty expression. Also used to close a compound statement (Compound statements contain multiple statements and they start with the **begin** keyword and end with the **end** keyword)


* **rec_stmnt:** Recurisve rule used in conjunction with the previous rule to represent compound statements. This rule is used to start one.

* **expr:** Recurisve rule that covers all possible cases for expressions with different operators.


### Errors:

A syntactic error is thrown whenever the compiler reaches something that doesn't match any of the above rules that define the grammar. Unfortunately bison doesn't allow for error handling in this case so all it does is that it prints syntactic error and the line number.


## Semantic Phase
implemented in the yacc file **src/parser.y** and the c++ header file **parser_utils.h**. The other header file **console.h** is just used to allow printing to the console with different colors. 

In this pahse, source that matches the grammar is further validated to conform to the Pacal programming language rules.

### Used data types:

* **Identifier_type:** An enumeration that the holds the different possible types for an identifier (*undefined, function, variable, paramter*)

* **Identifier:** A structure used to store the data of an identifier, including the name, the type, whether it's used or not, and most importantly a void pointer that can be used to point at any type of data. For the variables and paramters, it can be a pointer to an integer or a float, depending on their data type. In the case of functions, that pointer points to an instance of the next structure.

* **function_data:** Contains the name of the function,and how many variables/parameters are declared inside of it.

* **context:** This is the main type used by the compiler to store all data about the different symbols.
1. As a symbol table, the context has a **vector of maps** templated on **C style string** as the type of keys and **Identifier** as the type of values. This memeber is called **scopes** and just as it's named, it stores the identifiers of each scope in a different vector element. The global scope of the program is the first element of the vector and it's added as as soon as the start rule is matched. Whenever a new function is met, we add a new element to the vector to store the data of the newly created scope.
2. The **find_id(const char\*)** method is used to search all scopes for an identifier. It starts from last added scope (The current/local scope) and it iterates over the vector until it reaches the global scope. If one of the maps has a key entry that matches the name, then the identifier exists and we return a pointer to it. Otherwise we return a nullptr.
3. The **can_use(const char \*)** method is used to check if an identifier that appeared in an expression can be used or not. To do so, we check if it exists or not, if it does, we mark it as used. That way the compiler can know which of the declared variables/parameters is used and which is not.

###  Errors:
The semantic errors don't terminate the program, and that's in order to do a full semantic analysis of the source code and find all the errors.

* **Not declared error:** When an identifier appears in an expression but it's not found in any of the scopes.

* **Redefinition error:** When a variable or a paramter is declared with an identifier that already exists in one of the scopes.

###  Warnings:
* **Not used warning:** A variable/parameter is never used in the scope it was declared in (Or any of the scopes inside it). This is done whenever we close a scope by checking all identifers of type variable or parameter that are marked as unused.

###  Info:
Outputting data whenever we add a new identifier. At the end of the compilation, we list all the defined functions with their data.

## Code Generation
Work in progress.




# Build

## tools:
* win-flex
* win-bison
* gcc

In the command line, navigate to the src folder and run the **build.bat** script. You need the above tools to be included to your path in order for the build to succeed.

If you use different flex and bison tools, you'll need to compile each file separately. 
1. Start by compiling the **parser.y** file using your bison tool. Make sure to use **-d** option in order to generate the the **parser.tab.h** and not only the **parser.tab.c** file.
2. Compile the **parser.lex** file using your flex tool.

3. Compile both **parser.tab.c** and **lex.yy.c** using your C++ compiler. You can't use a C compiler because the **parser_utils.h** is a c++ header file. Also make sure to use the C++ 14 standard when you compile, because we're using features that aren't supported in the previous versions.

## Testing
To test the the compiler, you can either run the generated executable from the command line and use it as an interpreter, or you can pass a stream from a file using the **<** operator.

**example:** (*pasc.exe < example.txt*)


