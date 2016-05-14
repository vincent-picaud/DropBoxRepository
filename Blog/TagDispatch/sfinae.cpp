#include <type_traits>
#include <iostream>

template<typename T>
class Matrix {};

template <typename T>
void matrixProduct(Matrix<T>& AB, const Matrix<T>& A,
                   const Matrix<T>& B)
{
  static_assert(!std::is_same<T, T>::value, /* differed false */
                "Missing specialization");
}
template <typename T>
typename std::enable_if<std::is_arithmetic<T>::value>::type
    matrixProduct(Matrix<T>& AB, const Matrix<T>& A,
                  const Matrix<T>& B)
{
  std::cout << "\nUse a generic (in-house) implementation";
}

template <typename T>
typename std::enable_if<std::is_same<T, float>::value||std::is_same<T, double>::value>::type
    matrixProduct(Matrix<T>& AB, const Matrix<T>& A,
                  const Matrix<T>& B)
{
  std::cout << "\nUse a BLAS call";
}

// Does not compile!
int main()
{
 struct A
  {
  };

  Matrix<A> aResult, aM;
  Matrix<int> iResult, iM;
  Matrix<double> dResult, dM;

  // matrixProduct(aResult, aM, aM);  // static assert error OK
  matrixProduct(iResult, iM, iM);  // Error!
  matrixProduct(dResult, dM, dM);  // Error!
}
