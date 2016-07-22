#pragma once

#include "foo.hpp"

namespace Foo
{
  namespace Internal
  {
    void ns_foo(const Dispatch<MethodEnum::A>&, const double&)
    {
      std::cerr << "\n" << __PRETTY_FUNCTION__;
    }
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  void __internal__foo(const Dispatch<MethodEnum::A>&, const double&)
  {
    std::cerr << "\n" << __PRETTY_FUNCTION__;
  }
}
