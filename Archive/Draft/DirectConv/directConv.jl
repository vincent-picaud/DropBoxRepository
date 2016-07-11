
function compute_direct_conv!{T}(α::StridedVector{T},λ::Int,
                                 β::StridedVector{T},
                                 γ::StridedVector{T})

    for k in [1:length(γ)]
        for i in [1:length(α)]
            γ[k]+=α[i]*β[k+i*λ]
        end
    end
    
end


# ________________________________________________________________

function scale(λ::Int,range::UnitRange)
    ifelse(λ>0,
           UnitRange(λ*start(range),λ*last(range)),
           UnitRange(λ*last(range),λ*start(range)))
end

function Ωγ1_range(α_range::UnitRange,
                   λ::Int,
                   β_range::UnitRange)
    
    λα_range = scale(λ,α_range)

    UnitRange(start(β_range)-start(λα_range),last(β_range)-last(λα_range))
end

function Ωγ2_range(α_range::UnitRange,
                   λ::Int,
                   β_range::UnitRange)
    
    λα_range = scale(λ,α_range)

    UnitRange(start(β_range)-last(λα_range),last(β_range)-start(λα_range))
end

# Left & Right relative complement A\B
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
                         α_range::UnitRange,
                         λ::Int,
                         β::StridedVector{T},
                         γ::StridedVector{T},
                         LeftBoundary::Symbol,
                         RightBoundary::Symbol)
    
    # sanity check
    # @assert in(UnitRange(1,length(γ)),γ_range) "bad γ range $γ_range"

#    const first_idx = Int(1) # in C is 0
    
    # Avoid the complications of λ<0
    #
    negative_λ=false

    if λ<0
        negative_λ=true
        λ=-λ
        reverse!(α)
        α_range=UnitRange(-last(α_range),-start(α_range))
    end

    # Initialization
    β_range = UnitRange(1,length(β))
    γ_range = UnitRange(1,length(γ))
    tilde_α_range = 1:length(α_range)
    
    fill!(γ,T(0))

    rΩγ1=intersect(γ_range,Ωγ1_range(α_range,λ,β_range))
    rΩγ2=intersect(γ_range,Ωγ2_range(α_range,λ,β_range))

#    print("$α_range $rΩγ1 $rΩγ2")

    # rΩγ1 part: no boundary effect
    #
    
    
    offset = λ*(start(α_range)-1)
    for k in rΩγ1
        for i in tilde_α_range
            γ[k]+=α[i]*β[k+λ*i+offset]
        end
    end

    # Left part (bounday effect)
    #
    left_rΩγ2 = relelativeComplement_left(rΩγ2,rΩγ1)
    left_β = boundaryExtension[LeftBoundary]
    
    for k in left_rΩγ2
#        print("Left $k")
        for i in tilde_α_range
            γ[k]+=α[i]*left_β(β,k+λ*i+offset)
        end
    end

    # Right part (bounday effect)
    #
    right_rΩγ2 = relelativeComplement_right(rΩγ2,rΩγ1)
    right_β = boundaryExtension[RightBoundary]
    
    for k in right_rΩγ2
 #       print("Right $k")
        for i in tilde_α_range
            γ[k]+=α[i]*right_β(β,k+λ*i+offset)
        end
    end

    # Restore initial α

    #
    if  negative_λ
        reverse!(α)
    end
end


function direct_conv!{T}(α::StridedVector{T},α_offset::Int,λ::Int,
                         β::StridedVector{T},
                         γ::StridedVector{T},
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

function direct_conv{T}(α::StridedVector{T},α_offset::Int,λ::Int,
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

function direct_conv{T}(α::StridedVector{T},α_range::UnitRange,λ::Int,
                        β::StridedVector{T},
                        LeftBoundary::Symbol,
                        RightBoundary::Symbol)

    γ = Array{T,1}(length(β))
    
    direct_conv!(α,
                 α_range,
                 λ,
                 β,
                 γ,
                 LeftBoundary,
                 RightBoundary)

    γ
end

function fft_conv{T}(α::StridedVector{T},β::StridedVector{T})
    @assert isodd(length(α)) ""
    halfWindow = round(Int,(length(α)-1)/2)
    padded_β = [β[1]*ones(halfWindow); β; β[end]*ones(halfWindow)]
    γ = conv(α[end:-1:1], padded_β)
    return γ[2*halfWindow+1:end-2*halfWindow]
end


# example
α=[0,1,0]
β=[1:10;]
γ=[1:20;]

direct_conv!(α,1,1,β,γ,:Constant,:Constant)
γ
