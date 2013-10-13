%{
/*****************************************************************
This is a sample program for using lex to extract tokens and then
invoke a parser function and pass the token as a parameter to parse.
You will need to implement the parsing function (not using yacc)
to achieve parsing and parse tree building.
*****************************************************************/

#include <stdio.h>
#include <iostream>
#include <fstream>
#include <string.h>
#include <sstream>
#include <map>
#include <vector>
#include <cstdlib>
#include <stack>
#include <algorithm>
#include "defines.h"
using namespace std;

#define Debug 1
 
#define Lbracket 1
#define Rbracket 2
#define Loop 3
#define Print 4
#define Assign 5
#define Function 6
#define Number 7
#define Identifier 8
#define EndIn 9

int Token;
int lineNum = 1;

string valid_inputs[9] = {"{", "}", "l", "p", "=", "f", "n", "x", "$"};

std::map<int, string> goto_indices;
std::map<int, string> action_indices;
std::map<i_pair, int> goto_table;
std::map<i_pair, string> action_table;
std::stack<string> pile;
std::stack<Node*> nodes;
int current_state = 1;
void myparser ();
void error_input ();

int search(string a[], int length, string key) {
	for (int i = 0; i < length; i++) {
		if (a[i] == key) {
			return i;
		}
	}
	return -1;
}

int goto_search(string value) {
	std::map<int, string>::const_iterator it;
	int key = -1;
	for (it = goto_indices.begin(); it != goto_indices.end(); ++it) {
		if (it->second == value) {
			key = it->first;
			break;
		}
	}
	return key;
}

int action_search(string value) {
	std::map<int, string>::const_iterator it;
	int key = -1;
	for (it = action_indices.begin(); it != action_indices.end(); ++it) {
		if (it->second == value) {
			key = it->first;
			break;
		}
	}
	return key;
}

string bracket(string s){
	return "<" + s + ">";
}

Node* head;

%}

Integer 0|[1-9][0-9]*
Real {Integer}"."[0-9]+
NUM {Integer}|{Real}
ID [a-z]+

%%

"{"      { Token = Lbracket; myparser(); }
"}"      { Token = Rbracket; myparser(); }
loop     { Token = Loop; myparser(); }
pr    { Token = Print; myparser(); }
=        { Token = Assign; myparser(); }
"+"|"*"  { Token = Function; myparser(); }
"**"     { Token = Function; myparser(); }
{NUM}    { Token = Number; myparser(); }
{ID}     { Token = Identifier; myparser(); }
[ \t]*   {}
\n       { lineNum++; }
.        { error_input(); }

%%


void error_input () {
	printf ("illegitimate token: %s in line %d\n", yytext, lineNum);
	exit (-1);
}

bool IsDash(char c) {
	return c == '-';
}

void myparser () {
	char* token;
	switch (Token)
	{
	case Lbracket:
		token = "{";
		break;
	case Rbracket:
		token = "}";
		break;
	case Loop:
		token = "l";
		break;
	case Print:
		token = "p";
		break;
	case Assign:
		token = "=";
		break;
	case Function:
		token = "f";
		break;
	case Number:
		token = "n";
		break;
	case Identifier:
		token = "x";
		break;
	case EndIn:
		token = "$";
		break;
	default:
		printf("Parse Error\n");
		exit(-1);
	}

	// cout << bracket(token) << endl;
	//if (Debug) printf ("Token = %d, %s\n", Token, yytext);
	while (true) {
		
		istringstream iss(pile.top());
		iss >> current_state;

		i_pair temp;
		temp.state = current_state;
		temp.input = token;
		string rule = action_table[temp];
		// cout << "\t" << rule << endl;
		if (convertToLowerCase(rule) == "acc" || convertToLowerCase(rule) == "accept") {
			printf("Successful parse\n\n");
			head = nodes.top();
			break;
		} else {
			iss.clear();
			iss.str(rule);
			int state;
			iss >> state;
			
			if (iss) {
				if (state <= 0) {
					printf("Parse error!\n");
					exit(-1);
				}
				pile.push(convertInt(state));
				
				string one = "<";
				string two = "> ";
				string result = one + token + two + yytext;
			
				Node* tmp = createNode((char*)result.c_str());
				nodes.push(tmp);
				break;
			} else {
				string prod = rule.substr(0, rule.find("-"));
				Node* tmp = createNode((char*)prod.c_str());
				if (rule.size() > 2) {
					for (int i = 2; i < rule.size(); i++) {
						pile.pop();
						if (tmp->child) {
							Node* tmp2 = nodes.top();
							tmp2->right_sibling = tmp->child;
							tmp->child = tmp2;
						} else {
							tmp->child = nodes.top();
						}
						nodes.pop();
					}
				}
				nodes.push(tmp);
				iss.clear();
				iss.str(pile.top());
				iss >> current_state;
				temp.state = current_state;
				temp.input = prod;
				int res = goto_table[temp];
				if (res <= 0) {
					printf("Parse error!!\n");
					exit(-1);
				}
				// cout << "goto: " << res << endl;
				pile.push(convertInt(res));
				
			}

		} 

	}
}

