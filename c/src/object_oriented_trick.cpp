#include <iostream>

// Credit to Creel on this one

class alpha
{
private:
  int x;

public:
  void Set_x(int x)
  {
     this->x = x; // set value of x via the `this pointer`;
  }

  void Printx()
  {
    std::cout << x;
  }

};

int main(void){
  alpha a;

  // Implore the type punning
  int* i = (int*)&a;
  
  *i = 123;

  // a.Set_x(25);
  a.Printx();

  return 0;
};
