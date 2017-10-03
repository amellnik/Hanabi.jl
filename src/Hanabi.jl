module Hanabi

using Reexport
@reexport using Nulls

include("suite.jl")
include("card.jl")
include("hand.jl")
include("library.jl")

### Overall TODO:
# Don't export internal methods

### PlayArea
# It's where the cards are played -- each suite has up to one of each value
# TODO: Need to replace Pair with something mutable!!!
export PlayArea
mutable struct PlayArea
    stacks_suite::Array{Suite, 1}
    stacks_value::Array{Integer, 1}
    score::Integer
end
PlayArea() = PlayArea(Suite[Suite(s) for s in possible_colors], [0 for s in possible_colors], 0)
function Base.show(io::IO, p::PlayArea)
    for (i, s) in enumerate(p.stacks_suite)
        println(s, ": ", p.stacks_value[i])
    end
    println("Current score: ", p.score)
end
###

### DiscardArea
# It's where the discarded cards go.  Serializing this is going to be tricky.
export DiscardArea
mutable struct DiscardArea
    cards::Array{Card, 1}
end
DiscardArea() = DiscardArea(Card[])
Base.show(io::IO, da::DiscardArea) = for c in da.cards show(io, c) end

### GameState

export GameState
"""
A `GameState` consists of a `Library`, a `PlayArea` (which includes the current score), an array of `Hand`s, an integer which tracks which hand corresponds to the current player, an integer that tracks the number of hints remaining, and an integer that tracks the number of lives remaining.
"""
mutable struct GameState
    library::Library
    play_area::PlayArea
    discard_area::DiscardArea
    hands::Array{Hand, 1}
    current_player::Integer
    hints::Integer
    lives::Integer
    final_turns::Integer
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
    GameState(lib, PlayArea(), DiscardArea(), hands, 1, 8, 3, 0)
end
function Base.show(io::IO, gs::GameState)
    show(io, gs.library)
    println(io, "Discarded cards: ")
    println(io, gs.discard_area)
    println(io, "Current player: ", gs.current_player)
    for (i, h) in enumerate(gs.hands)
        print(io, "Player ", i, ": ")
        show(io, h)
    end
    println(io, "Hints remaining: ", gs.hints)
    println(io, "Lives remaining: ", gs.lives)
    println(io, "Overtime turn: ", gs.final_turns)
    show(io, gs.play_area)
end

export attempt_to_play!
"""
    attempt_to_play!(gs::GameState, card_index::Integer)

Attempts to play the n'th card in the hand of the active player, where card_index is n.
"""
function attempt_to_play!(gs::GameState, card_index::Integer)
    # First, get the card out of the correct hand
    c = gs.hands[gs.current_player].cards[card_index]
    deleteat!(gs.hands[gs.current_player].cards, card_index)
    if attempt_to_play!(gs.play_area, c)
        # Play was successful
        println("Successfully played: ", c)

        # TODO: Check if the card was a 5, and if so give a hint back
    else
        println("Failure -- attempted to play: ", c)
        if gs.lives > 0
            gs.lives = gs.lives - 1
        else
            game_over(gs)
        end
    end
    # If there are cards remaining in the library, give another to the player
    if length(gs.library.cards) > 0
        push!(gs.hands[gs.current_player].cards, draw!(gs.library))
    else # Otherwise we are in the final turns - everyone gets one
        gs.final_turns = gs.final_turns + 1
        if gs.final_turns == length(gs.hands) + 1
            game_over(gs)
        end
    end
    return gs
end

# Internal convenience method for testing
function attempt_to_play!(p::PlayArea, c::Card)
    # Find the right stack
    # Note that we need to compare the color or value of the suites,
    # we can't compare them themselves.
    si = find([c.suite.value .== s.value for s in p.stacks_suite])[1]
    # Is this a valid card to play?
    if p.stacks_value[si] == c.value - 1
        p.stacks_value[si] = p.stacks_value[si] + 1
        p.score = p.score + 1
        return true # Play was successful
    else
        return false # No dice, need to reduce lives in gamestate
    end
end

export observe_active_hand
"""
    observe_active_hand(gs::GameState)

Returns what the active player knows about their own hand.
"""
function observe_active_hand(gs::GameState)
    observe(gs.hands[gs.current_player])
end

export other_players_hands
"""
    other_players_hands(gs::GameState)

What the other players are holding in their hands.
"""
function other_players_hands(gs::GameState)
    for i in 0:length(gs.hands)-2
        println("Player ", mod(gs.current_player+i,length(gs.hands)) + 1, " is holding:")
        println(gs.hands[mod(gs.current_player+i,length(gs.hands))+1].cards)
    end
end

function game_over(gs::GameState)
    println("Game over -- final score is ", gs.play_area.score)
end

# TODO: Need hint and discard play action methods

###



end # End module
