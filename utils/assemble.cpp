#include<iostream>
#include<fstream>
#include<sstream>
#include<vector>
#include<unordered_map>
#include <algorithm>
#include <cctype>
#include<cstdlib>
#include <bitset>

using namespace std;

vector<string> wordseperator(string str);
unordered_map<string,string> regDefine();
unordered_map<string,string> immDefine();
unordered_map<string,string> jumDefine();
string regTrans(string str, int lineNum);
bool is_number(const string& s);


int main(int argc, char**argv){
    string infilename;
    unsigned long memorySize;
    int lineNum = 0;

    unordered_map<string,string> registerMap = regDefine();
    unordered_map<string,string> immediateMap = immDefine();
    unordered_map<string,string> jumpMap = jumDefine();

    
    if(argc == 1){
        cout<< "No file & Memory defined";
        exit(EXIT_FAILURE);
    } else if (argc == 2){
        cout<< "File or memory size undefined";
    } else if(argc >= 3 && is_number(argv[2])){
        infilename = argv[1];
        memorySize = stol(argv[2]);
    }

    ifstream inputfile(infilename);

    if(inputfile.is_open()){
        string outfilename = "RAM_INIT"+infilename;
        ofstream outputfile(outfilename);

        string instr;
        while(getline(inputfile,instr)){
            lineNum++;
            string binTrans;
            vector<string> line = wordseperator(instr);
            if(registerMap.find(line[0])!=registerMap.end()){
                binTrans = "000000";
                if(line[0] == "jr"){
                    if (line.size()!=2){cout << "Invalid Instruction at line " << lineNum << endl; exit(EXIT_FAILURE);}
                    binTrans = binTrans + regTrans(line[1],lineNum)+ bitset<15>(0).to_string() + registerMap.at(line[0]);
                }else if(line[0] == "mfhi" ||line[0] == "mflo"){
                    if (line.size()!=2){cout << "Invalid Instruction at line " << lineNum << endl; exit(EXIT_FAILURE);}
                    binTrans = binTrans + bitset<10>(0).to_string()+ regTrans(line[1],lineNum)+ bitset<5>(0).to_string() + registerMap.at(line[0]);
                }else if(line[0] == "mthi" ||line[0] == "mtlo" || line[0] == "mthi" ||line[0] == "mtlo"){
                    if (line.size()!=2){cout << "Invalid Instruction at line " << lineNum << endl; exit(EXIT_FAILURE);}
                    binTrans = binTrans + regTrans(line[1],lineNum)+ bitset<15>(0).to_string() + registerMap.at(line[0]);
                }else if(line[0] == "jalr"){
                    if (line.size()!=3){cout << "Invalid Instruction at line " << lineNum << endl; exit(EXIT_FAILURE);}
                    binTrans = binTrans + regTrans(line[1],lineNum) + bitset<5>(0).to_string() + regTrans(line[2],lineNum)+ bitset<5>(0).to_string() + registerMap.at(line[0]);
                }else if (line[0] == "mult" ||line[0] == "multu" || line[0] == "div" ||line[0] == "divu"){
                    if (line.size()!=3){cout << "Invalid Instruction at line " << lineNum << endl; exit(EXIT_FAILURE);}
                    binTrans = binTrans + regTrans(line[1],lineNum) + regTrans(line[2],lineNum) + bitset<10>(0).to_string()+registerMap.at(line[0]);
                }else if(line[0] == "sll" || line[0] =="srl" || line[0] == "sra"){
                    if (line.size()!=4){cout << "Invalid Instruction at line " << lineNum << endl; exit(EXIT_FAILURE);}
                    binTrans = binTrans + bitset<5>(0).to_string() + regTrans(line[1],lineNum) + regTrans(line[2],lineNum) + bitset<5>(stol(line[3])).to_string()+ registerMap.at(line[0]);
                }else if (line[0] == "sllv" || line[0] =="slrv"){
                    if (line.size()!=4){cout << "Invalid Instruction at line " << lineNum << endl; exit(EXIT_FAILURE);}
                    binTrans = binTrans + regTrans(line[3],lineNum) + regTrans(line[2],lineNum)+ regTrans(line[1],lineNum) + bitset<5>(0).to_string() + registerMap.at(line[0]);
                }else{
                    if (line.size()!=4){cout << "Invalid Instruction at line " << lineNum << endl; exit(EXIT_FAILURE);}
                    binTrans = binTrans + regTrans(line[2],lineNum) + regTrans(line[3],lineNum)+ regTrans(line[1],lineNum) + bitset<5>(0).to_string() + registerMap.at(line[0]);
                }
            }else if(immediateMap.find(line[0]) != immediateMap.end()){
                if(line[0] == "lui"){
                    if (line.size()!=3){cout << "Invalid Instruction at line " << lineNum << endl; exit(EXIT_FAILURE);}
                    binTrans = immediateMap.at(line[0]) + "00000" + regTrans(line[1],lineNum) + bitset<16>(stol(line[2],nullptr,16)).to_string();
                }else if(line[0] == "bltz" || line[0] == "blez" || line[0] == "bgtz"){
                    if (line.size()!=3){cout << "Invalid Instruction at line " << lineNum << endl; exit(EXIT_FAILURE);}
                    binTrans = immediateMap.at(line[0]) + regTrans(line[1],lineNum) + "00000" + bitset<16>(stol(line[2],nullptr,16)).to_string();
                }else if(line[0] == "bgez"){
                    if (line.size()!=3){cout << "Invalid Instruction at line " << lineNum << endl; exit(EXIT_FAILURE);}
                    binTrans = immediateMap.at(line[0]) + regTrans(line[1],lineNum) + "00001" + bitset<16>(stol(line[2],nullptr,16)).to_string();
                }else if(line[0] == "bltzal"){
                    if (line.size()!=3){cout << "Invalid Instruction at line " << lineNum << endl; exit(EXIT_FAILURE);}
                    binTrans = immediateMap.at(line[0]) + regTrans(line[1],lineNum) + "10000" + bitset<16>(stol(line[2],nullptr,16)).to_string();
                }else if(line[0] == "bgezal"){
                    if (line.size()!=3){cout << "Invalid Instruction at line " << lineNum << endl; exit(EXIT_FAILURE);}
                    binTrans = immediateMap.at(line[0]) + regTrans(line[1],lineNum) + "10001" + bitset<16>(stol(line[2],nullptr,16)).to_string();
                }else{
                    if (line.size()!=4){cout << "Invalid Instruction at line " << lineNum << endl; exit(EXIT_FAILURE);}
                    binTrans = immediateMap.at(line[0]) + regTrans(line[1],lineNum) + regTrans(line[2],lineNum) + bitset<16>(stol(line[3],nullptr,16)).to_string();
                }
            }else if(jumpMap.find(line[0]) != jumpMap.end()){
                if(line[0] == "j"){
                    if (line.size()!=2){cout << "Invalid Instruction at line " << lineNum << endl; exit(EXIT_FAILURE);}
                    binTrans = jumpMap.at(line[0]) + bitset<26>(stol(line[1],nullptr,16)).to_string();
                } else if (line[0] == "jal"){
                    if (line.size()!=2){cout << "Invalid Instruction at line " << lineNum << endl; exit(EXIT_FAILURE);}
                    binTrans = jumpMap.at(line[0]) + bitset<26>(stol(line[1],nullptr,16)).to_string();
                }
            } else{
                cout << "Invalid Instruction at line " << lineNum << endl;
                exit(EXIT_FAILURE);
            }
            bitset<32> set(binTrans);  
            cout << setfill('0');
            cout << hex << setw(8) << set.to_ulong() << endl;
            cout << binTrans <<endl;


        }
    } else cout <<"Unable to open file";


}

