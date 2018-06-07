# q.v. https://stackoverflow.com/questions/9489736/catmull-rom-curve-with-no-cusps-and-no-self-intersections/23980479#23980479

module CatmullRom

export CentripetalCatmullRom, POINT1D, POINT2D, POINT3D, POINT4D

using Polynomials
import Polynomials: Poly, polyval, polyint, polyder

struct POINT1D{T}
    x::T
end
struct POINT2D{T}
    x::T; y::T
end
struct POINT3D{T}
    x::T; y::T; z::T
end
struct POINT4D{T}
    x::T; y::T; z::T; t::T
end

x(p::POINT1D{T}) where {T} = p.x
x(p::POINT2D{T}) where {T} = p.x
x(p::POINT3D{T}) where {T} = p.x
x(p::POINT4D{T}) where {T} = p.x

y(p::POINT2D{T}) where {T} = p.y
y(p::POINT3D{T}) where {T} = p.y
y(p::POINT4D{T}) where {T} = p.y

z(p::POINT3D{T}) where {T} = p.z
z(p::POINT4D{T}) where {T} = p.z

t(p::POINT4D{T}) where {T} = p.t

dx(p::POINT1D{T}, q::POINT1D{T}) where {T} = x(q) - x(p)
dx(p::POINT2D{T}, q::POINT2D{T}) where {T} = x(q) - x(p)
dx(p::POINT3D{T}, q::POINT3D{T}) where {T} = x(q) - x(p)
dx(p::POINT4D{T}, q::POINT4D{T}) where {T} = x(q) - x(p)

dy(p::POINT2D{T}, q::POINT2D{T}) where {T} = y(q) - y(p)
dy(p::POINT3D{T}, q::POINT3D{T}) where {T} = y(q) - y(p)
dy(p::POINT4D{T}, q::POINT4D{T}) where {T} = y(q) - y(p)

dz(p::POINT3D{T}, q::POINT3D{T}) where {T} = z(q) - z(p)
dz(p::POINT4D{T}, q::POINT4D{T}) where {T} = z(q) - z(p)

dt(p::POINT4D{T}, q::POINT4D{T}) where {T} = t(q) - t(p)

dx2(p::POINT1D{T}, q::POINT1D{T}) where {T} = dx(p, q)^2
dx2(p::POINT2D{T}, q::POINT2D{T}) where {T} = dx(p, q)^2
dx2(p::POINT3D{T}, q::POINT3D{T}) where {T} = dx(p, q)^2
dx2(p::POINT4D{T}, q::POINT4D{T}) where {T} = dx(p, q)^2

dy2(p::POINT2D{T}, q::POINT2D{T}) where {T} = dy(p, q)^2
dy2(p::POINT3D{T}, q::POINT3D{T}) where {T} = dy(p, q)^2
dy2(p::POINT4D{T}, q::POINT4D{T}) where {T} = dy(p, q)^2

dz2(p::POINT3D{T}, q::POINT3D{T}) where {T} = dz(p, q)^2
dz2(p::POINT4D{T}, q::POINT4D{T}) where {T} = dz(p, q)^2

dt2(p::POINT4D{T}, q::POINT4D{T}) where {T} = dt(p, q)^2

# distance squared
dist2(p::POINT1D{T}, q::POINT1D{T}) where {T} = dx2(p, q)
dist2(p::POINT2D{T}, q::POINT2D{T}) where {T} = dx2(p, q) + dy2(p, q)
dist2(p::POINT3D{T}, q::POINT3D{T}) where {T} = dx2(p, q) + dy2(p, q) + dz2(p, q)
dist2(p::POINT4D{T}, q::POINT4D{T}) where {T} = dx2(p, q) + dy2(p, q) + dz2(p, q) + dt2(p, q)


struct CubicPoly{T}
    poly::Poly{T}
    dpoly::Poly{T}
    
    function CubicPoly(c0::T, c1::T, c2::T, c3::T) where {T}
        poly = Poly([c0, c1, c2, c3])
        dpoly = polyder(poly)
        return new{T}(poly, dpoly)
    end    
end

@inline poly(x::CubicPoly{T}) where {T} = x.poly
@inline dpoly(x::CubicPoly{T}) where {T} = x.dpoly

@inline polyval(x::CubicPoly{T}, z::T) where {T} = polyval(poly(x), z)
@inline dpolyval(x::CubicPoly{T}, z::T) where {T} = polyval(dpoly(x), z)

struct CatmullRom{T,N}
    polys::NTuple{N,CubicPoly{T}}
end

function polyval(cr::CatmullRom{T,1}, x::T) where {T}
    p1 = polyval(cr.polys[1].poly, x)
    return (p1,)
end

function polyval(cr::CatmullRom{T,2}, x::T) where {T}
    p1 = polyval(cr.polys[1].poly, x)
    p2 = polyval(cr.polys[2].poly, x)
    return (p1, p2)
end

function polyval(cr::CatmullRom{T,3}, x::T) where {T}
    p1 = polyval(cr.polys[1].poly, x)
    p2 = polyval(cr.polys[2].poly, x)
    p3 = polyval(cr.polys[3].poly, x)
    return (p1, p2, p3)
end

function polyval(cr::CatmullRom{T,4}, x::T) where {T}
    p1 = polyval(cr.polys[1].poly, x)
    p2 = polyval(cr.polys[2].poly, x)
    p3 = polyval(cr.polys[3].poly, x)
    p4 = polyval(cr.polys[4].poly, x)
    return (p1, p2, p3, p4)
end

