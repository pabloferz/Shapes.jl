"""    ftransform(f, s::Shape)

Maps a function `f(x, y, z)` to another `g(λ, μ, ν) * J(λ, μ, ν)`, where
`g(λ, μ, ν)` is basically `f(x(λ, μ, ν), y(λ, μ, ν), z(λ, μ, ν))` within the
volume of the shape `s` but under a change of variables to a rectangular
domain, and `J(λ, μ, ν)` is the Jacobian determinant of the transformation. The
limits of the domain are given by `domain(s)`
"""
function ftransform(f, s::Shape)
    function g(x, y, z)
        p = Point(x, y, z)
        r = f(x, y, z)
        return ifelse(p in s, r, zero(r))
    end
    return g
end

"""    ptransform(s::Shape)

Returns a function that maps a point `(λ, μ, ν)` on the domain given by
`domain(s)` to a tuple `(j, x, y, z)`, where `p = (x, y, z)` corresponds to the
cartesian coordinates of a point inside `s`, and `j` is the is the Jacobian
determinant of the transformation `(x, y, z) ↦ (λ, μ, ν)` evaluated on `p`.
"""
function ptransform end

for S in (:Cube, :Cylinder, :Ellipsoid, :EllipticCylinder, :HollowCylinder,
          :Parallelepiped, :RectangularPyramid, :Ring, :Sphere, :SphericalCap,
          :SquarePyramid, :TriangularToroid, :Torus, :TSP)

    T = Symbol(S, :PT)

    @eval begin
        ptransform(s::$S) = $T(s)
        ftransform{F}(f::F, s::$S) = FunctionTransformation(f, $T(s))
    end
end

function (T::FunctionTransformation)(λ, μ, ν)
    j, x, y, z = T.t(λ, μ, ν)
    return j * T.f(x, y, z)
end

@inline function (T::SpherePT)(λ, θ, φ)
    sθ, cθ = sincos(θ)
    sφ, cφ = sincos(φ)
    r = λ * T.s.r
    rsθ = r * sθ
    j = T.s.r * r * rsθ
    x = rsθ * cφ
    y = rsθ * sφ
    z = r * cθ
    return j, x, y, z
end

@inline function (T::SphericalCapPT)(λ, φ, ν)
    sφ, cφ = sincos(φ)
    κ = 1 - ν
    μ = κ * (T.a - κ)
    k = λ * √μ
    j = T.w * λ * μ
    x = k * cφ
    y = k * sφ
    z = T.s.c * ν
    return j, x, y, z
end

@inline function (T::EllipsoidPT)(λ, θ, φ)
    sθ, cθ = sincos(θ)
    sφ, cφ = sincos(φ)
    λsθ = λ * sθ
    j = T.w * λ * λsθ
    x = λsθ * T.s.a * cφ
    y = λsθ * T.s.b * sφ
    z = λ * T.s.c * cθ
    return j, x, y, z
end

@inline function (T::CylinderPT)(λ, φ, ν)
    sφ, cφ = sincos(φ)
    ρ = λ * T.s.r
    j = T.w * ρ
    x = ρ * cφ
    y = ρ * sφ
    z = ν * T.s.c
    return j, x, y, z
end

@inline function (T::HollowCylinderPT)(λ, φ, ν)
    sφ, cφ = sincos(φ)
    ρ = λ * T.a + T.s.r
    j = T.w * ρ
    x = ρ * cφ
    y = ρ * sφ
    z = ν * T.s.c
    return j, x, y, z
end

@inline function (T::TriangularToroidPT){N}(λ, φ, ν::N)
    sφ, cφ = sincos(φ)
    κ = (1 - ν) * N(0.5)
    ρ = λ * κ * T.s.b + T.s.r
    j = T.w * κ * ρ
    x = ρ * cφ
    y = ρ * sφ
    z = ν * T.s.c
    return j, x, y, z
end

