
function vandermonde(halfWindow::Int, polyDeg::Int,T::Type=Float64)

    @assert halfWindow>=0
    @assert polyDeg>=0

    x=T[i for i in -halfWindow:halfWindow]

    n = polyDeg+1
    m = length(x)
    
    V = Array{T}(m, n)
    
    for i = 1:m
        V[i,1] = T(1)
    end
    for j = 2:n
        for i = 1:m
            V[i,j] = x[i] * V[i,j-1]
        end
    end

    return V
end
    
function SG(halfWindow::Int, polyDeg::Int,T::Type=Float64)

    @assert 2*halfWindow>polyDeg
    
    V=vandermonde(halfWindow,polyDeg,T)
    Q,R=qr(V)
    SG=R\Q'

    for i in 1:size(SG,1)
        SG[i,:]*=factorial(i-1)
    end
    
    return SG'
end

function apply_filter{T}(filter::StridedVector{T},signal::StridedVector{T})

    @assert isodd(length(filter))

    halfWindow = round(Int,(length(filter)-1)/2)
    
    padded_signal = [signal[1]*ones(halfWindow); signal; signal[end]*ones(halfWindow)]
    filter_cross_signal = conv(filter[end:-1:1], padded_signal)

    return filter_cross_signal[2*halfWindow+1:end-2*halfWindow]
end

#________________________________________________________________

s=readdlm("signal.txt")[:,1]
sg=SG(20,3)
smoothed_s=apply_filter(sg[:,1],s)
