
Math.sinh ||= (x) -> (@exp(x) - @exp(-x)) / 2
Math.cosh ||= (x) -> (@exp(x) + @exp(-x)) / 2
Math.tanh ||= (x) -> @sinh(x) / @cosh(x)

class ComputerPlayer
  constructor: (options) ->
    @options = options
    @include1s = options.include1s
    @include2To4 = options.include2To4
    @isBlackbirdHigh = options.isBlackbirdHigh
    @useHighTrumpRed1 = options.useHighTrumpRed1
    @bonusForTakingMostTricks = options.bonusForTakingMostTricks
    @maximumBidAmount = options.maximumBidAmount
    @lastTrickTakesWidow = options.lastTrickTakesWidow
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
    factors = []

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
    ownedTrumpCards = []

    # Put the highest trump card at the beginning (index 0), the lowest trump card at the end
    trumpCards.sort (card1, card2) ->
      card2.effectiveNumber - card1.effectiveNumber

    for card in @hand
      cardIsTrump = card.effectiveSuit == trumpSuit || card.effectiveSuit == Suit.effectiveTrumpSuit
      if cardIsTrump
        ownedTrumpCards.push card
      else
        if card.effectiveNumber > 11
          nonTrumpHighCardCount++
          if card.number == @highestCardNumber
            nonTrumpHighestCardCount++

    bidFactor = 0
    maxBidFactor = 0

    maxCardValue = 15
    for i in [0...trumpCards.length]
      cardValue = maxCardValue - i
      factor =
        name: "Trump: #{trumpCards[i].toString()}"
        maxValue: @getCardWorthFromValue cardValue
        value: 0

      for card in ownedTrumpCards
        if trumpCards[i].toString() == card.toString()
          factor.value = factor.maxValue

      bidFactor += factor.value
      maxBidFactor += factor.maxValue
      factors.push factor

    factor =
      name: '# trump'
      maxValue: 10
      value: 0
      description: "
        10 pts >= #{Math.floor(trumpCards.length) / 2}, or
        5 pts >= #{Math.floor(trumpCards.length / 3).toFixed(1)}, or
        3 pts >= #{Math.floor(trumpCards.length / 4).toFixed(1)}.
        This hand has #{ownedTrumpCards.length} trump cards."
    if ownedTrumpCards.length >= Math.floor(trumpCards.length / 2)
      factor.value = 10
    else if ownedTrumpCards.length >= Math.floor(trumpCards.length / 3)
      factor.value = 5
    else if ownedTrumpCards.length >= Math.floor(trumpCards.length / 4)
      factor.value += 3
    bidFactor += factor.value
    maxBidFactor += factor.maxValue
    factors.push factor

    factor =
      name: '# highest non-trump'
      maxValue: 3 * 3.6
      value: nonTrumpHighestCardCount * 3.6
      description: "3.6 pts for each highest non-trump card. This hand has #{nonTrumpHighestCardCount} highest non-trump cards."
    bidFactor += factor.value
    maxBidFactor += factor.maxValue
    factors.push factor

    factor =
      name: '# high non-trump'
      maxValue: (2 + (if @include1s then 1 else 0)) * 3 * 0.6
      value: nonTrumpHighCardCount * 0.6
      description: "0.6 pts for each non-trump card higher than 11. This hand has #{nonTrumpHighCardCount} high non-trump cards."
    bidFactor += factor.value
    maxBidFactor += factor.maxValue
    factors.push factor

    numCardsInHandFactor = 0.1 * ((if @include1s then 0 else 1) + (if @include2To4 then 0 else 3)) / 4

    maximumBidAmount = @maximumBidAmount
    maximumBidAmount -= 15 if @useHighTrumpRed1
    minBid = (maximumBidAmount - @bonusForTakingMostTricks) * (0.453 + numCardsInHandFactor * 1.5)
    maxBid = (maximumBidAmount - @bonusForTakingMostTricks) * (0.82 + numCardsInHandFactor)

    bidAmount = bidFactor / maxBidFactor * (maxBid - minBid) + minBid
    bidAmount += @bonusForTakingMostTricks

    factor =
      name: 'Total'
      maxValue: maxBidFactor
      value: bidFactor
    factors.push factor

    bidAmount: Math.floor((bidAmount + 2.5) / 5) * 5
    bidAmountUnrounded: bidAmount.toFixed 2
    bidPercent: (bidFactor * 100 / maxBidFactor).toFixed 2
    minBid: (minBid + @bonusForTakingMostTricks).toFixed 2
    maxBid: (maxBid + @bonusForTakingMostTricks).toFixed 2
    factors: factors

  getCardWorthFromValue: (cardValue) ->
    cardValue = Math.max cardValue, 1

    # http://fooplot.com
    # (1/400)x^3 * log(x) + 0.75
    # (1/30)x^2 * (log(x)^2) + 0.75
    # (1/4000)x^4 + 0.75
    (1 / 30) * Math.pow(cardValue, 2) * Math.pow(Math.log(cardValue) / Math.log(10), 2) + 0.75


  makeBidProposed: ->
    factors = []

    trumpSuit = @chooseTrumpSync()

    trumpHighCardCount = 0 # 12 or higher
    nonTrumpHighestCardCount = 0 # 1s
    nonTrumpHighCardCount = 0 # 12 or higher

    deck = new Deck @options
    trumpCards = []
    redCards = [] # Maintain a list of cards of a random suit to help score other non-trump suits later

    drawnCard = deck.drawCard()
    while drawnCard
      if drawnCard.effectiveSuit == trumpSuit || drawnCard.effectiveSuit == Suit.effectiveTrumpSuit
        trumpCards.push drawnCard
      if drawnCard.effectiveSuit == Suit.redSuit
        redCards.push drawnCard

      drawnCard = deck.drawCard()

    ownedTrumpCardValues = []
    ownedTrumpCards = []

    # Put the highest trump card at the beginning (index 0), the lowest trump card at the end
    trumpCards.sort (card1, card2) ->
      card2.effectiveNumber - card1.effectiveNumber
    redCards.sort (card1, card2) ->
      card2.effectiveNumber - card1.effectiveNumber

    for card in @hand
      cardIsTrump = card.effectiveSuit == trumpSuit || card.effectiveSuit == Suit.effectiveTrumpSuit
      if cardIsTrump
        ownedTrumpCards.push card
        if card.effectiveNumber > 11
          trumpHighCardCount++
      else
        if card.effectiveNumber > 12
          if card.number == @highestCardNumber
            nonTrumpHighestCardCount++
          else
            nonTrumpHighCardCount++

    bidFactor = 0
    maxBidFactor = 0

    maxCardValue = 15
    for i in [0...trumpCards.length]
      cardValue = maxCardValue - i
      factor =
        name: "Trump: #{trumpCards[i].toString()}"
        maxValue: @getCardWorthFromValueProposed cardValue
        value: 0

      # The blackbird should always be worth at least 5
      factor.maxValue = 5 if trumpCards[i].suit == Suit.blackbirdSuit && factor.maxValue < 5

      for card in ownedTrumpCards
        if trumpCards[i].toString() == card.toString()
          factor.value = factor.maxValue

      bidFactor += factor.value
      maxBidFactor += factor.maxValue
      factors.push factor

    # http://fooplot.com
    # tanh(x/1.2-5) * 9 + 9
    c = @hand.length * 4.8 / 13
    calcTrumpCountWorth = (count) ->
      Math.tanh(count / 1.2 - c) * 9 + 9

    trumpScoreFactor = Math.min 1, bidFactor / 23

    trumpCount = ownedTrumpCards.length
    trumpCount = Math.min(Math.round(c), trumpCount) if trumpHighCardCount < 2
    factor =
      name: '# trump'
      maxValue: calcTrumpCountWorth(@hand.length)
      value: calcTrumpCountWorth(trumpCount) * trumpScoreFactor
      description: "This hand has #{ownedTrumpCards.length} trump cards. It is getting #{(trumpScoreFactor * 100).toFixed(0)}% because of the highness of trump. It would have been #{calcTrumpCountWorth(trumpCount).toFixed(2)}"
    bidFactor += factor.value
    maxBidFactor += factor.maxValue
    factors.push factor
    console.log factor

    factor =
      name: '# highest non-trump'
      maxValue: 3 * 5
      value: nonTrumpHighestCardCount * 5
      description: "5 pts for each highest non-trump card. This hand has #{nonTrumpHighestCardCount} highest non-trump cards."
    bidFactor += factor.value
    maxBidFactor += factor.maxValue
    factors.push factor

    factor =
      name: '# high non-trump'
      maxValue: (1 + (if @include1s then 1 else 0)) * 3 * 0.6
      value: nonTrumpHighCardCount * 0.6
      description: "0.6 pts for each non-trump card higher than 12, but less than the highest. This hand has #{nonTrumpHighCardCount} high non-trump cards."
    bidFactor += factor.value
    maxBidFactor += factor.maxValue
    factors.push factor

    # Reward for either being able to outsuit (no point cards) or having strong suits
    unless @lastTrickTakesWidow
      factor =
        name: "Strong colors / can outsuit"
        maxValue: 1.8 * 3
        value: 0
      suitCounts = {}
      suitCounts[Suit.blackSuit] = 0
      suitCounts[Suit.greenSuit] = 0
      suitCounts[Suit.redSuit] = 0
      suitCounts[Suit.yellowSuit] = 0
      for card in @hand
        cardIsTrump = card.effectiveSuit == trumpSuit || card.effectiveSuit == Suit.effectiveTrumpSuit
        unless cardIsTrump
          if card.number != @highestCardNumber && card.points() > 0
            suitCounts[card.effectiveSuit]++

      strongSuitCount = 0
      for suit, count of suitCounts
        suit = parseInt suit
        if count > 0
          suitScore = 0
          for i in [0...redCards.length]
            for card in @hand
              if redCards[i].effectiveNumber == card.effectiveNumber && card.effectiveSuit == suit
                cardValue = maxCardValue - i
                suitScore += @getCardWorthFromValueProposed cardValue
          if suitScore >= 16
            strongSuitCount++
        else if suit != trumpSuit
          strongSuitCount++

      factor.value = 1.8 * strongSuitCount

      # This benefit is not worth as much with fewer trumps
      percentTrumpInHand = (ownedTrumpCards.length - (3/13 * @hand.length)) / @hand.length
      percentTrumpFactor = Math.min(1, percentTrumpInHand * 5)
      factor.value *= percentTrumpFactor
      factor.description = "1.8 pts for each suit that is either strong or can be outsuited in. This hand has #{strongSuitCount} strong suits. It gets #{(percentTrumpFactor * 100).toFixed(0)}% of its value because there are #{ownedTrumpCards.length} trump cards."

      bidFactor += factor.value
      maxBidFactor += factor.maxValue
      factors.push factor

    numCardsInHandFactor = 0.1 * ((if @include1s then 0 else 1) + (if @include2To4 then 0 else 3)) / 4
    
    maximumBidAmount = @maximumBidAmount
    maximumBidAmount -= 10 if @useHighTrumpRed1

    minBid = (maximumBidAmount - @bonusForTakingMostTricks) * (0.44 + numCardsInHandFactor * 1.55)
    maxBid = (maximumBidAmount - @bonusForTakingMostTricks) * (0.84 + numCardsInHandFactor * 1.05)

    bidAmount = bidFactor / maxBidFactor * (maxBid - minBid) + minBid
    bidAmount += @bonusForTakingMostTricks

    factor =
      name: 'Total'
      maxValue: maxBidFactor
      value: bidFactor
    factors.push factor

    bidAmount: Math.floor((bidAmount + 2.0) / 5) * 5
    bidAmountUnrounded: bidAmount.toFixed 2
    bidPercent: (bidFactor * 100 / maxBidFactor).toFixed 2
    minBid: (minBid + @bonusForTakingMostTricks).toFixed 2
    maxBid: (maxBid + @bonusForTakingMostTricks).toFixed 2
    factors: factors

  getCardWorthFromValueProposed: (cardValue) ->
    cardValue = Math.max cardValue, 1

    # http://fooplot.com
    # (1/30)x^2 * (log(x)^2) + 0.75
    # (1/6000)x^4 * log(x) + 0.75
    #(1 / 30) * Math.pow(cardValue, 2) * Math.pow(Math.log(cardValue) / Math.log(10), 2) + 0.75
    (1 / 4800) * Math.pow(cardValue, 4) * Math.log(cardValue) / Math.log(10) + 0.75
