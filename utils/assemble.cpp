#include<iostream>
#include<fstream>
#include<sstream>
#include<vector>
#include<unordered_map>
#include <algorithm>
#include <cctype>
#include<cstdlib>
#include <bitset>
#include <map>

using namespace std;

vector<string> wordseperator(string str);

unordered_map<string,string> regDefine();
unordered_map<string,string> immDefine();
unordered_map<string,string> jumDefine();
string regTrans(string str, int lineNum);

bool is_number(const string& s);
string to_hex(string str);

void invalidInstruction(int lineNum);


int main(int argc, char**argv){
    string infilename;
    bool littleEndian;
    bool hex;
    bool writeZeros;
    int lineNum = 0;
    long memSize = 16777216;

    unordered_map<string,string> registerMap = regDefine();
    unordered_map<string,string> immediateMap = immDefine();
    unordered_map<string,string> jumpMap = jumDefine();

    
    if(argc == 1){
        cerr << "No file defined";
        exit(EXIT_FAILURE);
    } else if(argc == 2) {
        infilename = argv[1];
        hex = true;
        littleEndian = false;
        writeZeros = false;
    } else if(argc == 3){
        infilename = argv[1];
        if(strcmp((const char (*))argv[2], "bin") == 0){hex = false;} else{hex = true;}
        littleEndian = false;
        writeZeros = false;
    } else if (argc == 4){
        infilename = argv[1];
        if(strcmp((const char (*))argv[2], "bin") == 0){hex = false;} else{hex = true;}
        if(strcmp((const char (*))argv[3], "littleEndian") == 0){littleEndian = true;} else{littleEndian = false;}
        writeZeros = false;
    }else if(argc > 4){
        infilename = argv[1];
        if(strcmp((const char (*))argv[2], "bin") == 0){hex = false;} else{hex = true;}
        if(strcmp((const char (*))argv[3], "littleEndian") == 0){littleEndian = true;} else{littleEndian = false;}
        writeZeros = true;
    }

    ifstream inputfile(infilename);

    if(inputfile.is_open()){
        string outfilename = "RAM_INIT"+infilename;
        ofstream outputfile(outfilename);


        //Assembling instructions
        string instr;
        while(getline(inputfile,instr)){
            if(instr == "data:"){
                break;
            }
            lineNum++;
            string binTrans;
            replace(instr.begin(), instr.end(), '(', ' ');
            replace(instr.begin(), instr.end(), ')', ' ');
            vector<string> line = wordseperator(instr);
            if (line.size()>4){line.resize(4);}
            if(registerMap.find(line[0])!=registerMap.end()){
                binTrans = "000000";
                if(line[0] == "jr"){
                    if (line.size()!=2){invalidInstruction(lineNum);}
                    binTrans = binTrans + regTrans(line[1],lineNum)+ bitset<15>(0).to_string() + registerMap.at(line[0]);
                }else if(line[0] == "mfhi" ||line[0] == "mflo"){
                    if (line.size()!=2){invalidInstruction(lineNum);}
                    binTrans = binTrans + bitset<10>(0).to_string()+ regTrans(line[1],lineNum)+ bitset<5>(0).to_string() + registerMap.at(line[0]);
                }else if(line[0] == "mthi" ||line[0] == "mtlo" || line[0] == "mthi" ||line[0] == "mtlo"){
                    if (line.size()!=2){invalidInstruction(lineNum);}
                    binTrans = binTrans + regTrans(line[1],lineNum)+ bitset<15>(0).to_string() + registerMap.at(line[0]);
                }else if(line[0] == "jalr"){
                    if (line.size()!=3){invalidInstruction(lineNum);}
                    binTrans = binTrans + regTrans(line[1],lineNum) + bitset<5>(0).to_string() + regTrans(line[2],lineNum)+ bitset<5>(0).to_string() + registerMap.at(line[0]);
                }else if (line[0] == "mult" ||line[0] == "multu" || line[0] == "div" ||line[0] == "divu"){
                    if (line.size()!=3){invalidInstruction(lineNum);}
                    binTrans = binTrans + regTrans(line[1],lineNum) + regTrans(line[2],lineNum) + bitset<10>(0).to_string()+registerMap.at(line[0]);
                }else if(line[0] == "sll" || line[0] =="srl" || line[0] == "sra"){
                    if (line.size()!=4){invalidInstruction(lineNum);}
                    binTrans = binTrans + bitset<5>(0).to_string() + regTrans(line[1],lineNum) + regTrans(line[2],lineNum) + bitset<5>(stol(line[3])).to_string()+ registerMap.at(line[0]);
                }else if (line[0] == "sllv" || line[0] =="slrv"){
                    if (line.size()!=4){invalidInstruction(lineNum);}
                    binTrans = binTrans + regTrans(line[3],lineNum) + regTrans(line[2],lineNum)+ regTrans(line[1],lineNum) + bitset<5>(0).to_string() + registerMap.at(line[0]);
                }else{
                    if (line.size()!=4){invalidInstruction(lineNum);}
                    binTrans = binTrans + regTrans(line[2],lineNum) + regTrans(line[3],lineNum)+ regTrans(line[1],lineNum) + bitset<5>(0).to_string() + registerMap.at(line[0]);
                }
            }else if(immediateMap.find(line[0]) != immediateMap.end()){
                if(line[0] == "lui"){
                    if (line.size()!=3){invalidInstruction(lineNum);}
                    binTrans = immediateMap.at(line[0]) + "00000" + regTrans(line[1],lineNum) + bitset<16>(stol(line[2],nullptr,16)).to_string();
                }else if(line[0] == "bltz" || line[0] == "blez" || line[0] == "bgtz"){
                    if (line.size()!=3){invalidInstruction(lineNum);}
                    binTrans = immediateMap.at(line[0]) + regTrans(line[1],lineNum) + "00000" + bitset<16>(stol(line[2],nullptr,16)).to_string();
                }else if(line[0] == "bgez"){
                    if (line.size()!=3){invalidInstruction(lineNum);}
                    binTrans = immediateMap.at(line[0]) + regTrans(line[1],lineNum) + "00001" + bitset<16>(stol(line[2],nullptr,16)).to_string();
                }else if(line[0] == "bltzal"){
                    if (line.size()!=3){invalidInstruction(lineNum);}
                    binTrans = immediateMap.at(line[0]) + regTrans(line[1],lineNum) + "10000" + bitset<16>(stol(line[2],nullptr,16)).to_string();
                }else if(line[0] == "bgezal"){
                    if (line.size()!=3){invalidInstruction(lineNum);}
                    binTrans = immediateMap.at(line[0]) + regTrans(line[1],lineNum) + "10001" + bitset<16>(stol(line[2],nullptr,16)).to_string();
                }else if(line[0] == "bne" || line[0] == "beq"){
                    if (line.size()!=4){invalidInstruction(lineNum);}
                    binTrans = immediateMap.at(line[0]) + regTrans(line[1],lineNum) + regTrans(line[2],lineNum) + bitset<16>(stol(line[3],nullptr,16)).to_string();
                } else if (line[0] == "addiu" || line[0] == "andiu" ||line[0] == "ori" ||line[0] == "xori"||line[0] == "slti"||line[0] == "sltiu"){
                    if (line.size()!=4){invalidInstruction(lineNum);}
                    binTrans = immediateMap.at(line[0]) + regTrans(line[2],lineNum) + regTrans(line[1],lineNum) + bitset<16>(stol(line[3],nullptr,16)).to_string();
                } else{
                    if (line.size()!=4){invalidInstruction(lineNum);}
                    binTrans = immediateMap.at(line[0]) + regTrans(line[3],lineNum) + regTrans(line[1],lineNum) + bitset<16>(stol(line[2],nullptr,16)).to_string();
                }
            }else if(jumpMap.find(line[0]) != jumpMap.end()){
                if(line[0] == "j"){
                    if (line.size()!=2){invalidInstruction(lineNum);}
                    binTrans = jumpMap.at(line[0]) + bitset<26>(stol(line[1],nullptr,16)).to_string();
                } else if (line[0] == "jal"){
                    if (line.size()!=2){invalidInstruction(lineNum);}
                    binTrans = jumpMap.at(line[0]) + bitset<26>(stol(line[1],nullptr,16)).to_string();
                }
            } else{
                invalidInstruction(lineNum);
                exit(EXIT_FAILURE);
            }

            string hexTrans = to_hex(binTrans.substr(0,4))+to_hex(binTrans.substr(4,4))+" "+to_hex(binTrans.substr(8,4))+to_hex(binTrans.substr(12,4))+" "+to_hex(binTrans.substr(16,4))+to_hex(binTrans.substr(20,4))+" "+to_hex(binTrans.substr(24,4))+to_hex(binTrans.substr(28,4));
            //cout << hexTrans << endl;
            string littleEndianTrans = hexTrans.substr(9,2)+" "+hexTrans.substr(6,2)+" "+hexTrans.substr(3,2)+" "+hexTrans.substr(0,2);
            
            if(littleEndian){
                cout<<littleEndianTrans<<endl;
            }else if(!hex){
                cout << binTrans <<endl;
            }else {
                cout << hexTrans <<endl;
            }    
        }

        //Writing additional data and zeros to memory
        string data;
        map<long, string> memoryaddress;
        long resetVector = stol("BFC00000",nullptr,16);
        while(getline(inputfile,data) && writeZeros){
            if(data.empty()){
                break;
            }
            replace(data.begin(), data.end(), ':', ' ');
            vector<string> line = wordseperator(data);
            if (line.size()>4){line.resize(4);}

            if((stol(line[0],nullptr,16)-resetVector) > memSize){
                cerr << "Data Address too large" <<endl;
                exit(EXIT_FAILURE);
            }else if ((stol(line[0],nullptr,16) < (lineNum * 4+resetVector)) && (stol(line[0],nullptr,16) > resetVector)){
                cerr <<"Data overwrites address" <<endl;
                exit(EXIT_FAILURE);
            }else if ((stol(line[0],nullptr,16) < resetVector)){
                cerr <<"Data not accessible" <<endl;
                exit(EXIT_FAILURE);
            }else if (stoi(line[1],nullptr,16)>255){
                cerr<<"Data being stored is too large"<<endl;
                exit(EXIT_FAILURE);
            }else if(line[1].size()!=2){
                cerr<<"Data size is incorrect, needs to be 2 bits"<<endl;
                exit(EXIT_FAILURE);
            }else if(line[0].size()!=8){
                cerr<<"Address size is incorrect, needs to be 8 bits"<<endl;
                exit(EXIT_FAILURE);
            }else if(memoryaddress.find(stol(line[0],nullptr,16)) != memoryaddress.end()){
                cerr<<"Memory address written to twice"<<endl;
                exit(EXIT_FAILURE);
            }else {
                memoryaddress.insert(pair<long,string>(stol(line[0],nullptr,16),line[1]));
            }       
        }
        if(writeZeros){
            for (long i = (lineNum*4)+resetVector; i < memSize+resetVector; i++){
                if(memoryaddress.find(i) == memoryaddress.end()){
                    cout << "00 ";
                }else{
                    cout << memoryaddress.at(i) + " ";
            }
            }
        }

    } else {
        cerr <<"Unable to open file";
        exit(EXIT_FAILURE);
    }
    exit(EXIT_SUCCESS);
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
    //copy(vstrings.begin(), vstrings.end(), ostream_iterator<string>(std::cerr, "\n"));
    return vstrings;
}

