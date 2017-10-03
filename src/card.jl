### Card type
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
mutable struct ObservedCard
    suite::Union{Suite, Null}
    value::Union{Int, Null}
end

Base.show(io::IO, c::ObservedCard) = print(io, isnull(c.suite) ? "?" : c.suite, " ", isnull(c.value) ? "?" : c.value)

export observe
observe(c::Card) = ObservedCard(c.suite_known ? c.suite : null, c.value_known ? c.value : null)
###
