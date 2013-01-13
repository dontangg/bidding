
class ComputerPlayer
  constructor: (options) ->
    @options = options
    @include1s = options.include1s
    @include2To4 = options.include2To4
    @isBlackbirdHigh = options.isBlackbirdHigh
    @useHighTrumpRed1 = options.useHighTrumpRed1
    @bonusForTakingMostTricks = options.bonusForTakingMostTricks
    @maximumBidAmount = options.maximumBidAmount
    @highestCardNumber = if @include1s then 1 else 14

  calculateChooseTrumpScore: (cardToScore) ->
    score = cardToScore.effectiveNumber - 1

    numberOfOwnedCardsHigher = 0

    for card in @hand
      if card.effectiveSuit == cardToScore.effectiveSuit
        if card.effectiveNumber > cardToScore.effectiveNumber
          numberOfOwnedCardsHigher++

    numberOfMissingCardsHigher = (if @include1s then 15 else 14) - cardToScore.effectiveNumber - numberOfOwnedCardsHigher

    multiplier = if numberOfMissingCardsHigher > 0 then 0.75 else 1.0

    score * multiplier + 2

  chooseTrumpSync: ->
    blackScore = 0
    greenScore = 0
    redScore = 0
    yellowScore = 0

    for card in @hand
      continue if card.effectiveSuit == Suit.effectiveTrumpSuit

      score = @calculateChooseTrumpScore card

      switch card.effectiveSuit
        when Suit.blackSuit then blackScore += score
        when Suit.greenSuit then greenScore += score
        when Suit.redSuit then redScore += score
        when Suit.yellowSuit then yellowScore += score

    trumpSuit = Suit.blackSuit
    highScore = blackScore

    if greenScore > highScore
      trumpSuit = Suit.greenSuit
      highScore = greenScore

    if redScore > highScore
      trumpSuit = Suit.redSuit
      highScore = redScore

    if yellowScore > highScore
      trumpSuit = Suit.yellowSuit
      highScore = yellowScore

    trumpSuit

  makeBid: ->
    trumpSuit = @chooseTrumpSync()

    nonTrumpHighestCardCount = 0 # 1s
    nonTrumpHighCardCount = 0 # 12 or higher

    deck = new Deck @options
    trumpCards = []

    drawnCard = deck.drawCard()
    while drawnCard
      if drawnCard.effectiveSuit == trumpSuit || drawnCard.effectiveSuit == Suit.effectiveTrumpSuit
        trumpCards.push drawnCard

      drawnCard = deck.drawCard()

    ownedTrumpCardValues = []
    maxCardValue = 15

    trumpCards.sort (card1, card2) ->
      card2.EffectiveNumber - card1.EffectiveNumber

    for card in @hand
      cardIsTrump = card.effectiveSuit == trumpSuit || card.effectiveSuit == Suit.effectiveTrumpSuit
      if cardIsTrump
        for i in [0...trumpCards.length]
          if trumpCards[i].toString() == card.toString()
            ownedTrumpCardValues.push (maxCardValue - i)
            break
      else
        if card.effectiveNumber < 11
          nonTrumpHighCardCount++
          if card.number == @highestCardNumber
            nonTrumpHighestCardCount++
    

    bidFactor = 0
    maxBidFactor = 0

    for cardValue in ownedTrumpCardValues
      cardWorth = @getCardWorthFromValue cardValue
      bidFactor += cardWorth

    totalTrumpPointsPossible = 0
    for i in [(maxCardValue - trumpCards.length + 1)..maxCardValue]
      cardWorth = @getCardWorthFromValue cardValue
      maxBidFactor += cardWorth
      totalTrumpPointsPossible += cardWorth

    if ownedTrumpCardValues.length >= Math.floor(trumpCards.length / 2)
      bidFactor += 10
    else if ownedTrumpCardValues.length >= trumpCards.length / 3
      bidFactor += 5
    else if ownedTrumpCardValues.length >= trumpCards.length / 4
      bidFactor += 3
    maxBidFactor += 10

    bidFactor += nonTrumpHighestCardCount * 3.6
    maxBidFactor += 3 * 3.6

    bidFactor += nonTrumpHighCardCount * 0.6
    maxBidFactor += (2 + (if @include1s then 1 else 0)) * 3 * 0.6

    numCardsInHandFactor = 0.1 * ((if @include1s then 0 else 1) + (if @include2To4 then 0 else 1)) / 4

    console.log "numCardsInHandFactor: #{numCardsInHandFactor}"

    minBid = (@maximumBidAmount - @bonusForTakingMostTricks) * (0.453 + numCardsInHandFactor * 1.5)
    maxBid = (@maximumBidAmount - @bonusForTakingMostTricks) * (0.82 + numCardsInHandFactor)

    console.log "minBid: #{minBid}"
    console.log "maxBid: #{maxBid}"

    bidAmount = bidFactor / maxBidFactor * (maxBid - minBid) + minBid
    bidAmount += @bonusForTakingMostTricks

    Math.floor((bidAmount + 2.5) / 5) * 5

  getCardWorthFromValue: (cardValue) ->
    cardValue = Math.max cardValue, 1

    # http://fooplot.com
    # (1/400)x^3 * log(x) + 0.75
    # (1/30)x^2 * (log(x)^2) + 0.75
    # (1/4000)x^4 + 0.75
    (1 / 30) * Math.pow(cardValue, 2) * Math.pow(Math.log(cardValue) / Math.log(10), 2) + 0.75
