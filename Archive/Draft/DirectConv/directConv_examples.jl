workspace()
include("/home/picaud/GitHub/DropBoxRepository/Archive/Draft/DirectConv/DirectConv.jl")

using DirectConv

α=Float64[0,0,1]
β=Float64[1:5;]

γ=zeros(10)
Ωγ=UnitRange(1,10)

#direct_conv!(α,2,1,β,γ,Ωγ,:Mirror,:Periodic)
direct_conv!(α,2,1,β,γ,Ωγ,:Periodic,:Mirror)

#direct_conv(α,2,1,β,:ZeroPadding,:ZeroPadding)

