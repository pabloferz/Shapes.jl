__precompile__()

module GeometricTransforms


### Dependencies
using Compat
using Reexport

@reexport using StaticArrays

### Imports
import Base: in

### Implementation
path = dirname(realpath(@__FILE__)) # works even for symlinks
include(joinpath(path, "types.jl"))
include(joinpath(path, "utils.jl"))
include(joinpath(path, "in.jl"))
include(joinpath(path, "transforms.jl"))

### Exports
export Shape, Cube, Cylinder, Ellipsoid, EllipticCylinder, HollowCylinder,
       Parallelepiped, Point, RectangularPyramid, Ring, Sphere, SphericalCap,
       SquarePyramid, TSP, TriangularToroid, TruncatedSquarePyramid, Torus,
       Vec, domain, halflengths, ftransform, ptransform


end # module
