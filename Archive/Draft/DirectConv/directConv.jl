
function direct_conv!{T}(α::StridedVector{T},λ::Int,
                         β::StridedVector{T},
                         γ::StridedVector{T})

    for k in [1:length(γ)]
        for i in [1:length(α)]
            γ[k]+=α[i]*β[k+i*λ]
        end
    end
        
end

function direct_conv!{T}(α::StridedVector{T},α_range::UnitRange,λ::Int,
                         β::StridedVector{T},β_range::UnitRange,
                         γ::StridedVector{T},γ_range::UnitRange)
    negative_λ=false
    
    if λ<0
        negative_λ=true
        reverse!(α)
        α_range=UnitRange(-last(α_range),-start(α_range))
    end

    fill!(γ[γ_range],T(0))

    Ω2=UnitRange(start(β_range)-λ*last(α_range),
                 last(β_range)-λ*start(α_range))

    rΩ2=intersect(γ_range,Ω2)
    
    if !isempty(rΩ2)
        
        Ω1=UnitRange(start(β_range)-λ*start(α_range),
                     last(β_range)-λ*last(α_range))

        rΩ1=intersect(γ_range,Ω1)
        
        print("$Ω1 $Ω2 $rΩ1 $rΩ2")

        print("\n range $(β_range-start(rΩ1)-λ*start(α_range))")
        direct_conv!(α,λ, β[β_range-start(rΩ1)-λ*start(α_range)+1],  γ[rΩ1])
    end
    
    if  negative_λ
        reverse!(α)
    end
end

function direct_conv!{T}(α::StridedVector{T},α_offset::Int,λ::Int,
                         β::StridedVector{T},
                         γ::StridedVector{T})
    direct_conv!(α,UnitRange(1,length(α))-α_offset,λ,
                 β,UnitRange(1,length(β)),
                 γ,UnitRange(1,length(γ)))
end

# example
α=[1:3;]
β=[1:10;]
γ=[1:20;]


direct_conv!(α,1,1,β,γ)

