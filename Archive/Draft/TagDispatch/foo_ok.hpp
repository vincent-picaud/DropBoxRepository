#pragma once

#include "dispatch_ok.hpp"

#include <iostream>

namespace Foo
{
    namespace Internal
    {
        template <typename T>
        void ns_foo_ok(const Dispatch<MethodEnum::Default>&, const T&)
        {
            std::cerr << "\n" << __PRETTY_FUNCTION__;
        }
    }

    template <typename T>
    void foo_version_ns_ok(const T& t)
    {
        ns_foo_ok(Internal::Dispatch<MethodEnum::END>(), t);
    }
}
