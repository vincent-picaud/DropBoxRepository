

# ________________________________________________________________

function scale(λ::Int,Ω::UnitRange)
    ifelse(λ>0,
           UnitRange(λ*start(Ω),λ*last(Ω)),
           UnitRange(λ*last(Ω),λ*start(Ω)))
end

function compute_Ωγ1(Ωα::UnitRange,
                   λ::Int,
                   Ωβ::UnitRange)
    
    λΩα = scale(λ,Ωα)

    UnitRange(start(Ωβ)-start(λΩα),
              last(Ωβ)-last(λΩα))
end

function compute_Ωγ2(Ωα::UnitRange,
                   λ::Int,
                   Ωβ::UnitRange)
    
    λΩα = scale(λ,Ωα)

    UnitRange(start(Ωβ)-last(λΩα),
              last(Ωβ)-start(λΩα))
end

# Left & Right relative complements A\B
function relelativeComplement_left(A::UnitRange,B::UnitRange)
    UnitRange(start(A),min(last(A),start(B)-1))
end

function relelativeComplement_right(A::UnitRange,B::UnitRange)
    UnitRange(max(start(A),last(B)+1),last(A))
end

#________________________________________________________________

function boundaryExtension_zeroPadding{T}(β::StridedVector{T},
                                          k::Int)
    return (k>=1)&&(k<=length(β)) ? β[k] : T(0)
end

#________________

function boundaryExtension_constant{T}(β::StridedVector{T},
                                       k::Int)
    if k<1
        β[1]
    elseif k<=length(β)
        β[k]
    else
        β[length(β)]
    end
end


boundaryExtension = Dict(:ZeroPadding=>boundaryExtension_zeroPadding,
                         :Constant=>boundaryExtension_constant)


function direct_conv!{T}(α::StridedVector{T},
                         Ωα::UnitRange,
                         λ::Int,
                         β::StridedVector{T},
                         γ::StridedVector{T},
                         Ωγ::UnitRange,
                         LeftBoundary::Symbol,
                         RightBoundary::Symbol)
    
    # Initialization
    Ωβ = UnitRange(1,length(β))
    tilde_Ωα = 1:length(Ωα)
    
    fill!(γ,T(0))

    rΩγ1=intersect(Ωγ,compute_Ωγ1(Ωα,λ,Ωβ))
    rΩγ2=intersect(Ωγ,compute_Ωγ2(Ωα,λ,Ωβ))

    # rΩγ1 part: no boundary effect
    #
    offset = λ*(start(Ωα)-1)
    for k in rΩγ1
        for i in tilde_Ωα
            γ[k]+=α[i]*β[k+λ*i+offset]
        end
    end

    # Left part
    #
    left_rΩγ2 = relelativeComplement_left(rΩγ2,rΩγ1)
    Φ_left = boundaryExtension[LeftBoundary]
    
    for k in left_rΩγ2
        for i in tilde_Ωα
            γ[k]+=α[i]*Φ_left(β,k+λ*i+offset)
        end
    end

    # Right part
    #
    right_rΩγ2 = relelativeComplement_right(rΩγ2,rΩγ1)
    Φ_right = boundaryExtension[RightBoundary]
    
    for k in right_rΩγ2
        for i in tilde_Ωα
            γ[k]+=α[i]*Φ_right(β,k+λ*i+offset)
        end
    end
end


function direct_conv!{T}(α::StridedVector{T},
                         α_offset::Int,λ::Int,

                         β::StridedVector{T},

                         γ::StridedVector{T},
                         Ωγ::UnitRange,
                         
                         LeftBoundary::Symbol,
                         RightBoundary::Symbol)

    direct_conv!(α,
                 UnitRange(-α_offset,-α_offset+length(α)-1),
                 λ,
                 β,
                 γ,
                 LeftBoundary,
                 RightBoundary)
end

function direct_conv{T}(α::StridedVector{T},
                        α_offset::Int,λ::Int,

                        β::StridedVector{T},

                        LeftBoundary::Symbol,
                        RightBoundary::Symbol)

    γ = Array{T,1}(length(β))
    
    direct_conv!(α,
                 α_offset,
                 λ,
                 β,
                 γ,
                 LeftBoundary,
                 RightBoundary)

    γ
end

function direct_conv{T}(α::StridedVector{T},Ωα::UnitRange,λ::Int,
                        β::StridedVector{T},
                        LeftBoundary::Symbol,
                        RightBoundary::Symbol)

    γ = Array{T,1}(length(β))
    
    direct_conv!(α,
                 Ωα,
                 λ,
                 β,
                 γ,
                 LeftBoundary,
                 RightBoundary)

    γ
end

function fft_conv{T}(α::StridedVector{T},β::StridedVector{T})
    @assert isodd(length(α)) 
    halfWindow = round(Int,(length(α)-1)/2)
    padded_β = [β[1]*ones(halfWindow); β; β[end]*ones(halfWindow)]
    γ = conv(α[end:-1:1], padded_β)
    return γ[2*halfWindow+1:end-2*halfWindow]
end


# example
nα=11
nβ=200
nγ=3000

α=rand(nα)
β=rand(nβ)
γ=rand(nγ)

@assert isodd(length(α)) 
direct_conv!(α,round(Int,(length(α)-1)/2),1,β,γ,:Constant,:Constant)
γ
