%{
#include "Scanner.hpp"
%}

%require "3.7.4"
%language "C++"
%defines "Parser.hpp"
%output "Parser.cpp"

%define api.parser.class {Parser}
%define api.namespace {lisp_for_kids}
%define api.value.type variant
%param {yyscan_t scanner}
%parse-param {float& result}

%locations

%code provides
{
    #define YY_DECL \
        int yylex(lisp_for_kids::Parser::semantic_type *yylval, \
                lisp_for_kids::Parser::location_type* yylloc, \
                yyscan_t yyscanner)
    YY_DECL;
}

%token <float> T_LITERAL_FLOAT
%left T_PLUS T_MINUS // low priority
%left T_MUL T_DIV // medium priority
%right UMINUS // high priority
%token T_PARENTHESIS_OPEN
%token T_PARENTHESIS_CLOSE
%token T_END_OF_FILE

%type <float> s expr num

%%

s: expr T_END_OF_FILE {
    result = $1;
    YYACCEPT;
};

expr: num { $$ = $1; }
    | expr T_PLUS expr { $$ = $1 + $3; }
    | expr T_MINUS expr { $$ = $1 - $3; }
    | expr T_MUL expr { $$ = $1 * $3; }
    | expr T_DIV expr { $$ = $1 / $3; }
    | T_MINUS expr %prec UMINUS { $$ = -$2; }
    | T_PARENTHESIS_OPEN expr T_PARENTHESIS_CLOSE { $$ = $2; };

num: T_LITERAL_FLOAT { $$ = $1; };

%%

void lisp_for_kids::Parser::error(const location_type& loc, const std::string& msg) {
    const char* text = yyget_text(scanner);
    int length = yyget_leng(scanner);
    
    std::cerr << msg << " at (Line: " << loc.begin.line << ", Column: " << loc.begin.column
            << ", Last token: '" << std::string(text, length) << "')\n";
}