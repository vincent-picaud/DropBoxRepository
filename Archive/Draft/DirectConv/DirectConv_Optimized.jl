# Attention: do not modify me, tangled from directConv.org
module DirectConv

function scale(λ::Int64,Ω::UnitRange)
    ifelse(λ>0,
           UnitRange(λ*start(Ω),λ*last(Ω)),
           UnitRange(λ*last(Ω),λ*start(Ω)))
end

function compute_Ωγ1(Ωα::UnitRange,
                     λ::Int64,
                     Ωβ::UnitRange)
    
    λΩα = scale(λ,Ωα)

    UnitRange(start(Ωβ)-start(λΩα),
              last(Ωβ)-last(λΩα))
end

function compute_Ωγ2(Ωα::UnitRange,
                     λ::Int64,
                     Ωβ::UnitRange)
    
    λΩα = scale(λ,Ωα)

    UnitRange(start(Ωβ)-last(λΩα),
              last(Ωβ)-start(λΩα))
end

# Left & Right relative complements A\B
#
function relelativeComplement_left(A::UnitRange,
                                   B::UnitRange)
    UnitRange(start(A),
              min(last(A),start(B)-1))
end

function relelativeComplement_right(A::UnitRange,
                                    B::UnitRange)
    UnitRange(max(start(A),last(B)+1),
              last(A))
end

function boundaryExtension_zeroPadding{T}(β::StridedVector{T},
                                          k::Int64)
    if (k>=1)&&(k<=length(β))
        β[k]
    else
        T(0)
    end
end

function boundaryExtension_constant{T}(β::StridedVector{T},
                                       k::Int64)
    if k<1
        β[1]
    elseif k<=length(β)
        β[k]
    else
        β[length(β)]
    end
end

function boundaryExtension_periodic{T}(β::StridedVector{T},
                                       k::Int64)
    β[1+mod(k-1,length(β))]
end

function boundaryExtension_mirror{T}(β::StridedVector{T},
                                     k::Int64)
    β[length(β)-abs(length(β)-1-mod(k-1,2*(length(β)-1)))]
end

# For the user interface
#
boundaryExtension = Dict(:ZeroPadding=>boundaryExtension_zeroPadding,
                         :Constant=>boundaryExtension_constant,
			 :Periodic=>boundaryExtension_periodic,
			 :Mirror=>boundaryExtension_mirror)

function direct_conv!{T}(tilde_α::StridedVector{T},
                         Ωα::UnitRange,
                         λ::Int64,
                         β::StridedVector{T},
                         γ::StridedVector{T},
                         Ωγ::UnitRange,
                         LeftBoundary::Symbol,
                         RightBoundary::Symbol)
    # Sanity check
    @assert λ!=0
    @assert length(tilde_α)==length(Ωα)
    @assert (start(Ωγ)>=1)&&(last(Ωγ)<=length(γ))

    # Initialization
    const Ωβ = UnitRange(1,length(β))
    const tilde_Ωα = 1:length(Ωα)
    
    for k in Ωγ
        γ[k]=0 
    end

    rΩγ1=intersect(Ωγ,compute_Ωγ1(Ωα,λ,Ωβ))
    
    # rΩγ1 part: no boundary effect
    #
    const β_offset = λ*(start(Ωα)-1)

    @simd for k in rΩγ1
        for i in tilde_Ωα
            @inbounds γ[k]+=tilde_α[i]*β[k+λ*i+β_offset]
        end
    end

    # Left part
    #
    const rΩγ1_left = relelativeComplement_left(Ωγ,rΩγ1)
    const Φ_left = boundaryExtension[LeftBoundary]
    
    for k in rΩγ1_left
        for i in tilde_Ωα
            @inbounds γ[k]+=tilde_α[i]*Φ_left(β,k+λ*i+β_offset)
        end
    end

    # Right part
    #
    const rΩγ1_right = relelativeComplement_right(Ωγ,rΩγ1)
    const Φ_right = boundaryExtension[RightBoundary]
    
    @simd for k in rΩγ1_right
        for i in tilde_Ωα
            @inbounds γ[k]+=tilde_α[i]*Φ_right(β,k+λ*i+β_offset)
        end
    end
end

# Some UI functions, γ inplace modification 
#
function direct_conv!{T}(tilde_α::StridedVector{T},
                         α_offset::Int64,
			 λ::Int64,

                         β::StridedVector{T},

                         γ::StridedVector{T},
                         Ωγ::UnitRange,
                         
                         LeftBoundary::Symbol,
                         RightBoundary::Symbol)

    Ωα = UnitRange(-α_offset,
                   length(tilde_α)-α_offset-1)
    
    direct_conv!(tilde_α,
                 Ωα,
                 λ,
                 
		 β,

                 γ,
                 Ωγ,

		 LeftBoundary,
                 RightBoundary)
end

function direct_conv{T}(tilde_α::StridedVector{T},
                        α_offset::Int64,
			λ::Int64,

                        β::StridedVector{T},

                        LeftBoundary::Symbol,
                        RightBoundary::Symbol)

    γ = Array{T,1}(length(β))
    
    direct_conv!(tilde_α,
                 α_offset,
                 λ,

                 β,

                 γ,
		 UnitRange(1,length(γ)),

                 LeftBoundary,
                 RightBoundary)

    γ
end

export direct_conv
export direct_conv!

end
