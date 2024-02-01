# About zenea-swift-server
This package contains a swift implementation of a HTTP server for the [Zenea Project](https://github.com/glasfisch3000/zenea) Data Layer. It is built on [Vapor](https://github.com/vapor/vapor) and [zenea-swift](https://github.com/glasfisch3000/zenea-swift).

# How to Use
If you haven't already, download the latest version of Swift, but at least version 5.9.2. On macOS, the recommended way to do this is by downloading the Xcode app. On Linux, you'll want to use [swiftly](https://github.com/swift-server/swiftly).

After downloading this repository's latest release, `cd` into the directory that this README file is in and run `swift run`. This will automatically install all the required packages and compile and execute the finished product.

NOTE: This package may not work on systems that do not provide an adequate `Foundation` library. In any recent release of macOS, this should not be a problem. However, on Linux systems you might be using an older version of the library or it might be missing entirely. Apple is currently working on making an [open-source swift version](https://github.com/apple/swift-foundation) of that package that can be used as a dependency on all systems, but as it is still in an early stage, you could run into problems compiling this package.