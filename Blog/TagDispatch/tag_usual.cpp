#include <type_traits>
#include <iostream>

template<typename T>
class Matrix {};

struct UndefinedTag;

template <typename T>
void matrixProduct(const UndefinedTag&, Matrix<T>& AB,
                   const Matrix<T>& A, const Matrix<T>& B)
{
  static_assert(!std::is_same<T, T>::value, /* differed false */
                "Missing specialization");
}

struct GenericTag;

template <typename T>
typename std::enable_if<std::is_arithmetic<T>::value>::type
    matrixProduct(const GenericTag&, Matrix<T>& AB,
                  const Matrix<T>& A, const Matrix<T>& B)
{
  std::cout << "\nUse a generic (in-house) implementation";
}

struct BlasTag;

template <typename T>
typename std::enable_if<std::is_same<T, float>::value ||
                        std::is_same<T, double>::value>::type
    matrixProduct(const BlasTag&, Matrix<T>& AB, const Matrix<T>& A,
                  const Matrix<T>& B)
{
  std::cout << "\nUse a BLAS call";
}

// Define a Tag hierarchy
// -> this induce an order in the dispatch
struct UndefinedTag
{
};

struct GenericTag : UndefinedTag
{
};

struct BlasTag : GenericTag
{
};

template <typename T>
void matrixProduct(Matrix<T>& AB, const Matrix<T>& A,
                   const Matrix<T>& B)
{
  matrixProduct(BlasTag(), AB, A, B);
}

int main()
{
 struct A
  {
  };

  Matrix<A> aResult, aM;
  Matrix<int> iResult, iM;
  Matrix<double> dResult, dM;

  // matrixProduct(aResult, aM, aM);  // static assert error OK
  matrixProduct(iResult, iM, iM);  // OK!
  matrixProduct(dResult, dM, dM);  // OK!
}
