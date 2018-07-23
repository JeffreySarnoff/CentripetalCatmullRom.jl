@inline clamp01(x::T) where {T<:Real} = clamp(x, zero(T), one(T))

"""
    into01((xs...,))

maps values into 0.0:1.0 (minimum(xs) --> 0.0, maximum(xs) --> 1.0)
"""
function into01(values::U) where {N,T, U<:Union{NTuple{N,T}, Vector{T}}}
    mn, mx = minimum(values), maximum(values)
    delta = mx .- mn
    delta = sqrt(sum(map(x->x*x, delta)))
    result = collect(clamp01((v .- mn)./delta) for v in values)
    return result
end


# uniform separation in 0..1 inclusive
uniformsep(n::Int) = n >= 2 ? collect(0.0:inv(n-1):1.0) : throw(DomainError("$n < 2"))

# chebyshev T(x) zeros in 0..1 inclusive
chebyshevsep(n::Int) = n >= 2 ? cheb1zerosᵤ(n) : throw(DomainError("$n < 2"))

# roots of Chebyshev polynomials (types 1,2,3,4)

# zeros of T(x)

cheb1zero(n,k) = cospi((n-k+0.5)/n)
cheb1zeros(n) = [cheb1zero(n,k) for k=1:n]

# shifted into 0..1
cheb1zero_shifted(n,k) = (cospi((n-k+0.5)/n) + 1)/2
cheb1zeros_shifted(n) = [cheb1zero_shifted(n,k) for k=1:n]

# includes 0,1 as first, last
shifted_cheb1zeros(n) = [0.0, [cheb1zero_shifted(n-2,k) for k=1:n-2]..., 1.0]

# zeros of U(x)

cheb2zero(n,k) = cospi((n-k+1)/(n+1))
cheb2zeros(n) = [cheb2zero(n,k) for k=1:n]

# shifted into 0..1
cheb2zeroₛ(n,k) = (cospi((n-k+1)/(n+1)) + 1)/2
cheb2zerosₛ(n) = [cheb2zeroₛ(n,k) for k=1:n]

# includes 0,1 as first, last
shifted_cheb2zeros(n) = [0.0, [cheb2zeroₛ(n-2,k) for k=1:n-2]..., 1.0]

# zeros of V(x)

cheb3zero(n,k) = cospi((n-k+0.5)/(n+0.5))
cheb3zeros(n) = [cheb3zero(n,k) for k=1:n]

# shifted into 0..1
cheb3zero_shifted(n,k) = (cospi((n-k+0.5)/(n+0.5)) + 1)/2
cheb3zeros_shifted(n) = [cheb3zero_shifted(n,k) for k=1:n]

# includes 0,1 as first, last
shifted_cheb3zeros(n) = [0.0, [cheb3zero_shifted(n-2,k) for k=1:n-2]..., 1.0]

# zeros of W(x)

cheb4zero(n,k) = cospi((n-k+1)/(n+0.5))
cheb4zeros(n) = [cheb4zero(n,k) for k=1:n]

# shifted into 0..1
cheb4zero_shifted(n,k) = (cospi((n-k+1)/(n+0.5)) + 1)/2
cheb4zeros_shifted(n) = [cheb4zero_shifted(n,k) for k=1:n]

# includes 0,1 as first, last
shifted_cheb4zeros(n) = [0.0, [cheb4zero_shifted(n-2,k) for k=1:n-2]..., 1.0]


# extrema of _weighted_ Chebyshev polynomials (types 1,2,3,4)
# includes reverse order 1-extrema with extrema 

# extrema of T(x)

cheb1extrema(n,k) = cospi((n-k)/n)
cheb1extrema(n) = [cheb1extrema(n-1,k) for k=0:n-1]

# shifted into 0,1
cheb1extrema_shifted(n,k) = (cospi((n-k)/n) + 1)/2
cheb1extrema_shifted(n) = [cheb1extrema_shifted(n-1,k) for k=0:n-1]

# includes 0,1 as first, last
shifted_cheb1extrema(n) = [cheb1extrema_shifted(n-1,k) for k=0:n-1]

# extrema of sqrt(1-x^2) * U(x)

cheb2extrema(n,k) = cospi((2*(n-k)+1)/(2*(n+1)))
cheb2extrema(n) = [cheb2extrema(n-1,k) for k=0:n-1]

# shifted into 0,1
cheb2extrema_shifted(n,k) = (cospi((2*(n-k)+1)/(2*(n+1)))+1)/2
cheb2extrema_shifted(n) = [cheb2extrema_shifted(n-1,k) for k=0:n-1]

# includes 0,1 as first, last
shifted_cheb2extremaᵤ(n) = [0.0, [cheb2extrema_shifted(n-3,k) for k=0:n-3]..., 1.0]


# extrema of sqrt(1+x) * V(x)

cheb3extrema(n,k) = cospi((2*(n-k))/(2*n+1))
cheb3extrema(n) = [cheb3extrema(n,k) for k=0:n-1]

# shifted into 0,1
cheb3extrema_shifted(n,k) = (cospi((2*(n-k))/(2*n+1)) + 1)/2
cheb3extrema_shifted(n) = [cheb3extrema_shifted(n,k) for k=0:n-1]

# includes 0,1 as first, last
shifted_cheb3extrema(n) = [0.0, [cheb3extrema_shifted(n-2,k) for k=0:n-3]..., 1.0]

# extrema of sqrt(1-x) * W(x)

cheb4extrema(n,k) = cospi((2*(n-k)+1)/(2*n+1))
cheb4extrema(n) = [cheb4extrema(n,k) for k=1:n]

# shifted into 0,1
cheb4extrema_shifted(n,k) = (cospi((2*(n-k)+1)/(2*n+1)) + 1)/2
cheb4extrema_shifted(n) = [cheb4extrema_shifted(n,k) for k=1:n]

# includes 0,1 as first, last
shifted_cheb4extrema(n) = [0.0, [cheb4extrema_shifted(n-2,k) for k=1:n-2]..., 1.0]
