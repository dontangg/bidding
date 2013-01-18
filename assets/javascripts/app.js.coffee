#= require bootstrap.min
#= require jquery.mustache
#= require suit
#= require card
#= require deck
#= require computer_player

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


setupScreen = ->
  rules = $('#tabs li.active a').data('rules')
  
  switch rules
    when 'official'
      options =
        include1s: false
        include2To4: false
        isBlackbirdHigh: true
        useHighTrumpRed1: false
        bonusForTakingMostTricks: 0
        maximumBidAmount: 120
        lastTrickTakesWidow: true
    when 'wyoming'
      options =
        include1s: true
        include2To4: true
        isBlackbirdHigh: false
        useHighTrumpRed1: false
        bonusForTakingMostTricks: 20
        maximumBidAmount: 200
        lastTrickTakesWidow: false
    when 'red1'
      options =
        include1s: false
        include2To4: false
        isBlackbirdHigh: true
        useHighTrumpRed1: true
        bonusForTakingMostTricks: 0
        maximumBidAmount: 150
        lastTrickTakesWidow: true
    when 'tennessee'
      options =
        include1s: true
        include2To4: false
        isBlackbirdHigh: true
        bonusForTakingMostTricks: 0
        maximumBidAmount: 180
        lastTrickTakesWidow: true


  player = new ComputerPlayer options
  player.hand = nextHand options
  Card.sortCards player.hand

  showHand player.hand

  trumpSuit = player.chooseTrumpSync()
  trumpSuitName = Suit.getName trumpSuit
  $('#trumpSuit')
    .removeClass()
    .addClass(trumpSuitName)
    .text(trumpSuitName)

  $('#showBidBtn').show().unbind('click').click ->
    $(this).hide()

    bidInfo = player.makeBid()
    bidInfo.title = "Bid"
    for factor in bidInfo.factors
      factor.class = 'greyed-out' if factor.value == 0
      factor.value = factor.value.toFixed 2
      factor.maxValue = factor.maxValue.toFixed 2
    factorsHtml = $('#factor-tmpl').mustache bidInfo
    $('#bid-info').html factorsHtml
    $('#bid-info [rel=tooltip]').tooltip()

    bidInfo = player.makeBidProposed()
    bidInfo.title = "Proposed Bid"
    for factor in bidInfo.factors
      factor.class = 'greyed-out' if factor.value == 0
      factor.value = factor.value.toFixed 2
      factor.maxValue = factor.maxValue.toFixed 2
    factorsHtml = $('#factor-tmpl').mustache bidInfo
    $('#bid-info-proposed').html factorsHtml
    $('#bid-info-proposed [rel=tooltip]').tooltip()


$ ->
  $('#tabs a').click (event) ->
    $('#tabs li').removeClass 'active'
    $(this).parent().addClass 'active'
    setupScreen()
    $('#bid-info').html ''
    $('#bid-info-proposed').html ''

  tab = $("a[href=#{document.location.hash}]").parent()
  tab = $('#tabs li:first-child') if tab.length == 0
  tab.addClass 'active'

  setupScreen()
