#include <iostream>
#include <string>
#include <algorithm>
#include <fstream>
#include <map>

#define Word_size 8

using namespace std;

struct info{
    string opcode;
    int arguments;
};

map<string,info>codigos = {
    {"ADD", info{"00000001"},2},
    {"SUB", info{"00000010"},2},
    {"NOT", info{"00000100"},2}
    //ADICIONAR MAIS CODIGOS DE OPERAÇÃO AQUI!
};
void removeCommentsAndSpaces(string &s) {
    // Remove comentários (tudo após o ponto e vírgula)
    size_t pos = s.find(";");
    if (pos != string::npos) s.erase(pos);

    // Remove todos os espaços
    s.erase(remove(s.begin(), s.end(), ' '), s.end());
}

//verifica se o argumento é binario
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

int getArguments(const string& s) {
    return mnemonics[s].arguments;
}

string getOpcode(const string& s) {
    return mnemonics[s].opcode;
}


int main(int agrc, char**argv){

    if(argc != 3){
        cerr << "Usage: ./compilador file.asm file.bin"<<endl;
        return 1;
    }
    ifstream asm_file(argv[1]);
    if(!asm_file.is_open()){
        cerr << "cannot open"<<argv[1]<<endl;
        return 2;
    }
    ofstream bin_file(argv[2],ios::out | ios::binary);
    if(!bin_file.is_open()){
        cerr << "cannot open"<<endl;
        asm_file.close();
        return 2;
    }

    string cmdBuffer, argbuffer;
    int line = 0;

    //esse loop faz a procura dos codigos.
    while(getline(asm_file,cmdBuffer)){
        line++;
        removeCommentsAndSpaces(cmdBuffer);

        if(cmdBuffer.empty())continue;

        if(!isCommand(cmdBuffer)){
            cerr <<"semantic error in line "<< line << ": command "<<cmdBuffer<< "is undefined" endl;
            asm_file.close(); bin_file.close;
            return 3;
        }

        int expectedArgs = getArguments(cmdBuffer);
        string opcode = getOpcode(cmdBuffer);

        bin_file.write(opcode.c_str(),opcode.size());
        bin_file.put('\n');

        //esse loop aqui analisa se as linhas que seguem são do padrão correto para fazer as operações
        for(int i=0;i<expectedArgs;i++){
            line++

            if(!getline(asm_file,argbuffer)){
                cerr << "EOF reached before expected arguments" << endl;
                asm_file.close(); bin_file.close;
                return 4;
            }

            removeCommentsAndSpaces(argbuffer);
            if(argbuffer.empty()){
                i--; continue;
            }
            //verifica se o argbuffer é binario e se o tamanho do argumento é do tamanho aceitado
            if(!isBinary(argbuffer)||argbuffer.size() > Word_size){
                cerr << "Syntactic Error in line " << line << ": Invalid argument " << argBuffer << " for command " << cmdBuffer << endl;
                cerr << "Expected binary argument of size " << WORD_SIZE << endl;
                asm_file.close(); bin_file.close();
                return 5;
            }

            argbuffer = completeArgument(argbuffer);
            bin_file.write(argbuffer.c_str(),argbuffer.size());
            bin_file.put('\n');
        }
    }
    //fecha tudo
    asm_file.close();
    bin_file.close();
    return 0;
}
