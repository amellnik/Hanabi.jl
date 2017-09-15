module Hanabi

using Reexport
@reexport using Nulls


### Suite type
export Suite
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

export random_suite
random_suite() = Suite(floor(Int, rand()*5+1))
###

### Card type
export Card
mutable struct Card
    suite::Suite
    value::Int
    suite_known::Bool
    value_known::Bool
end
Base.show(io::IO, c::Card) = print(io, c.suite , " ", c.value )

# Drawn cards are unhinted
Card(suite::Suite, value::Int) = Card(suite::Suite, value, false, false)

# Provide information about a card to the player holding it
export hint!
function hint!(c::Card, property::String)
    if !(property in ["suite", "value"])
        error("You need to give hints about either the suite or value")
    end
    if property == "suite"
        c.suite_known = true
    else
        c.value_known = true
    end
    return c
end
###

### ObservedCard type
export ObservedCard
mutable struct ObservedCard
    suite::Union{Suite, Null}
    value::Union{Int, Null}
end
Base.show(io::IO, c::ObservedCard) = print(io, isnull(c.suite) ? "?" : c.suite, " ", isnull(c.value) ? "?" : c.value)

export observe
observe(c::Card) = ObservedCard(c.suite_known ? c.suite : null, c.value_known ? c.value : null)
###

### Hand type
# A hand is just a fancy array of cards
export Hand
mutable struct Hand
    cards::Array{Card, 1}
end
###

### Library type
# Another fancy array of cards
export Library
mutable struct Library
    cards::Array{Card, 1}
end

# Make a random deck of cards
function Library()
    cards = Card[]
    for value in [1,1,1,2,2,3,3,4,4,5]
        for suite in Suite.(possible_colors)
            push!(cards, Card(suite, value))
        end
    end
    return Library(shuffle(cards))
end

export draw!
draw!(library::Library) = pop!(library.cards)
###








end # End module
