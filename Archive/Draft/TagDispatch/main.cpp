// Compile with
// clang++ -std=c++11 main.cpp -o main; ./main 

#include "foo.hpp"
#include "foo_double.hpp"

using namespace Foo;

int main()
{
  foo_version_ns(1.0);         // Print void Foo::Internal::ns_foo(const Dispatch<MethodEnum::Default> &, const T &) [T = double]
  foo_version_internal(1.0);   // Print void Foo::__internal__foo(const Dispatch<MethodEnum::A> &, const double &)
  
  return 0;
}
