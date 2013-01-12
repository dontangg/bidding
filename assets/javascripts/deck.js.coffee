
Array::remove = (from, to) ->
  rest = this.slice((to || from) + 1 || this.length)
  this.length = if from < 0 then this.length + from else from
  this.push.apply this, rest

class Deck
  constructor: (options) ->
    # options: include1s, include2To4, isBlackbirdHigh, useHighTrumpRed1
    
    cardCount = 41
    cardCount += 4 if options.include1s
    cardCount += 12 if options.include2To4

    @cards = []

    addedHighRed1 = false

    for suit in [0..3]
      for num in [1..14]
        continue if num == 1 && !options.include1s
        continue if num > 1 && num < 5 && !options.include2To4

        if (options.useHighTrumpRed1 && suit == Suit.redSuit && num == 1)
          @cards.push Card.highTrumpRed1Card()
          addedHighRed1 = true
        else
          @cards.push(new Card(num, suit))

    @cards.push(Card.highTrumpRed1Card()) if options.useHighTrumpRed1 && !addedHighRed1

    # Add the Blackbird card
    blackbirdCard = if options.isBlackbirdHigh then Card.highBlackbirdCard() else Card.lowBlackbirdCard()
    @cards.push blackbirdCard

  # Returns a random number between 0 (inclusive) and max (exclusive)
  getRandomNumber: (max) ->
    Math.floor(Math.random() * max)

  drawCard: ->
    return null if @cards.length <= 0

    random = @getRandomNumber @cards.length
    card = @cards[random]
    @cards.remove random

    card
