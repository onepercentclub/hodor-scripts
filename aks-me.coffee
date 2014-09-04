# Description:
#   Display a random "aks me" image
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hodor aks me - Returns a random pic of Aksel
#
# Author:
#   rollick

url = "https://s3-ap-southeast-2.amazonaws.com/djangocon2014/"

aksMe = (msg) ->
  msg.send "#{url}#{Math.floor(Math.random()*17)+1}.jpg"

module.exports = (robot) ->
  robot.respond /aks me/i, (msg) ->
    aksMe msg
