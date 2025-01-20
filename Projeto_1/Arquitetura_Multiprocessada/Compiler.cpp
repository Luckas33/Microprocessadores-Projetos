#include <iostream>
#include <fstream>
#include <string>
#include <algorithm>
#include <map>

#define WORD_SIZE 8

using namespace std;

struct info {
    string opcode;
    int arguments;
};

map<string, info> mnemonics = {

//MODIFIQUE OS MINEMONICOS SE FOR NECESSÁRIO,SE  QUISER  IMPLEMENTAR MAIS ETC...
    { "ADD", info{"00000001", 1} },  // ADD
    { "SUB", info{"00000010", 1} }, // SUB
    { "MUL", info{"00000011", 1} }, // MUL
    { "DIV", info{"00000100", 1} }, // DIV
    { "MOD", info{"00000101", 2} }, // MOD  
    { "AND", info{"00000110", 2} },  // AND
    { "OR", info{"00000111", 2} },  //OR
    { "XOR", info{"00001000", 2} }, //XOR
    { "NOT", info{"00001001", 2} }, //NOT
    { "NOR", info{"00001010", 2} }, //NOR
    { "NAND" , info{"00001011", 2} }, //NAND
    { "XNOR", info{"10001100", 2} },  //XNOR
    { "NOR", info{"00001101", 2} }, //MOV
    { "NAND" , info{"00001110", 2} }, //SLL
    { "XNOR", info{"10001111", 2} },  //SRL
};

void removeComments(string &s) {
    size_t pos = s.find(";");
    if (pos != string::npos) s.erase(pos);
}

void removeSpaces(string &s) {
    s.erase(remove(s.begin(), s.end(), ' '), s.end());
}

bool isBinary(const string& s) {
    return !s.empty() && s.find_first_not_of("01") == string::npos;
}

bool isCommand(const string& s) {
    return mnemonics.count(s) == 1;
}

int getArguments(const string& s) {
    return mnemonics[s].arguments;
}

string getOpcode(const string& s) {
    return mnemonics[s].opcode;
}

string completeArgument(const string& binary) {
    size_t missingZeros = WORD_SIZE - binary.size();
    string fullBinary = string(missingZeros, '0') + binary;
    return fullBinary;
}

int main(int argc, char** argv) {

    if (argc != 3) {
        cerr << "Usage: ./compiler file.asm file.bin" << endl;
        return 1;
    }

    // Usando o caminho absoluto para os arquivos
    ifstream asm_file("C:/Users/maria/OneDrive/Desktop/compilador/input.asm"); // Caminho absoluto do arquivo de entrada
    if (!asm_file.is_open())
    {
        cerr << "Cannot open input.asm" << endl;
        return 2;
    }

    ofstream bin_file("C:/Users/maria/OneDrive/Desktop/compilador/output.bin", ios::out | ios::binary); // Caminho absoluto do arquivo de saída
    if (!bin_file.is_open()) {
        cerr << "Cannot open output.bin" << endl;
        asm_file.close();
        return 2;
    }

    string cmdBuffer, argBuffer;
    int line = 0;

    // Loop principal: procura comandos que são representados por mnemonicos válidos
    while (getline(asm_file, cmdBuffer)) {

        line++;
        removeComments(cmdBuffer); removeSpaces(cmdBuffer);

        if (cmdBuffer.empty()) continue;

        if (!isCommand(cmdBuffer)) {
            cerr << "Semantic Error in line " << line << ": Command " << cmdBuffer << " is undefined" << endl;
            asm_file.close(); bin_file.close();
            return 3;
        }

        int expectedArgs = getArguments(cmdBuffer);
        string opcode = getOpcode(cmdBuffer);

        bin_file.write(opcode.c_str(), opcode.size());
        bin_file.put('\n');

        // Loop interno: analisa argumentos (linhas seguintes) para os comandos
        for (int i = 0; i < expectedArgs; i++) {

            line++;

            if (!getline(asm_file, argBuffer)) {
                cerr << "EOF reached before expected arguments" << endl;
                asm_file.close(); bin_file.close();
                return 4;
            }

            removeComments(argBuffer); removeSpaces(argBuffer);

            if (argBuffer.empty()) {
                i--; continue;
            }

            if (!isBinary(argBuffer) || argBuffer.size() > WORD_SIZE) {
                cerr << "Syntactic Error in line " << line << ": Invalid argument " << argBuffer << " for command " << cmdBuffer << endl;
                cerr << "Expected binary argument of size " << WORD_SIZE << endl;
                asm_file.close(); bin_file.close();
                return 5;
            }

            argBuffer = completeArgument(argBuffer);
            bin_file.write(argBuffer.c_str(), argBuffer.size());
            bin_file.put('\n');
        }
    }

    asm_file.close(); bin_file.close();
    return 0;
}