vector<string> wordseperator(string str)
{
    // Used to split string around spaces.
    //string input = str;

    transform(str.begin(), str.end(), str.begin(), ::tolower);

    stringstream ss(str);
 
    istream_iterator<string> begin(ss);
    istream_iterator<std::string> end;
    vector<string> vstrings(begin, end);
    //copy(vstrings.begin(), vstrings.end(), ostream_iterator<string>(std::cout, "\n"));
    return vstrings;
}

string regTrans(string str, int lineNum){
    int reg;
    if (str[0] != '$'){
        cout << "Register " << str << " at line "<< lineNum << " is invalid" <<endl;
        exit(EXIT_FAILURE);
    } else {
        str.erase(str.begin());
        reg = stoi(str);
        if(reg > 31){
            cout << "Register " << str << " at line "<< lineNum << " is invalid" <<endl;
            exit(EXIT_FAILURE);
        } else {
            return bitset<5>(reg).to_string();
        }
    }
}

unordered_map<string,string> regDefine(){
    unordered_map<string, string> umap;

    umap["addu"] = "100001";
    umap["and"]  = "100100";
    umap["div"]  = "011010";
    umap["divu"] = "011011";
    umap["jalr"] = "001001";
    umap["jr"]   = "001000";
    umap["mfhi"] = "010000";
    umap["mflo"] = "010010";
    umap["mthi"] = "010001";
    umap["mtlo"] = "010011";
    umap["mult"] = "011000";
    umap["multu"]= "011001";
    umap["or"]   = "100101";
    umap["sll"]  = "000000";
    umap["sllv"] = "000100";
    umap["slt"]  = "101010";
    umap["sltu"] = "101011";
    umap["sra"]  = "000011";
    umap["srav"] = "000111";
    umap["srl"]  = "000010";
    umap["srlv"] = "000110";
    umap["subu"] = "100011";
    umap["xor"]  = "100110";

    return umap;
}

unordered_map<string,string> immDefine(){
    unordered_map<string, string> umap;

    umap["addiu"] = "001001";
    umap["andi"]  = "001100";
    umap["beq"]   = "000100";
    umap["bgez"]  = "000001";
    umap["bgezal"]= "000001";
    umap["bgtz"]  = "000111";
    umap["blez"]  = "000110";
    umap["bltz"]  = "000001";
    umap["bltzal"]= "000001";
    umap["bne"]   = "000101";
    umap["lb"]    = "100000";
    umap["lbu"]   = "100100";
    umap["lh"]    = "100001";
    umap["lhu"]   = "100100";
    umap["lui"]   = "001111";
    umap["lw"]    = "100011";
    umap["lwl"]   = "100010";
    umap["lwr"]   = "100110";
    umap["ori"]   = "001101";
    umap["sb"]    = "101000";
    umap["sh"]    = "101001";
    umap["slti"]  = "001010";
    umap["sltiu"] = "001011";
    umap["sw"]    = "101011";
    umap["xori"]  = "001110";

    return umap;
}

unordered_map<string,string> jumDefine(){
    unordered_map<string, string> umap;

    umap["j"] = "000010";
    umap["jal"] = "000011";

    return umap;
}

bool is_number(const string& s)
{
    for (int i = 0; i < s.length(); i++)
        if (isdigit(s[i]) == false)
            return false;
 
    return true;
}