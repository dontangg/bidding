#= require 'suit'
#= require 'card'
#= require 'deck'

$ ->
  card = new Card 3, Suit.redSuit
  console.log card.toString()

  card = Card.highBlackbirdCard()
  console.log card.toString()

  cards = [new Card(3, Suit.redSuit), new Card(2, Suit.redSuit), new Card(4, Suit.redSuit), Card.lowBlackbirdCard(), new Card(10, Suit.greenSuit)]
  console.log c.toString() for c in cards

  Card.sortCards cards
  console.log c.toString() for c in cards
