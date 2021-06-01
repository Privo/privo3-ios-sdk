# PrivoSDK

PRIVO 3 ios SDK Swift package

You can import it as Swift Package:
1) Select xcodeproj
2) Go to File -> Swift Packages -> Add Package Dependency
3) use git@github.com:Privo/privo3-ios-sdk.git as repo URL
4) Select master branch as a source


Alternativly you can import it with Swift Package Manager.
Add this code to the dependencies value of your Package.swift:

dependencies: [
    .package(url: "git@github.com:Privo/privo3-ios-sdk.git", .branch("master"))
]
