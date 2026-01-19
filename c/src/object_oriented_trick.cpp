#include <iostream>

class alpha {
    private:
      int x;

    public:
      void Set_x(int x) {
     this->x = x; // set value of x via the `this pointer`;
    }
    void Printx(){
    std::cout << x;
    }

};

int main(void){
 
   alpha a;

  int* i = (int*)&a;
  
  *i = 123;
  a.Printx();

  return 0;
};
