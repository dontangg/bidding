
class ComputerPlayer
  constructor: (options) ->
    @include1s = options.include1s
    @include2To4 = options.include2To4
    @isBlackbirdHight = options.isBlackbirdHigh
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

