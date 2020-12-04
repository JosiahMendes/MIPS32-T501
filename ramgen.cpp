#include <iostream>
#include <string>

using namespace std;

int main(){
    cout <<"0a 00 42 24 c0 bf 63 24 00 1c 03 00 18 00 63 24 08 00 60 00 0a 00 42 24 08 00 00 00 14 00 42 24"<<endl;
    for (int i = 0; i<16777216-32; i++){
        cout << "00 ";
    }
}
