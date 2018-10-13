// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

// import socket from "./socket"

import Elm from './main';

const elmLeaderDiv = document.querySelector('#elm_leader_target');

if (elmLeaderDiv) {
  var app = Elm.Leader.embed(elmLeaderDiv, {
    gameId: elmLeaderDiv.dataset.gameId,
    state: elmLeaderDiv.dataset.gameState,
    socketServer: elmLeaderDiv.dataset.socketServer
  });

  app.ports.play.subscribe(function(audioPath) {
    var audio = new Audio(audioPath);
    audio.play();
  });
}

const elmFollowerDiv = document.querySelector('#elm_follower_target');

if (elmFollowerDiv) {
  var app = Elm.Follower.embed(elmFollowerDiv, {
    gameId: elmFollowerDiv.dataset.gameId,
    state: elmFollowerDiv.dataset.gameState,
    playerId: elmFollowerDiv.dataset.playerId,
    socketServer: elmFollowerDiv.dataset.socketServer
  });

  window.addEventListener("deviceorientation", function(data) {
    app.ports.listener.send(data);
  }, true);
}
