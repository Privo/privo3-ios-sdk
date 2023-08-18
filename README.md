# PrivoSDK

PRIVO 3 ios SDK Swift package

Instantiation:

You can import it as Swift Package in Xcode:
1) Select xcodeproj
2) Go to File -> Swift Packages -> Add Package Dependency
3) use git@github.com:Privo/privo3-ios-sdk.git as repo URL
4) Select master branch as a source

Alternatively you can import it in Package.swift file.
Add this code to the dependencies value of your Package.swift:

dependencies: [
    .package(url: "git@github.com:Privo/privo3-ios-sdk.git", .branch("master"))
]

Documentation:

https://developer.privo.com/#doc_mobileswift-requirements




                        ////////////////////////////////////////////////
                        ///                                         ////
                        ///                                         ////
                        ///                                         ////
                        ///         STRUCTURE OF THE SDK            ////
                        ///                                         ////
                        ///                                         ////
                        ///                                         ////
                        ////////////////////////////////////////////////
                        
                        
                        
                                        COMMON IDEA
                                        
                                        
        EVERY LAYER, NETWORK SERVICE, INNER BUSINESS LOGIC SERVICE, CLIENT'S SERVICE, SHOULB WORK ONLY WITH                         
        THEIR ENTITIES, WITHOUT HAVING AN ACCESS TO ANOTHER.
            
                        ////////////////////////////////////////////////
                        ///                                         ////
                        ///                                         ////
                        ///                                         ////      --> INCLUDE NETWORK API, DESCRIBE SCHEME OF RESPONSES & THEIR CHILD
                        ///                NETWORK                  ////          ENTITIES, DATA WHICH ARE REQUIRED FOR REQUESTS.
                        ///                                         ////
                        ///                                         ////
                        ///                                         ////
                        ////////////////////////////////////////////////
                        
                        ------------------------------------------------
                        
                        ////////////////////////////////////////////////
                        ///                                         ////
                        ///                                         ////
                        ///                                         ////    --> INCLUDE SERVICES, MODELS, VIEWS WHAT ARE NEEDED FOR INNNER WORK.
                        ///         INNER BUSINESS LOGIC            ////        
                        ///                                         ////
                        ///                                         ////
                        ///                                         ////
                        ////////////////////////////////////////////////
                        
                        ------------------------------------------------
                        
                        ////////////////////////////////////////////////
                        ///                                         ////
                        ///                                         ////
                        ///                                         ////    --> INCLUDE PUBLIC MANAGERS ARE PRESENTED FOR CLIENTS' WORK.
                        ///             CLIENTS' LAYER              ////
                        ///                                         ////
                        ///                                         ////
                        ///                                         ////
                        ////////////////////////////////////////////////
                        
                        
*** IMPORTANT *** 
    THERE SHOULDN'T EXIST DIRECT CONNECTIONS BETWEEN MODELS, WE HAVE TO CREATE OR USE STRUCTURES, WHAT ARE CONVERTING DATA FOR SPECIFIC MODULE.
                        
                        



*** All SDK splited on the logic module, which responsible for their functions ***

*** Folders *** 

    *****  API ****
    ***** Included three folders:
        - Models: - includes entities what we're getting from API. Naming of a class should include in the end "TO".
        - Records: - describe the data what we're sending to API. Naming of a class should include in the end "Record".
        - Response: - common scheme of data what we get from API(every object include child data, what has been described in Models' classes.
                Naming of a class should include in the end "Response".
        - API: - The class is responsible form the communication with server. 
    
    
    *****  Components ****
    ***** Included two folders:
        - Buttons: - includes common buttons' views which we're using in many places.
        - ViewModifier: - Includes custom modifiers for SwiftUI's components.
        
    
    *****  Extensions ****
        - Includes common extensions for SDK.
        
        
    *****  Helpers ****
        - Includes additional classes are needed for inner work.
        
        
    *****  Models ****
        - Describes internal classes what're using by inner logic in the SDK, what are not accessible by clients.
        
        
    *****  Public ****
    ***** Includes classes what needed for public using, include two folders:
        - Managers: - include services what are visible for clients.
        - Models: - classes what are visible and usable for clients.


    *****  Services ****
    ***** Includes services required for inner work, what are not available for clients:
        - AgeGate: - responsible for work with Gate's functions.
        - AgeSettings: - responsible for work with Setting's functions.
        - AgeVerification: - responsible for work with Age Verification's functions.
        - Authentication: - responsible for work with Authentication's functions.
        - Permissions: - responsible for managing permissions what are required for SDK's work.
        - Register: - responsible for work with Register's functions.
        - Verification: - responsible for work with Verification's functions.
