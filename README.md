# Stratus

[![Build Status (Travis)](https://img.shields.io/travis/status-im/nim-stratus/master.svg?label=Linux%20/%20macOS "Linux/macOS build status (Travis)")](https://travis-ci.org/status-im/nim-stratus)
[![License: Apache](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
![Stability: experimental](https://img.shields.io/badge/stability-experimental-orange.svg)

## Introduction

Stratus is an proof-of-concept chat client for the Status chat protocol that serves as an example of how [nim-eth p2p](https://github.com/status-im/nim-eth/blob/master/doc/p2p.md) can be used. See [the introductory post](https://discuss.status.im/t/hello-stratus-toying-around-with-nimbus-and-qml/905) for more information.

:construction: This is a prototype that's only sporadically maintained :construction:

:construction: Though in theory, both Nim and QT come with excellent cross-platform support, in practice this prototype was developed on Linux. Your mileage may vary. :construction:

## Build & run

``` bash
# Build it:
make # you can add "-j4" if you have 4 CPU cores available, to run some jobs in parallel

# Run it:
./stratus

# That's it.
```

## Buzzwords

* [nim-eth p2p](https://github.com/status-im/nim-eth/blob/master/doc/p2p.md)
* [Nim](https://nim-lang.org/)
* [QT/QML](http://doc.qt.io/qt-5/qmlapplications.html)
* [NimQML](https://github.com/filcuc/nimqml/)

## License

Licensed and distributed under either of

* MIT license: [LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT

or

* Apache License, Version 2.0, ([LICENSE-APACHEv2](LICENSE-APACHEv2) or http://www.apache.org/licenses/LICENSE-2.0)

at your option. These files may not be copied, modified, or distributed except according to those terms.

