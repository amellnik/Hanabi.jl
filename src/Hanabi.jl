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

# Default constructor is an empty hand
Hand() = Hand(Card[])

# Default display only says how many cards are in the hand.
Base.show(io::IO, h::Hand) = println(io, "Hand with ", length(h.cards), " cards")

# A method for the other players to see exactly what's in the hand
export hand_contents
function hand_contents(h::Hand)
    return h.cards
end

# What the owner of the hand knows about it
observe(h::Hand) = ObservedCard[observe(c) for c in h.cards]

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
# draw! removes cards from the library and returns the drawn card
export draw!
draw!(library::Library) = pop!(library.cards)
Base.show(io::IO, l::Library) = println(io, "Library has ", length(l.cards), " cards")
###

### PlayArea
# It's where the cards are played -- each suite has up to one of each value
export PlayArea
mutable struct PlayArea
    stacks::Array{Pair{Suite, Int},1}
    score::Int
end
PlayArea() = PlayArea([Pair(Suite(s), 0) for s in possible_colors], 0)
function Base.show(io::IO, p::PlayArea)
    for s in p.stacks
        println(s.first, ": ", s.second)
    end
    println("Current score: ", p.score)
end
###

### GameState

export GameState
"""
A `GameState` consists of a `Library`, a `PlayArea` (which includes the current score), an array of `Hand`s, an integer which tracks which hand corresponds to the current player, an integer that tracks the number of hints remaining, and an integer that tracks the number of lives remaining.
"""
mutable struct GameState
    library::Library
    play_area::PlayArea
    hands::Array{Hand, 1}
    current_player::Integer
    hints::Integer
    lives::Integer
end
function GameState(nplayers::Integer) # Start a new game
    # First shuffle the cards to make a library
    lib = Library()
    # For three or less players each person gets 5 cards, 4 otherwise
    nplayers <= 3 ? ncards = 5 : ncards = 4
    hands = Hand[]
    # Draw cards from the deck and deal out to players
    for p in 1:nplayers
        push!(hands, Hand(Card[draw!(lib) for i in 1:ncards]))
    end
    GameState(lib, PlayArea(), hands, 1, 8, 3)
end
function Base.show(io::IO, gs::GameState)
    show(io, gs.library)
    println(io, "Current player: ", gs.current_player)
    for (i, h) in enumerate(gs.hands)
        print(io, "Player ", i, ": ")
        show(io, h)
    end
    println(io, "Hints remaining: ", gs.hints)
    println(io, "Lives remaining: ", gs.lives)
    show(io, gs.play_area)
end




# TODO: This needs to be rewritten to operation on a GameState
export attempt_to_play
function attempt_to_play(p::PlayArea, c::Card)
    # Find the right stack
    si = find([c.suite .== s.first for s in p.stacks])[1]
    # Is this a valid card to play?
    if p.stacks[si].second == c.value - 1
        p.stacks[si].second = p.stacks[si].second + 1
        p.score = p.score + 1
        return true # Play was successful
    else
        return false # No dice, need to reduce lives in gamestate
    end
end

# TODO: Need hint and discard play action methods

###



end # End module
