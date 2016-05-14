#include <type_traits>
#include <iostream>

template<typename T>
class Matrix {};

// Code from:
// https://github.com/wichtounet/cpp_utils/blob/master/static_if.hpp
//
// See:
// http://baptiste-wicht.com/posts/2015/07/simulate-static_if-with-c11c14.html
// http://lists.boost.org/Archives/boost/2014/08/216607.php
//
namespace static_if_detail
{
  struct identity
  {
    template <typename T>
    T operator()(T&& x) const
    {
      return std::forward<T>(x);
    }
  };

  template <bool Cond>
  struct statement
  {
    template <typename F>
    void then(const F& f)
    {
      f(identity());
    }

    template <typename F>
    void else_(const F&)
    {
    }
  };

  template <>
  struct statement<false>
  {
    template <typename F>
    void then(const F&)
    {
    }

    template <typename F>
    void else_(const F& f)
    {
      f(identity());
    }
  };
}

template <bool Cond, typename F>
static_if_detail::statement<Cond> static_if(F const& f)
{
  static_if_detail::statement<Cond> if_;
  if_.then(f);
  return if_;
}

template <typename T>
void matrixProduct_undefined(Matrix<T>& AB, const Matrix<T>& A,
                             const Matrix<T>& B)
{
  static_assert(!std::is_same<T, T>::value, /* differed false */
                "Missing specialization");
}

template <typename T>
constexpr bool matrixProduct_generic_v = std::is_arithmetic<T>::value;

template <typename T>
typename std::enable_if<matrixProduct_generic_v<T>>::type
    matrixProduct_generic(Matrix<T>& AB, const Matrix<T>& A,
                          const Matrix<T>& B)
{
  std::cout << "\nUse a generic (in-house) implementation";
}

template <typename T>
constexpr bool matrixProduct_blas_v =
    std::is_same<T, float>::value || std::is_same<T, double>::value;

template <typename T>
typename std::enable_if<matrixProduct_blas_v<T>>::type
    matrixProduct_blas(Matrix<T>& AB, const Matrix<T>& A,
                       const Matrix<T>& B)
{
  std::cout << "\nUse a BLAS call";
}

template <typename T>
void matrixProduct(Matrix<T>& AB, const Matrix<T>& A, const Matrix<T>& B)
{
    static_if<matrixProduct_blas_v<T>>([&](auto id)
                                       {
                                           matrixProduct_blas(id(AB), id(A), id(B));
                                       })
        .else_([&](auto id)
               {
                   static_if<matrixProduct_generic_v<T>>(
                       [&](auto id)
                       {
                           matrixProduct_generic(id(AB), id(A), id(B));
                       })
                       .else_([&](auto id)
                              {
                                  matrixProduct_undefined(id(AB), id(A), id(B));
                              });
               });
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
