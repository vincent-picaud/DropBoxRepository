// Compile with
// clang++ -std=c++11 main_ok.cpp -o main_ok; ./main _ok

#include "foo_ok.hpp"
#include "foo_double_ok.hpp"

using namespace Foo;

int main()
{
  foo_version_ns_ok(1.0);         // Print void Foo::Internal::ns_foo_ok(const Dispatch<MethodEnum::Default> &, const T &) [T = double]

  return 0;
}
