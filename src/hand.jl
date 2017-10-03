### Hand type
# A hand is just a fancy array of cards
mutable struct Hand
    cards::Array{Card, 1}
end

# Default constructor is an empty hand
Hand() = Hand(Card[])

# Default display only says how many cards are in the hand.
Base.show(io::IO, h::Hand) = println(io, "Hand with ", length(h.cards), " cards")

# What the owner of the hand knows about it
observe(h::Hand) = ObservedCard[observe(c) for c in h.cards]
