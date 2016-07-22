#pragma once

#include "dispatch.hpp"

#include <iostream>

namespace Foo
{
  namespace Internal
  {
    template <typename T>
    void ns_foo(const Dispatch<MethodEnum::Default>&, const T&)
    {
      std::cerr << "\n" << __PRETTY_FUNCTION__;
    }
  }

  template <typename T>
  void foo_version_ns(const T& t)
  {
    using Internal::ns_foo;

    ns_foo(Dispatch<MethodEnum::END>(), t);
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  template <typename T>
  void __internal__foo(const Dispatch<MethodEnum::Default>&, const T&)
  {
    std::cerr << "\n" << __PRETTY_FUNCTION__;
  }

  template <typename T>
  void foo_version_internal(const T& t)
  {
    __internal__foo(Dispatch<MethodEnum::END>(), t);
  }
}
