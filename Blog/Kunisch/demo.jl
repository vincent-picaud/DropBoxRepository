include("./kunisch.jl")
using Kunisch

T=Float64

n=25::Int

lb=Array{T}(n)
lb[:]=0

ub=Array{T}(n)
ub[:]=10

H=T[1/(i+j-1) for i in 1:n,j in 1:n]

Q=Symmetric(H,:L)
q=Array{T}(n)
q[:]=-1

kunisch(Q,q,lb,ub)
