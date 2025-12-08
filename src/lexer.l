%{
#include "Parser.hpp"

using namespace lisp_for_kids;
void set_input_file(yyscan_t scanner, const char* filename);

static int current_line = 1;
static int current_column = 1;

%}

%option reentrant batch noyywrap yylineno nodefault outfile="Scanner.cpp" header="Scanner.hpp"

%{
#define YY_USER_ACTION \
    do { \
        if (yylloc) { \
            yylloc->begin.line = yylloc->end.line = current_line; \
            yylloc->begin.column = current_column; \
            yylloc->end.column = current_column + yyleng - 1; \
        } \
        current_column += yyleng; \
    } while (0);
%}

%%

;.*        { /* ignore comment */ }

"("        { return Parser::token::T_PARENTHESIS_OPEN; }
")"        { return Parser::token::T_PARENTHESIS_CLOSE; }

"+"        { return Parser::token::T_PLUS; }
"-"        { return Parser::token::T_MINUS; }
"*"        { return Parser::token::T_MUL; }
"/"        { return Parser::token::T_DIV; }

[0-9]+("."[0-9]+)? { yylval->emplace<float>(atof(yytext)); return Parser::token::T_LITERAL_FLOAT; }

\n         { current_line++; current_column = 1; }
\r         { current_column = 1; }
[ \t]+     {}

<<EOF>>    { return Parser::token::T_END_OF_FILE; }
.          { return yytext[0]; }

%%

void set_input_file(yyscan_t scanner, const char* filename) {
    FILE* file = fopen(filename, "r");
    if (file) {
        yyset_in(file, scanner);
    } else {
        std::cerr << "Cannot open file: " << filename << std::endl;
        exit(1);
    }
}

float analize(char* arg) {
    yyscan_t scanner;
    yylex_init(&scanner);
    
    set_input_file(scanner, arg);
    
    float result;
    lisp_for_kids::Parser parser{ scanner, result };
    if (parser.parse() == 0) {
        std::cout << "Parse success.\n";
    }
    else {
        std::cerr << "Parse error!\n";
    }
    
    yylex_destroy(scanner);

    return result;
}