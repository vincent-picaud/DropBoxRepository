
function direct_conv!{T}(α::StridedVector{T},λ::Int,
                         β::StridedVector{T},
                         γ::StridedVector{T})

    for k in [1:length(γ)]
        for i in [1:length(α)]
            γ[k]+=α[i]*β[k+i*λ]
        end
    end
        
end

function test_direct_conv!{T}(α::StridedVector{T},α_min::Int,λ::Int,
                             β::StridedVector{T},
                             γ::StridedVector{T})
    
    for k in 1:length(γ);
        for i in 1:length(α);
            γ[k]+=α[i]*β[k+i*λ+λ*(α_min-1)+1]
            print("\n$k : $(γ[k])")
        end
    end
        
end

function direct_conv!{T}(α::StridedVector{T},α_range::UnitRange,λ::Int,
                         β::StridedVector{T},β_range::UnitRange,
                         γ::StridedVector{T},γ_range::UnitRange)

    # sanity check
    # @assert in(UnitRange(1,length(γ)),γ_range) "bad γ range $γ_range"
    
    # Avoid the complications of λ<0
    negative_λ=false
    
    if λ<0
        negative_λ=true
        reverse!(α)
        α_range=UnitRange(-last(α_range),-start(α_range))
    end

    
    fill!(γ[γ_range],T(0))

    Ωγ2=UnitRange(start(β_range)-λ*last(α_range),
                 last(β_range)-λ*start(α_range))

    rΩγ2=intersect(γ_range,Ωγ2)
    
    if !isempty(rΩγ2)
        
        Ωγ1=UnitRange(start(β_range)-λ*start(α_range),
                     last(β_range)-λ*last(α_range))

        rΩγ1=intersect(γ_range,Ωγ1)

      
        Ωβ = β_range+λ*(start(α_range)-first_idx)-first_idx
        
        print("$α_range $Ωβ $rΩγ1")

        test_direct_conv!(α,start(α_range),λ, β,  γ[rΩγ1])
    end
    
    if  negative_λ
        reverse!(α)
    end
end

function direct_conv!{T}(α::StridedVector{T},α_offset::Int,λ::Int,
                         β::StridedVector{T},
                         γ::StridedVector{T})

    direct_conv!(α,UnitRange(-α_offset,length(α)),λ,
                 β,UnitRange(1,length(β)),
                 γ,UnitRange(1,length(γ)))
end

# example
α=[1:3;]
β=[1:10;]
γ=[1:20;]

direct_conv!(α,1,1,β,γ)

