module Kunisch

import Base.LinAlg.BlasFloat


# [Modify_Qq]
const active_lb = -1::Int
const inactive = 0::Int
const active_ub = +1::Int

function restrict2Active!{T<:BlasFloat,S<:StridedMatrix}(Q::Symmetric{T,S},
                                                         q::StridedVector{T},
                                                         Z::StridedVector{Int},
                                                         lb::StridedVector{T},
                                                         ub::StridedVector{T}) 
    
    const n = length(q)

    @assert (Q.uplo=='L')||(Q.uplo=='U') "Q.uplo==$(Q.uplo)"
    
    if Q.uplo=='L'

        for k = 1:n
            
            if Z[k]!=inactive

                const constrained_x_k = ifelse(Z[k]==active_lb,
                                               lb[k],
                                               ub[k])

                
                q[1:k-1] += constrained_x_k*Q.data[k,1:k-1]'
                Q.data[k,1:k-1]=zero(T)

                Q_kk = max(1,abs(Q.data[k,k]))
                q[k] = -constrained_x_k*Q_kk
                Q.data[k,k] = Q_kk
                
                q[k+1:n] += constrained_x_k*Q.data[k+1:n,k]
                Q.data[k+1:n,k]=zero(T)
                
            end # Z[k]!=inactive
        end # k = 1:n

    else         
        @assert (Q.uplo=='U') ""
        
        for k = 1:n
            
            if Z[k]!=inactive

                const constrained_x_k = ifelse(Z[k]==active_lb,
                                               lb[k],
                                               ub[k])

                
                q[1:k-1] += constrained_x_k*Q.data[1:k-1,k]
                Q.data[1:k-1,k]=zero(T)

                Q_kk = max(1,abs(Q.data[k,k]))
                q[k] = -constrained_x_k*Q_kk
                Q.data[k,k] = Q_kk
                
                q[k+1:n] += constrained_x_k*Q.data[k,k+1:n]'
                Q.data[k,k+1:n]=zero(T)

            end # Z[k]!=inactive
        end # k = 1:n
        
    end
    
end
# [Modify_Qq]

# [UpdateZ]
function updateZ!{T<:BlasFloat}(x::StridedVector{T},
                                tau::StridedVector{T},
                                Z::StridedVector{Int},
                                lb::StridedVector{T},
                                ub::StridedVector{T})

    const n = length(x)

    count_bad_hypothesis = 0
    
    for i in 1:n

        if Z[i]==inactive

            if x[i]<=lb[i]

                count_bad_hypothesis+=1
                Z[i]=active_lb
                
            elseif x[i]>=ub[i]
                
                count_bad_hypothesis+=1
                Z[i]=active_ub
                
            end
            
        elseif Z[i]==active_lb
            
            @assert  x[i]==lb[i] "Internal error $(x[i]) != $(lb[i])"
            
            if tau[i]>0
                count_bad_hypothesis+=1
                Z[i]=inactive
            end

        else
            
          @assert  x[i]==ub[i] "Internal error $(x[i]) != $(ub[i])"
            
            if tau[i]<0
                count_bad_hypothesis+=1
                Z[i]=inactive
            end
            
        end 
        
    end #  for i in 1:n

    return count_bad_hypothesis
end
# [UpdateZ]

# [Kunisch]
function kunisch{T<:BlasFloat,S<:StridedMatrix}(Q::Symmetric{T,S},
                                                q::StridedVector{T},
                                                lb::StridedVector{T},
                                                ub::StridedVector{T},
                                                maxIter::Int = 50,
                                                k0::Int = 6,
                                                c0::T=0.1)
    const n = length(q)

    
    @assert ((n==length(lb))&&
             (n==length(ub))&&
             ((n,n)==size(Q))) "Bad dimension"

    @assert count(x->!x,0.<=ub-lb)==0 "Incoherent bounds"

    x=copy(lb)
    x=min(x,ub)
    Z=map(x->ifelse(isfinite(x),active_lb,inactive),x)

    for iter in 1:maxIter

        # [Solution]
        Q_tilde=copy(Q)
        q_tilde=copy(q)

        if iter<=k0
            mu::T=c0*norm(Q,Inf)/2^iter
            for i in 1:n Q_tilde.data[i,i]+=mu end
        end

        restrict2Active!(Q_tilde,q_tilde,Z,lb,ub)

        x=-1*(Q_tilde\q_tilde);
        tau=-1*(Q*x+q)
        # [Solution]


        count_bad_hypothesis = updateZ!(x,tau,Z,lb,ub);
        
        print("\niter $iter count $count_bad_hypothesis")
        
        if (iter>k0)&&(count_bad_hypothesis == 0)
            print("\nConverged!")
            return x,tau
        end
        
    end # iter
    
    error("\nDid not converged! \n$x")
    
end
# [Kunisch]

export kunisch

end
