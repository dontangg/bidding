
class Card
  constructor: (@number, @suit) ->
    @effectiveNumber = if @number == 1 then 15 else @number;
    @effectiveSuit = @suit;

  toString: ->
    return "<span class='black'>BB</span>" if @suit == Suit.blackbirdSuit

    suitChar = switch @suit
      when Suit.blackSuit then 'B'
      when Suit.greenSuit then 'G'
      when Suit.redSuit then 'R'
      when Suit.yellowSuit then 'Y'
      else '??'

    color = Suit.getName @suit

    "<span class='#{color}'>#{suitChar}#{@number}</span>"

  points: ->
    return 20 if @suit == Suit.blackbirdSuit
    switch @number
      when 1 then 15
      when 14 then 10
      when 10 then 10
      when 5 then 5
      else 0

  @highBlackbirdCard: ->
    card = new Card 16, Suit.blackbirdSuit
    card.effectiveSuit = Suit.effectiveTrumpSuit
    card

  @lowBlackbirdCard: ->
    card = new Card 0, Suit.blackbirdSuit
    card.effectiveSuit = Suit.effectiveTrumpSuit
    card

  @highTrumpRed1Card: ->
    card = new Card 1, Suit.redSuit
    card.effectiveNumber = 17
    card.effectiveSuit = Suit.effectiveTrumpSuit
    card

  @sortCards: (cards, descending = false) ->
    orderedAscending = if descending then 1 else -1
    orderedDescending = if descending then -1 else 1
    orderedSame = 0

    cards.sort (card1, card2) ->
      return orderedAscending if card1.suit < card2.suit
      return orderedDescending if card1.suit > card2.suit

      return orderedAscending if card1.effectiveNumber < card2.effectiveNumber
      return orderedDescending if card1.effectiveNumber > card2.effectiveNumber

      orderedSame


