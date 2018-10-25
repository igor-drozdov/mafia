import {Socket} from "phoenix"

function embedSocketPortsTo(app, channelName) {
  let socket = new Socket("/socket", {params: {}})
  socket.connect()

  let channel = socket.channel(channelName)

  app.ports.onPort.subscribe(event => {
    channel.on(event, payload => app.ports.onListenerPort.send([event, payload]))
  });

  app.ports.pushPort.subscribe(([event, payload]) => {
    channel.push(event, payload, 10000)
  });

  app.ports.joinPort.subscribe(() => {
    channel.join()
      .receive("ok", (data) => app.ports.joinListenerPort.send(data))
      .receive("error", ({reason}) => console.log("failed join", reason) )
  });
}

export default embedSocketPortsTo
