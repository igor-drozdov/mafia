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
import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

// import socket from "./socket"

import ElmLeader from './leader';
import ElmFollower from './follower';

const elmLeaderDiv = document.querySelector('#elm_leader_target');

if (elmLeaderDiv) {
  ElmLeader.Leader.embed(elmLeaderDiv, {
    gameId: elmLeaderDiv.dataset.gameId,
    state: elmLeaderDiv.dataset.state
  });
}

const elmFollowerDiv = document.querySelector('#elm_follower_target');

if (elmFollowerDiv) {
  ElmFollower.Follower.embed(elmFollowerDiv, {
    gameId: elmFollowerDiv.dataset.gameId,
    state: elmFollowerDiv.dataset.state,
    playerId: elmFollowerDiv.dataset.playerId
  });
}
