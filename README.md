# PrivoSDK

Privo ios SDK Swift package

You can import it as Swift Package:
1) Select xcodeproj
2) Go to File -> Swift Packages -> Add Package Dependency
3) Provide github link to Privo ios SDK
4) Select master branch as a source


Alternativly you can import it with Swift Package Manager.
Add this code to the dependencies value of your Package.swift:

dependencies: [
    .package(url: "https://github.com/Privo/privo-mobile-ios-sdk", .branch("master"))
]
