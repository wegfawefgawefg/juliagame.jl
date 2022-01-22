module Vectors

    struct Point
        x::Float
        y::Float
    end

    Base.:+(a::Point, b::Point) = Point(a.x + b.x, a.y + b.y)
    Base.:-(a::Point, b::Point) = Point(a.x - b.x, a.y - b.y)
    Base.:*(a::Point, b::Float) = Point(a.x * b, a.y * b)
    Base.:/=(a::Point, b::Float) = Point(a.x / b, a.y / b)
    Base.:^(a::Point, b::Float) = Point(a.x ^ b, a.y ^ b)
    Base.:<(a::Point, b::Point) = a.x < b.x && a.y < b.y
    Base.:<=(a::Point, b::Point) = a.x <= b.x && a.y <= b.y
    Base.:>(a::Point, b::Point) = a.x > b.x && a.y > b.y
    Base.:>=(a::Point, b::Point) = a.x >= b.x && a.y >= b.y
    Base.:==(a::Point, b::Point) = a.x == b.x && a.y == b.y
    Base.:!=(a::Point, b::Point) = a.x != b.x || a.y != b.y
    Base.:+=(a::Point, b::Point) = a := a + b
    Base.:-=(a::Point, b::Point) = a := a - b
    Base.:*=(a::Point, b::Float) = a := a * b
    Base.:/=(a::Point, b::Float) = a := a / b
    Base.:^=(a::Point, b::Float) = a := a ^ b
    Base.:<(a::Point, b::Point) = a.x < b.x && a.y < b.y

    struct Vec3
        x::Real
        y::Real
        z::Real
    end

end