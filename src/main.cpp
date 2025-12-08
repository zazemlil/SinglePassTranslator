#include <iostream>

extern float analize(char* arg);

int main(int argc, char* argv[])
{   
    std::cout << "-----------------------------\n";
    std::cout << "----Abstract syntax tree:----\n";
    std::cout << "-----------------------------\n";
    std::cout << analize(argv[1]) << "\n";
    
    return 0;
}