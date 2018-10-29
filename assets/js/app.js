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

import css from '../css/app.css';

import embedSocketPortsTo from "./socket"
import {Elm} from '../elm/src/Leader.elm';

const elmLeaderDiv = document.querySelector('#elm_leader_target');

if (elmLeaderDiv) {
  let gameId = elmLeaderDiv.dataset.gameId;

  var app = Elm.Leader.init({
    node: elmLeaderDiv,
    flags: {
      state: elmLeaderDiv.dataset.gameState,
    }
  });

  embedSocketPortsTo(app, "leader:" + gameId)

  app.ports.play.subscribe(function(audioPath) {
    var audio = new Audio(audioPath);
    audio.play();
  });
}

const elmFollowerDiv = document.querySelector('#elm_follower_target');

if (elmFollowerDiv) {
  let gameId = elmFollowerDiv.dataset.gameId;
  let playerId = elmFollowerDiv.dataset.playerId;

  var app = Elm.Follower.init({
    node: elmFollowerDiv,
    flags: {
      state: elmFollowerDiv.dataset.gameState,
    }
  });

  embedSocketPortsTo(app, "followers:" + gameId + ":" + playerId)

  window.addEventListener("deviceorientation", function(data) {
    app.ports.listener.send(data);
  }, true);
}
