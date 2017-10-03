### Suite type
mutable struct Suite
    value::Int
    color::String
end

possible_colors = ["red", "green", "blue", "yellow", "white"]

function Suite(color::String)
    if color in possible_colors
        return Suite(find(color .== possible_colors)[1], color)
    else
        error("That's not a suite!  Possible values are: ", possible_colors)
    end
end

function Suite(value::Int)
    if 1 <= value <= 5
        return Suite(value, possible_colors[value])
    else
        error("There's only five suites!")
    end
end

Base.show(io::IO, s::Suite) = print(io, s.color)

random_suite() = Suite(floor(Int, rand()*5+1))
###
