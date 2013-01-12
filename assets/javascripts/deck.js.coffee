
class Deck
  constructor: (include1s, include2To4, isBlackbirdHigh, useHighTrumpRed1) ->
    cardCount = 41
    cardCount += 4 if include1s
    cardCount += 12 if include2To4

    @cards = []

    addedHighRed1 = false

    for suit in [0..3]
      for num in [1..14]
        continue if num == 1 && !include1s
        continue if num > 1 && num < 5 && !include2To4

        if (useHighTrumpRed1 && suit == Suit.redSuit && num == 1)
          @cards.push Card.highTrumpRed1Card()
          addedHighRed1 = true
        else
          @cards.push(new Card(num, suit))

    @cards.push(Card.highTrumpRed1Card()) if useHighTrumpRed1 && !addedHighRed1

    # Add the Blackbird card
    blackbirdCard = if isBlackbirdHigh then Card.highBlackbirdCard() else Card.lowBlackbirdCard()
    @cards.push blackbirdCard

  random: (max) ->
    Math.floor(Math.random() * (max + 1))