void invalidInstruction(int lineNum){
    cerr << "Invalid Instruction at line " << lineNum << endl; 
    exit(EXIT_FAILURE);
}

string regTrans(string str, int lineNum){
    int reg;
    if (str[0] != '$'){
        cerr << "Register " << str << " at line "<< lineNum << " is invalid" <<endl;
        exit(EXIT_FAILURE);
    } else {
        str.erase(str.begin());
        reg = stoi(str);
        if(reg > 31){
            cerr << "Register " << str << " at line "<< lineNum << " is invalid" <<endl;
            exit(EXIT_FAILURE);
        } else {
            return bitset<5>(reg).to_string();
        }
    }
}

string to_hex(string str){
    if(str == "0000"){return "0";}
    else if(str == "0001"){return "1";}
    else if(str == "0010"){return "2";}
    else if(str == "0011"){return "3";}
    else if(str == "0100"){return "4";}
    else if(str == "0101"){return "5";}
    else if(str == "0110"){return "6";}
    else if(str == "0111"){return "7";}
    else if(str == "1000"){return "8";}
    else if(str == "1001"){return "9";}
    else if(str == "1010"){return "a";}
    else if(str == "1011"){return "b";}
    else if(str == "1100"){return "c";}
    else if(str == "1101"){return "d";}
    else if(str == "1110"){return "e";}
    else if(str == "1111"){return "f";}
    else {cerr <<"Not binary!"<<endl; exit(EXIT_FAILURE);}

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