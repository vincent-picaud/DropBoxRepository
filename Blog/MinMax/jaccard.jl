function jaccard_julia_NaN_aware(a::Array{Float64,1},
                                 b::Array{Float64,1})

    @assert length(a)==length(b) 

    num::Float64 = 0
    den::Float64 = 0

    for i in 1:length(a)

        @inbounds num += min(a[i],b[i])
        @inbounds den += max(a[i],b[i])

    end
    return 1. - num/den
end

function jaccard_julia_comparison(a::Array{Float64,1},
                                  b::Array{Float64,1})

    @assert length(a)==length(b) 

    num::Float64 = 0
    den::Float64 = 0

    for i in 1:length(a)

        @inbounds num += ifelse(a[i]<b[i],a[i],b[i])
        @inbounds den += ifelse(a[i]>b[i],a[i],b[i])

    end
    return 1. - num/den
end

function jaccard_C_NaN_aware(a::Array{Float64,1},
                             b::Array{Float64,1})

    @assert length(a)==length(b) 

    return ccall((:jaccard_C_NaN_aware,
                  "./libjaccard.so"),
                 Float64,
                 (Int64,Ptr{Float64},Ptr{Float64}),
                 length(a),a,b)

end

function jaccard_C_comparison(a::Array{Float64,1},
                              b::Array{Float64,1})

    @assert length(a)==length(b) 

    return ccall((:jaccard_C_comparison,
                  "./libjaccard.so"),
                 Float64,
                 (Int64,Ptr{Float64},Ptr{Float64}),
                 length(a),a,b)

end

function test_distance(f,
                       v1::Array{Float64,1},
                       v2::Array{Float64,1})
    sum=0
    for i in 1:5000
        sum+=f(v1,v2)
    end
    sum
end

v1=rand(10000);
v2=rand(10000);

for name in (:jaccard_julia_NaN_aware,
             :jaccard_C_NaN_aware,
             :jaccard_julia_comparison,
             :jaccard_C_comparison)
    print("$name")
    @time @eval test_distance($name,v1,v2)
end