#=
 * Compute coefficients for a cubic polynomial
 *   p(s) = c0 + c1*s + c2*s^2 + c3*s^3
 * such that
 *   p(0) = x0, p(1) = x1
 *  and
 *   p'(0) = t0, p'(1) = t1.
=#

function coeffcalc(x0::T, x1::T, t0::T, t1::T) where {T<:Number}
    c0 = x0
    c1 = t0
    c2 = -3*x0 + 3*x1 - 2*t0 - t1
    c3 =  2*x0 - 2*x1 +   t0 + t1
    return CubicPoly(c0,c1,c2,c3)
end

# compute coefficients for a nonuniform Catmull-Rom spline
function NonuniformCatmullRom(x0::T, x1::T, x2::T, x3::T, dt0::T, dt1::T, dt2::T) where {T}
    # compute tangents when parameterized in [t1,t2]
    t1 = (x1 - x0) / dt0 - (x2 - x0) / (dt0 + dt1) + (x2 - x1) / dt1
    t2 = (x2 - x1) / dt1 - (x3 - x1) / (dt1 + dt2) + (x3 - x2) / dt2

    # rescale tangents for parametrization in [0,1]
    t1 *= dt1
    t2 *= dt1

    return coeffcalc(x1, x2, t1, t2)
end


function CentripetalCatmullRom(p0::P, p1::P, p2::P, p3::P) where {T, P<:POINT1D{T}}
    d0 = T(sqrt(sqrt(dist2(p0, p1))))
    d1 = T(sqrt(sqrt(dist2(p1, p2))))
    d2 = T(sqrt(sqrt(dist2(p2, p3))))

    # safety check for repeated points
    if (d1 < 1.0e-4)  d1 = T(1.0) end
    if (d0 < 1.0e-4)  d0 = d1 end
    if (d2 < 1.0e-4)  d2 = d1 end

    xcpoly = NonuniformCatmullRom(p0.x, p1.x, p2.x, p3.x, d0, d1, d2)

    return CatmullRom{T,1}((xcpoly,))
end

function CentripetalCatmullRom(p0::P, p1::P, p2::P, p3::P) where {T, P<:POINT2D{T}}
    d0 = T(sqrt(sqrt(dist2(p0, p1))))
    d1 = T(sqrt(sqrt(dist2(p1, p2))))
    d2 = T(sqrt(sqrt(dist2(p2, p3))))

    # safety check for repeated points
    if (d1 < 1.0e-4)  d1 = T(1.0) end
    if (d0 < 1.0e-4)  d0 = d1 end
    if (d2 < 1.0e-4)  d2 = d1 end

    xcpoly = NonuniformCatmullRom(p0.x, p1.x, p2.x, p3.x, d0, d1, d2)
    ycpoly = NonuniformCatmullRom(p0.y, p1.y, p2.y, p3.y, d0, d1, d2)

    return CatmullRom{T,2}((xcpoly, ycpoly))
end

function CentripetalCatmullRom(p0::P, p1::P, p2::P, p3::P) where {T, P<:POINT3D{T}}
    d0 = T(sqrt(sqrt(dist2(p0, p1))))
    d1 = T(sqrt(sqrt(dist2(p1, p2))))
    d2 = T(sqrt(sqrt(dist2(p2, p3))))

    # safety check for repeated points
    if (d1 < 1.0e-4)  d1 = T(1.0) end
    if (d0 < 1.0e-4)  d0 = d1 end
    if (d2 < 1.0e-4)  d2 = d1 end

    xcpoly = NonuniformCatmullRom(p0.x, p1.x, p2.x, p3.x, d0, d1, d2)
    ycpoly = NonuniformCatmullRom(p0.y, p1.y, p2.y, p3.y, d0, d1, d2)
    zcpoly = NonuniformCatmullRom(p0.z, p1.z, p2.z, p3.z, d0, d1, d2)

    return CatmullRom{T,3}((xcpoly, ycpoly, zcpoly))
end

function CentripetalCatmullRom(p0::P, p1::P, p2::P, p3::P) where {T, P<:POINT4D{T}}
    d0 = T(sqrt(sqrt(dist2(p0, p1))))
    d1 = T(sqrt(sqrt(dist2(p1, p2))))
    d2 = T(sqrt(sqrt(dist2(p2, p3))))

    # safety check for repeated points
    if (d1 < 1.0e-4)  d1 = T(1.0) end
    if (d0 < 1.0e-4)  d0 = d1 end
    if (d2 < 1.0e-4)  d2 = d1 end

    xcpoly = NonuniformCatmullRom(p0.x, p1.x, p2.x, p3.x, d0, d1, d2)
    ycpoly = NonuniformCatmullRom(p0.y, p1.y, p2.y, p3.y, d0, d1, d2)
    zcpoly = NonuniformCatmullRom(p0.z, p1.z, p2.z, p3.z, d0, d1, d2)
    tcpoly = NonuniformCatmullRom(p0.t, p1.t, p2.t, p3.t, d0, d1, d2)

    return CatmullRom{T,4}((xcpoly, ycpoly, zcpoly, tcpoly))
end


function test()
    p0 = POINT2D(0.0, 0.0)
    p1 = POINT2D(1.0, 1.0)
    p2 = POINT2D(1.5, 1.25)
    p3 = POINT2D(2.0, 0.0)

    crpoly = CentripetalCatmullRom(p0, p1, p2, p3)

    n = 4
    coords = Vector{POINT2D}(n)
    m = inv(n)
    
    for i=1:n
        xcoord, ycoord = polyval(crpoly, min(1.0,m*i))
        coord = POINT2D(xcoord, ycoord)
        coords[i] = coord
    end
    return coords
end

print(test())



end # module