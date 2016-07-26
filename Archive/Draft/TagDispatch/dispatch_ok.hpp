#pragma once

#include <type_traits>

namespace Foo
{

    enum class MethodEnum
    {
        Default = 0,
        A,
        B,
        END
    };

    template <typename E>
    constexpr typename std::underlying_type<E>::type to_underlying(E e)
    {
        return static_cast<typename std::underlying_type<E>::type>(e);
    }

    namespace Internal
    {
        template <MethodEnum METHOD>
        struct Dispatch : Dispatch<MethodEnum(to_underlying(METHOD) - 1)>
        {
        };

        template <>
        struct Dispatch<MethodEnum::Default>
        {
        };
    }
}
