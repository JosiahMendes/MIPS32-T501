#include<iostream>
#include <iomanip>
#include <iterator>
#include<fstream>
#include<sstream>
#include<vector>
#include<unordered_map>
#include <algorithm>
#include <cctype>
#include<cstdlib>
#include<bitset>
#include <map>
#include <string.h>
#include <stdio.h>

using namespace std;

vector<string> wordseperator(string str);

unordered_map<string,string> regDefine();
unordered_map<string,string> immDefine();
unordered_map<string,string> jumDefine();
string regTrans(string str, int lineNum, unordered_map<string,int> &registerlist);
unordered_map<string,int> registers();

bool is_number(const string& s);
string bin_to_hex(string str);
string tobin26(string str);
string tobin16(string str);
string tobin5(string str);
long tolong(string str);
string tohex(string str);

void invalidInstruction(int lineNum);


int main(int argc, char**argv){
    string infilename;
    bool littleEndian;
    bool hex;
    bool writeZeros;
    int lineNum = 0;
    long memSize = 32768;

    unordered_map<string,string> registerMap = regDefine();
    unordered_map<string,string> immediateMap = immDefine();
    unordered_map<string,string> jumpMap = jumDefine();
    unordered_map<string,int> registerlist = registers();



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
            string temp = instr.substr(0, instr.find("#", 0));
            vector<string> line = wordseperator(temp);
            if(registerMap.find(line[0])!=registerMap.end()){
                binTrans = "000000";
                if(line[0] == "jr"){
                    if (line.size()!=2){invalidInstruction(lineNum);}
                    binTrans = binTrans + regTrans(line[1],lineNum, registerlist)+ bitset<15>(0).to_string() + registerMap.at(line[0]);
                }else if(line[0] == "mfhi" ||line[0] == "mflo"){
                    if (line.size()!=2){invalidInstruction(lineNum);}
                    binTrans = binTrans + bitset<10>(0).to_string()+ regTrans(line[1],lineNum, registerlist)+ bitset<5>(0).to_string() + registerMap.at(line[0]);
                }else if(line[0] == "mthi" ||line[0] == "mtlo" || line[0] == "mthi" ||line[0] == "mtlo"){
                    if (line.size()!=2){invalidInstruction(lineNum);}
                    binTrans = binTrans + regTrans(line[1],lineNum, registerlist)+ bitset<15>(0).to_string() + registerMap.at(line[0]);
                }else if(line[0] == "jalr"){
                    if (!(line.size() ==3||line.size() ==2)){invalidInstruction(lineNum);}
                    if(line.size() == 3){binTrans = binTrans + regTrans(line[2],lineNum, registerlist) + bitset<5>(0).to_string() + regTrans(line[1],lineNum, registerlist)+ bitset<5>(0).to_string() + registerMap.at(line[0]);}
                    else if(line.size() == 2){binTrans = binTrans + regTrans(line[1],lineNum, registerlist) + bitset<5>(0).to_string()+"11111"+bitset<5>(0).to_string() + registerMap.at(line[0]);}
                }else if (line[0] == "mult" ||line[0] == "multu" || line[0] == "div" ||line[0] == "divu"){
                    if (line.size()!=3){invalidInstruction(lineNum);}
                    binTrans = binTrans + regTrans(line[1],lineNum, registerlist) + regTrans(line[2],lineNum, registerlist) + bitset<10>(0).to_string()+registerMap.at(line[0]);
                }else if(line[0] == "sll" || line[0] =="srl" || line[0] == "sra"){
                    if (line.size()!=4){invalidInstruction(lineNum);}
                    binTrans = binTrans + bitset<5>(0).to_string() + regTrans(line[1],lineNum, registerlist) + regTrans(line[2],lineNum, registerlist) + tobin5(line[3])+ registerMap.at(line[0]);
                }else if (line[0] == "sllv" || line[0] =="srlv" || line[0] == "srav"){
                    if (line.size()!=4){invalidInstruction(lineNum);}
                    binTrans = binTrans + regTrans(line[3],lineNum, registerlist) + regTrans(line[2],lineNum, registerlist)+ regTrans(line[1],lineNum, registerlist) + bitset<5>(0).to_string() + registerMap.at(line[0]);
                }else{
                    if (line.size()!=4){invalidInstruction(lineNum);}
                    binTrans = binTrans + regTrans(line[2],lineNum, registerlist) + regTrans(line[3],lineNum, registerlist)+ regTrans(line[1],lineNum, registerlist) + bitset<5>(0).to_string() + registerMap.at(line[0]);
                }
            }else if(immediateMap.find(line[0]) != immediateMap.end()){
                if(line[0] == "lui"){
                    if (line.size()!=3){invalidInstruction(lineNum);}
                    binTrans = immediateMap.at(line[0]) + "00000" + regTrans(line[1],lineNum, registerlist) + tobin16(line[2]);
                }else if(line[0] == "bltz" || line[0] == "blez" || line[0] == "bgtz"){
                    if (line.size()!=3){invalidInstruction(lineNum);}
                    binTrans = immediateMap.at(line[0]) + regTrans(line[1],lineNum, registerlist) + "00000" + tobin16(line[2]);
                }else if(line[0] == "bgez"){
                    if (line.size()!=3){invalidInstruction(lineNum);}
                    binTrans = immediateMap.at(line[0]) + regTrans(line[1],lineNum, registerlist) + "00001" + tobin16(line[2]);
                }else if(line[0] == "bltzal"){
                    if (line.size()!=3){invalidInstruction(lineNum);}
                    binTrans = immediateMap.at(line[0]) + regTrans(line[1],lineNum, registerlist) + "10000" + tobin16(line[2]);
                }else if(line[0] == "bgezal"){
                    if (line.size()!=3){invalidInstruction(lineNum);}
                    binTrans = immediateMap.at(line[0]) + regTrans(line[1],lineNum, registerlist) + "10001" + tobin16(line[2]);
                }else if(line[0] == "bne" || line[0] == "beq"){
                    if (line.size()!=4){invalidInstruction(lineNum);}
                    binTrans = immediateMap.at(line[0]) + regTrans(line[1],lineNum, registerlist) + regTrans(line[2],lineNum, registerlist) + tobin16(line[3]);
                } else if (line[0] == "addiu" || line[0] == "andi" ||line[0] == "ori" ||line[0] == "xori"||line[0] == "slti"||line[0] == "sltiu"){
                    if (line.size()!=4){invalidInstruction(lineNum);}
                    binTrans = immediateMap.at(line[0]) + regTrans(line[2],lineNum, registerlist) + regTrans(line[1],lineNum, registerlist) + tobin16(line[3]);
                } else{
                    if (line.size()!=4){invalidInstruction(lineNum);}
                    binTrans = immediateMap.at(line[0]) + regTrans(line[3],lineNum, registerlist) + regTrans(line[1],lineNum, registerlist) + tobin16(line[2]);
                }
            }else if(jumpMap.find(line[0]) != jumpMap.end()){
                if(line[0] == "j"){
                    if (line.size()!=2){invalidInstruction(lineNum);}
                    binTrans = jumpMap.at(line[0]) + tobin26(line[1]);
                } else if (line[0] == "jal"){
                    if (line.size()!=2){invalidInstruction(lineNum);}
                    binTrans = jumpMap.at(line[0]) + tobin26(line[1]);
                }
            } else{
                invalidInstruction(lineNum);
                exit(EXIT_FAILURE);
            }



            string hexTrans = bin_to_hex(binTrans.substr(0,8))+" "+bin_to_hex(binTrans.substr(8,8))+" "+bin_to_hex(binTrans.substr(16,8))+" "+bin_to_hex(binTrans.substr(24,8));
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

            if((tolong(line[0])-resetVector) > memSize){
                cerr << "Data Address  " << line[0]<< " is too large" <<endl;
                exit(EXIT_FAILURE);
            }else if ((tolong(line[0]) < (lineNum * 4+resetVector)) && (tolong(line[0]) > resetVector)){
                cerr <<"Data overwrites address "<< line[0] <<endl;
                exit(EXIT_FAILURE);
            }else if ((tolong(line[0]) < resetVector)){
                cerr <<"Data Address  " << line[0]<< " is not accessible" <<endl;
                exit(EXIT_FAILURE);
            }else if (tolong(line[1])>255){
                cerr<<"Data being stored at address " << line[0]<< " is too large"<<endl;
                exit(EXIT_FAILURE);
            }else if(memoryaddress.find(tolong(line[0])) != memoryaddress.end()){
                cerr<<"Memory address  " << line[0]<< " is written to twice"<<endl;
                exit(EXIT_FAILURE);
            }else {
                memoryaddress.insert(pair<long,string>(tolong(line[0]),tohex(line[1])));
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

string tobin26(string str){
    if(str.substr(0,2) == "0x"){
        return bitset<26>(stol(str.substr(2),nullptr,16)).to_string();
    }else if(is_number(str)){
        return bitset<26>(stol(str)).to_string();
    }else{cerr<< "Value is not hex or dec!";exit(EXIT_FAILURE);}
}
string tobin16(string str){
    if(str.substr(0,2) == "0x"){
        return bitset<16>(stol(str.substr(2),nullptr,16)).to_string();
    }else if(is_number(str)){
        return bitset<16>(stol(str)).to_string();
    }else{cerr<< "Value is not hex or dec!";exit(EXIT_FAILURE);}
}
string tobin5(string str){
    if(str.substr(0,2) == "0x"){
        return bitset<5>(stol(str.substr(2),nullptr,16)).to_string();
    }else if(is_number(str)){
        return bitset<5>(stol(str)).to_string();
    }else{cerr<< "Value is not hex or dec!";exit(EXIT_FAILURE);}
}
long tolong(string str){
    if(str.substr(0,2) == "0x"){
        return stol(str.substr(2),nullptr,16);
    }else if(is_number(str)){
        return stol(str);
    }else{cerr<< "Value is not hex or dec!";exit(EXIT_FAILURE);}
}
string tohex(string str){
    if(str.substr(0,2) == "0x"){
        return str.substr(2);
    }else if(is_number(str)){
        stringstream ss;
        ss<<hex<<setfill('0')<<setw(2)<<stol(str);
        return (ss.str());
    }else{cerr<< "Value is not hex or dec!";exit(EXIT_FAILURE);}
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

string regTrans(string str, int lineNum, unordered_map<string,int> &registerlist){
    int reg;
    if(registerlist.find(str) != registerlist.end()){
        return bitset<5>(registerlist.at(str)).to_string();
    }else if (str[0] != '$'){
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

string bin_to_hex(string str){
    bitset<8> set(str);
    stringstream res;
    res << hex << uppercase <<setfill('0')<<setw(2)<< set.to_ullong();
    return res.str();
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

unordered_map<string,int> registers(){
    unordered_map<string, int> umap;
    umap["r0"] = 0;
    umap["at"] =1;
    umap["v0"] = 2;
    umap["v1"] = 3;
    umap["a0"] = 4;
    umap["a1"] = 5;
    umap["a2"] = 6;
    umap["a3"] = 7;
    umap["t0"] = 8;
    umap["t1"] = 9;
    umap["t2"] = 10;
    umap["t3"] = 11;
    umap["t4"] = 12;
    umap["t5"] = 13;
    umap["t6"] = 14;
    umap["t7"] = 15;
    umap["s0"] = 16;
    umap["s1"] = 17;
    umap["s1"] = 18;
    umap["s3"] = 19;
    umap["s4"] = 20;
    umap["s5"] = 21;
    umap["s6"] = 22;
    umap["s7"] = 23;
    umap["t8"] = 24;
    umap["t9"] = 25;
    umap["k0"] = 26;
    umap["k1"] = 27;
    umap["gp"] = 28;
    umap["sp"] = 29;
    umap["s8"] = 30;
    umap["ra"] = 31;

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
    umap["lhu"]   = "100101";
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