int yywrap () { 
  Token = EndIn;
  yytext = "$";
  myparser ();
  return (1);
}

void print_parse_tree(Node* cNode, int tabs) {
	if(cNode != NULL && cNode->label != NULL) {
		int i = 0;
		while (i < tabs) {
			cout << "  ";
			i++;
		}
		cout << cNode->label << endl;
		if (cNode->child) {
			print_parse_tree(cNode->child, tabs+1);
		} else {
			if (cNode->label[0] != '<') {
				i = 0;
				while (i < tabs + 1) {
					cout << "  ";
					i++;
				}
				//cout << "\u03b5" << endl;
				cout << "epsilon" << endl;
			}
		}
		if (cNode->right_sibling) {
			print_parse_tree(cNode->right_sibling, tabs);
		}
	}
}

int main (int argc, char* argv[]) {
	if (argc != 5 || strcmp(argv[1], "-pt") != 0 || strcmp(argv[3], "-input") != 0){
                printf("Usage: %s -pt <parse_table_file> -input <input_file>", argv[0]);
                return 2;
        }

        ifstream pt_file(argv[2]);

        string line;
        if (!getline(pt_file, line)) {
                cout << "EOF reached in input file";
		return 2;
        }

	std:: istringstream istr(line);
	string test;

	int i = 0;
	while (istr >> test) {
		int ind = search(valid_inputs, 9, test);
		if (ind != -1) {
			action_indices[i] = test;
		} else {
			goto_indices[i] = test;
		}
		i++;
	}

	while(getline(pt_file, line)) {
		istr.clear();
		istr.str(line);
		int state;
		istr >> state;
		if (state <= 0) {
			cout << "Error with state numbers in parse table" << endl;
			exit(-1);
		}
		int i = 0;
		string in;
		while (istr >> in) {
			i_pair temp_pair;
			temp_pair.state = state;

			bool v = (action_indices.find(i) != action_indices.end());
			if (in == "9999") {
				in = "accept";
				temp_pair.input = action_indices[i];
				action_table[temp_pair] = in;
			} else if (v) { // in action_table
				temp_pair.input = action_indices[i];
				action_table[temp_pair] = in;
			} else {
				temp_pair.input = goto_indices[i];
				istringstream iss(in);
				int gt;
				iss >> gt;
				goto_table[temp_pair] = gt;
			}
			i++;
		}
	}


/***************************************************************************************/
	pile.push(convertInt(current_state));
	FILE *file = fopen(argv[4], "r");
	if (!file) {
		cout << "Could not open " << bracket(argv[4]) << endl;
		return -1;
	}
	yyin = file;
	yylex();

	printf ("Print Parse tree ...\n");
	print_parse_tree(head, 0);
	/* call your parse tree printing function */

	return (0);
}

