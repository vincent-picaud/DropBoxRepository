workspace()
include("./DirectConv.jl")

using DirectConv

T = Int

α=T[0,0,1]
β=T[1:5;]

γ=zeros(T,10)
Ωγ=UnitRange(1,10)

direct_conv!(α,20,1,β,γ,Ωγ,:Periodic,:Periodic)
γ
#direct_conv!(α,2,1,β,γ,Ωγ,:Periodic,:Mirror)

#direct_conv(α,2,1,β,:ZeroPadding,:ZeroPadding)

function create_directConvMatrix{T}(α::StridedVector{T},
                                    α_offset::Int,λ::Int,
                                    Nβ::Int,Nγ::Int,
                                    LeftBoundary::Symbol,
                                    RightBoundary::Symbol)
    M=T[0 for i in 1:Nγ,j in 1:Nβ]

    β=zeros(T,Nβ)
    Ωγ=UnitRange(1,Nγ)
    γ=zeros(T,Nγ)
    
    for j in 1:Nβ
        fill!(β,T(0))
        β[j]=1
        direct_conv!(α,α_offset,λ,
                     β,
                     γ,
                     Ωγ,
                     LeftBoundary,RightBoundary)
        M[:,j]=γ
    end

    M
end
