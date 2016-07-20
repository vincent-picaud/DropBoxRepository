using DirectConv

α=Float64[0,0,1]
β=zeros(5)

γ=zeros(10)
Ωγ=UnitRange(1,10)

direct_conv(α,0,1,β,:Mirror,:Periodic)
