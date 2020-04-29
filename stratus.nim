#
#                 Stratus
#              (c) Copyright 2018
#       Status Research & Development GmbH
#
#            Licensed under either of
#  Apache License, version 2.0, (LICENSE-APACHEv2)
#            MIT license (LICENSE-MIT)

import
  cligen, options, strutils, chronos, json, times,
  nimcrypto/[bcmode, hmac, rijndael, pbkdf2, sha2, sysrand, utils, keccak, hash],
  eth/keys, eth/rlp, eth/p2p, eth/p2p/rlpx_protocols/[whisper_protocol],
  eth/p2p/[discovery, enode, peer_pool], chronicles

import NimQml, model/root, fleets

{.passl: "-lDOtherSideStatic".}

# Normally this part is done with CMake/qmake
{.passl: gorge("pkg-config --libs --static Qt5Core Qt5Qml Qt5Gui Qt5Quick Qt5QuickControls2 Qt5Widgets").}
{.passl: "-Wl,-as-needed".}

proc `$`*(digest: SymKey): string =
  for c in digest: result &= hexChar(c.byte)

# Don't do this at home, you'll never get rid of ugly globals like this!
var
  node: EthereumNode
  rootItem: Root

proc subscribeChannel(
    channel: string, handler: proc (msg: ReceivedMessage) {.gcsafe.}) =
  var ctx: HMAC[sha256]
  var symKey: SymKey
  discard ctx.pbkdf2(channel, "", 65356, symKey)

  let channelHash = digest(keccak256, channel)
  var topic: array[4, byte]
  for i in 0..<4:
    topic[i] = channelHash.data[i]

  info "Subscribing to channel", channel, topic, symKey

  discard node.subscribeFilter(initFilter(symKey = some(symKey),
                                         topics = @[topic]),
                              handler)

proc handler(msg: ReceivedMessage) {.gcsafe.} =
  try:
    # ["~#c4",["dcasdc","text/plain","~:public-group-user-message",
    #          154604971756901,1546049717568,[
    #             "^ ","~:chat-id","nimbus-test","~:text","dcasdc"]]]
    let
      src =
        if msg.decoded.src.isSome(): $msg.decoded.src.get()
        else: ""
      payload = cast[string](msg.decoded.payload)
      data = parseJson(cast[string](msg.decoded.payload))
      channel = data.elems[1].elems[5].elems[2].str
      time = $fromUnix(data.elems[1].elems[4].num div 1000)
      message = data.elems[1].elems[0].str

    info "adding", full=(cast[string](msg.decoded.payload))
    rootItem.add(channel, src[0..<8] & "..." & src[^8..^1], message, time)
  except:
    notice "no luck parsing", message=getCurrentExceptionMsg()

proc run(port: uint16 = 30303) =
  let address = Address(
    udpPort: port.Port, tcpPort: port.Port, ip: parseIpAddress("0.0.0.0"))

  let keys = KeyPair.random().tryGet()
  node = newEthereumNode(keys, address, 1, nil, addAllCapabilities = false)
  node.addCapability Whisper

  var bootnodes: seq[ENode] = @[]
  for nodeId in MainBootnodes:
    let bootnode = ENode.fromString(nodeId).tryGet()
    bootnodes.add(bootnode)

  asyncCheck node.connectToNetwork(bootnodes, true, true)
  # main network has mostly non SHH nodes, so we connect directly to SHH nodes
  for nodeId in WhisperNodes:
    let whisperENode = ENode.fromString(nodeId).tryGet()
    var whisperNode = newNode(whisperENode)

    asyncCheck node.peerPool.connectToNode(whisperNode)

  node.protocolState(Whisper).config.powRequirement = 0

  let app = newQApplication()
  defer: app.delete

  proc joinChannel(channel: string) =
    subscribeChannel(channel, handler)

  rootItem = newRoot(app, poll, joinChannel)
  defer: rootItem.delete

  let engine = newQQmlApplicationEngine()
  defer: engine.delete

  let rootVariant = newQVariant(rootItem)
  defer: rootVariant.delete

  engine.setRootContextProperty("root", rootVariant)
  engine.load("main.qml")

  app.exec()

dispatch(run)
