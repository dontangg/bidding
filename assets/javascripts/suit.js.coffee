
Suit =
  greenSuit: 0
  yellowSuit: 1
  blackSuit: 2
  redSuit: 3
  blackbirdSuit: 4
  effectiveTrumpSuit: 5
  getName: (suit) ->
    switch suit
      when @greenSuit then 'green'
      when @blackSuit then 'black'
      when @redSuit then 'red'
      when @yellowSuit then 'yellow'
      else '?'

