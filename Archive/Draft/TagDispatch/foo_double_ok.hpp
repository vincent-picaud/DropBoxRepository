#pragma once

#include "foo_ok.hpp"

namespace Foo
{
  namespace Internal
  {
    void ns_foo_ok(const Dispatch<MethodEnum::A>&, const double&)
    {
      std::cerr << "\n" << __PRETTY_FUNCTION__;
    }
  }
}
