# Description:
#   Track arbitrary karma
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   <thing>++ - give thing some karma
#   <thing>-- - take away some of thing's karma
#   hubot karma <thing> - check thing's karma (if <thing> is omitted, show the top 5)
#   hubot karma empty <thing> - empty a thing's karma
#   hubot karma best [n] - show the top n (default: 5)
#   hubot karma worst [n] - show the bottom n (default: 5)
#
# Author:
#   D. Stuart Freeman (@stuartf) https://github.com/stuartf
#   Andy Beger (@abeger) https://github.com/abeger


class Karma

  constructor: (@robot) ->
    @cache = {}

    @increment_responses = [
      "+1!", "gained a level!", "is on the rise!", "leveled up!"
    ]

    @decrement_responses = [
      "took a hit! Ouch.", "took a dive.", "lost a life.", "lost a level."
    ]

    @robot.brain.on 'loaded', =>
      if @robot.brain.data.karma
        @cache = @robot.brain.data.karma

  kill: (thing) ->
    delete @cache[thing]
    @robot.brain.data.karma = @cache

  increment: (thing) ->
    @cache[thing] ?= 0
    @cache[thing] += 1
    @robot.brain.data.karma = @cache

  decrement: (thing) ->
    @cache[thing] ?= 0
    @cache[thing] -= 1
    @robot.brain.data.karma = @cache

  assign: (thing, val) ->
    @cache[thing] ?= 0
    @cache[thing] = val
    @robot.brain.data.karma = @cache

  incrementResponse: ->
    @increment_responses[Math.floor(Math.random() * @increment_responses.length)]

  decrementResponse: ->
    @decrement_responses[Math.floor(Math.random() * @decrement_responses.length)]

  get: (thing) ->
    k = if @cache[thing] then @cache[thing] else 0
    return k

  sort: ->
    s = []
    for key, val of @cache
      s.push({ name: key, karma: val })
    s.sort (a, b) -> b.karma - a.karma

  top: (n = 5) =>
    sorted = @sort()
    sorted.slice(0, n)

  bottom: (n = 5) =>
    sorted = @sort()
    sorted.slice(-n).reverse()

module.exports = (robot) ->
  karma = new Karma robot

  ###
  # Listen for "++" messages and increment
  ###
  robot.hear /@?(\S+[^+\s])\+\+(\s|$)/, (msg) ->
    subject = msg.match[1].toLowerCase()
    if subject == "rob"
      num = 0
      if num
#        msg.send "https://i.imgur.com/zFC8Pp4.jpg"
        msg.send(rickroll())
      else
#        msg.send "That didn't work."
        msg.send(rickroll())
    else
      karma.increment subject
#      msg.send "#{subject} #{karma.incrementResponse()} (Karma: #{karma.get(subject)})"
        msg.send(rickroll())

  ###
  # Listen for "--" messages and decrement
  ###
  robot.hear /@?(\S+[^-\s])--(\s|$)/, (msg) ->
    subject = msg.match[1].toLowerCase()
    if subject == "rob"
      num = 0
      if num
#        msg.send "https://media.giphy.com/media/Mir5fnHxvXrTa/giphy.gif"
        msg.send(rickroll())
      else
#        msg.send "That didn't work."
        msg.send(rickroll())
    else
      # avoid catching HTML comments
      unless subject[-2..] == "<!"
        karma.decrement subject
#        msg.send "#{subject} #{karma.decrementResponse()} (Karma: #{karma.get(subject)})"
        msg.send(rickroll())

  ###
  # Listen for "karma empty x" and empty x's karma
  ###
  robot.respond /karma empty ?(\S+[^-\s])$/i, (msg) ->
    subject = msg.match[1].toLowerCase()
    karma.kill subject
#    msg.send "#{subject} has had its karma scattered to the winds."
      msg.send(rickroll())

  ###
  # Function that handles best and worst list
  # @param msg The message to be parsed
  # @param title The title of the list to be returned
  # @param rankingFunction The function to call to get the ranking list
  ###
  parseListMessage = (msg, title, rankingFunction) ->
    count = if msg.match.length > 1 then msg.match[1] else null
    verbiage = [title]
    if count?
      verbiage[0] = verbiage[0].concat(" ", count.toString())
    for item, rank in rankingFunction(count)
      verbiage.push "#{rank + 1}. #{item.name} - #{item.karma}"
#    msg.send verbiage.join("\n")
    msg.send(rickroll())

  ###
  # Listen for "karma best [n]" and return the top n rankings
  ###
  robot.respond /karma best\s*(\d+)?$/i, (msg) ->
    parseData = parseListMessage(msg, "The Best", karma.top)

  ###
  # Listen for "karma worst [n]" and return the bottom n rankings
  ###
  robot.respond /karma worst\s*(\d+)?$/i, (msg) ->
    parseData = parseListMessage(msg, "The Worst", karma.bottom)

  ###
  # Listen for "karma x" and return karma for x
  ###
  robot.respond /karma (\S+[^-\s])$/i, (msg) ->
    match = msg.match[1].toLowerCase()
    if not (match in ["best", "worst"])
      if match == "rob"
#        msg.send "Nice try."
        msg.send(rickroll())
      else
#        msg.send "\"#{match}\" has #{karma.get(match)} karma. You must be proud."
        msg.send(rickroll())

  ###
  # Listen for "karma set x val" and set x to karma
  ###
  robot.respond /karma set (\S+[^-\s]) (-?\d+)$/i, (msg) ->
    subject = msg.match[1].toLowerCase()
    val = +msg.match[2]
    karma.assign subject, val

rickroll = ->
  num = Math.floor(Math.random() * 11)
  v = Math.floor(Math.random() * 10000)
  result = switch num
    when 0 then "https://media.giphy.com/media/629l2uUvy0uyc/giphy.gif"
    when 1 then "https://media.giphy.com/media/2EibPB1gfjHy0/giphy.gif"
    when 2 then "https://media.giphy.com/media/quXLseRWeh928/giphy.gif"
    when 3 then "https://media.giphy.com/media/P4SxYsjDqQwM0/giphy.gif"
    when 4 then "https://media.giphy.com/media/P4SxYsjDqQwM0/giphy.gif"
    when 5 then "https://media.giphy.com/media/LrmU6jXIjwziE/giphy.gif"
    when 6 then "https://media.giphy.com/media/sXX6ZPYWMNkwU/giphy.gif"
    when 7 then "https://media.giphy.com/media/6LG8fcerztuxy/giphy.gif"
    when 8 then "https://media.giphy.com/media/g7GKcSzwQfugw/giphy.gif"
    when 9 then "https://media.giphy.com/media/lgcUUCXgC8mEo/giphy.gif"
    when 10 then "https://media.giphy.com/media/4SoPtOQAOANMs/giphy.gif"
  result + "?v=" + v
