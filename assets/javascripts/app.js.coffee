#= require 'suit'
#= require 'card'
#= require 'deck'
#= require 'computer_player'

nextHand = (options) ->
  hand = []
  deck = new Deck options

  numCards = 9
  numCards += 1 if options.include1s
  numCards += 3 if options.include2To4

  hand.push(deck.drawCard()) for num in [1..numCards]
  hand

showHand = (hand) ->
  cards = (card.toString() for card in hand)
  $('#hand').html cards.join(' ')


$ ->
  options =
    include1s: true
    include2To4: true
    isBlackbirdHigh: false
    useHighTrumpRed1: false

  player = new ComputerPlayer options
  player.hand = nextHand options
  Card.sortCards player.hand

  showHand player.hand

  trumpSuit = player.chooseTrumpSync()
  trumpSuitName = Suit.getName trumpSuit
  $('#trumpSuit')
    .addClass(trumpSuitName)
    .text(trumpSuitName)
