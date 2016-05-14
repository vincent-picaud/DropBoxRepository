#include <type_traits>
#include <iostream>

template<typename T>
class Matrix {};

template <unsigned int N>
struct PriorityTag : PriorityTag<N - 1>
{
};

template <>
struct PriorityTag<0>
{
};

template <typename PRIORITY, PRIORITY integer>
using PriorityConfiguration = PriorityTag<static_cast<
    typename std::underlying_type<PRIORITY>::type>(integer)>;

template <typename PRIORITY, typename T>
void matrixProduct(
    const PriorityConfiguration<PRIORITY, PRIORITY::Undefined>&,
    Matrix<T>& AB, const Matrix<T>& A, const Matrix<T>& B)
{
  static_assert(!std::is_same<T, T>::value, /* differed false */
                "Missing specialization");
}

template <typename PRIORITY, typename T>
typename std::enable_if<std::is_arithmetic<T>::value>::type
    matrixProduct(
        const PriorityConfiguration<PRIORITY, PRIORITY::Generic>&,
        Matrix<T>& AB, const Matrix<T>& A, const Matrix<T>& B)
{
  std::cout << "\nUse a generic (in-house) implementation";
}

template <typename PRIORITY, typename T>
typename std::enable_if<std::is_same<T, float>::value ||
                        std::is_same<T, double>::value>::type
    matrixProduct(
        const PriorityConfiguration<PRIORITY, PRIORITY::Blas>&,
        Matrix<T>& AB, const Matrix<T>& A, const Matrix<T>& B)
{
  std::cout << "\nUse a BLAS call";
}

template <typename T>
void matrixProduct(Matrix<T>& AB, const Matrix<T>& A,
                   const Matrix<T>& B)
{
  enum class LocalPriority : unsigned int
  {
    Undefined,
    Generic,
    Blas, 

    END
  };

  matrixProduct<LocalPriority>(
      PriorityConfiguration<LocalPriority, LocalPriority::END>(), AB,
      A, B);
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