@inline function (T::EllipticCylinderPT)(λ, φ, ν)
    sφ, cφ = sincos(φ)
    j = T.w * λ
    x = λ * T.s.a * cφ
    y = λ * T.s.b * sφ
    z = ν * T.s.c
    return j, x, y, z
end

@inline function (T::CubePT)(λ, μ, ν)
    j = T.w
    x = T.s.a * λ
    y = T.s.a * μ
    z = T.s.a * ν
    return j, x, y, z
end

@inline function (T::ParallelepipedPT)(λ, μ, ν)
    j = T.w
    x = T.s.a * λ
    y = T.s.b * μ
    z = T.s.c * ν
    return j, x, y, z
end

@inline function (T::SquarePyramidPT){N}(λ, μ, ν::N)
    κ = (1 - ν) * N(0.5)
    κa = κ * T.s.a
    j = T.w * κ^2
    x = κa * λ
    y = κa * μ
    z = T.s.b * ν
    return j, x, y, z
end

@inline function (T::RectangularPyramidPT){N}(λ, μ, ν::N)
    κ = (1 - ν) * N(0.5)
    j = T.w * κ^2
    x = κ * T.s.a * λ
    y = κ * T.s.b * μ
    z = T.s.c * ν
    return j, x, y, z
end

@inline function (T::TSPPT){N}(λ, μ, ν::N)
    κ = 1 - T.s.r * (1 + ν) * N(0.5)
    κa = κ * T.s.a
    j = T.w * κ^2
    x = κa * λ
    y = κa * μ
    z = T.a * ν
    return j, x, y, z
end

@inline function (T::RingPT)(λ, θ, φ)
    sθ, cθ = sincos(θ)
    sφ, cφ = sincos(φ)
    aλ = T.s.a * λ
    ρ = aλ * cθ + T.s.R
    j = T.s.b * aλ * ρ
    x = ρ * cφ
    y = ρ * sφ
    z = T.s.b * λ * sθ
    return j, x, y, z
end

@inline function (T::TorusPT)(λ, θ, φ)
    sθ, cθ = sincos(θ)
    sφ, cφ = sincos(φ)
    rλ = T.s.r * λ
    ρ = rλ * cθ + T.s.R
    j = T.s.r * rλ * ρ
    x = ρ * cφ
    y = ρ * sφ
    z = rλ * sθ
    return j, x, y, z
end

### Variables domains
domain(::Sphere            ) = (( 0.0,  0.0,  0.0), (1.0,  1π,  2π))
domain(::Ellipsoid         ) = (( 0.0,  0.0,  0.0), (1.0,  1π,  2π))
domain(::Cylinder          ) = (( 0.0,  -1π, -1.0), (1.0,  1π, 1.0))
domain(::HollowCylinder    ) = (( 0.0,  -1π, -1.0), (1.0,  1π, 1.0))
domain(::EllipticCylinder  ) = (( 0.0,  -1π, -1.0), (1.0,  1π, 1.0))
domain(::TriangularToroid  ) = ((-1.0,  -1π, -1.0), (1.0,  1π, 1.0))
domain(::SphericalCap      ) = (( 0.0,  0.0, -1.0), (1.0,  2π, 1.0))
domain(::Cube              ) = ((-1.0, -1.0, -1.0), (1.0, 1.0, 1.0))
domain(::Parallelepiped    ) = ((-1.0, -1.0, -1.0), (1.0, 1.0, 1.0))
domain(::RectangularPyramid) = ((-1.0, -1.0, -1.0), (1.0, 1.0, 1.0))
domain(::SquarePyramid     ) = ((-1.0, -1.0, -1.0), (1.0, 1.0, 1.0))
domain(::TSP               ) = ((-1.0, -1.0, -1.0), (1.0, 1.0, 1.0))
domain(::Ring              ) = (( 0.0,  -1π,  -1π), (1.0,  1π,  1π))
domain(::Torus             ) = (( 0.0,  -1π,  -1π), (1.0,  1π,  1π))
