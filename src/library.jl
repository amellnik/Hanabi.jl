### Library type
# Another fancy array of cards
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
# draw! removes cards from the library and returns the drawn card
draw!(library::Library) = pop!(library.cards)
Base.show(io::IO, l::Library) = println(io, "Library has ", length(l.cards), " cards")
###
