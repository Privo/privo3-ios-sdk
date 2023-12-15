//
//  File.swift
//  
//
//  Created by alex slobodeniuk on 06.07.2021.
//
import Foundation
import UIKit

/// ### Age Gate Flow Diagrams
///
/// Simple Age Gate Flow Diagram
/// ![Simple Age Gate Flow Diagram](https://developer.privo.com/images/AgeGate-Mobile.drawio.png)
///
/// Age Gate Flow Diagram (with Age Recheck)
/// ![Age Gate Flow Diagram](https://developer.privo.com/images/Updated-Mobile_AgeRecheck.drawio.png)
///
/// Age Gate MultiUser Flow Diagram
/// ![Age Gate MultiUser Flow Diagram](https://developer.privo.com/images/Mobile_AgeGate_MultiUser.drawio.png)
///
/// ### Age Gate SDK example
///
///     Privo.ageGate.getStatus(userIdentifier) { s in
///         event = s
///     }
///     ...
///     let data = CheckAgeData(
///       userIdentifier: userIdentifier,
///       birthDateYYYYMMDD: birthDate,
///       countryCode: country
///     )
///     Privo.ageGate.run(data) { s in
///       event = s
///     }
///     ...
///     Privo.ageGate.recheck(data) { s in
///       event = s
///     }
///
/// ### Sample SDK Response
/// 
///     { // json
///       "id": "861dc238-...-c1dfe",
///       "status": "Allowed",
///       "extUserId": "9ede0f0-...a78", // optional
///       "countryCode": "US" // optional
///     }
///
public class PrivoAgeGate {
    
    private let ageGate: PrivoAgeGateInternal

    public init() {
        ageGate = PrivoAgeGateInternal()
    }
    
    init(permissionService: PrivoPermissionServiceType = PrivoPermissionService.shared,
         api: Restable = Rest.shared,
         app: UIApplication = .shared,
         fpIdService: FpIdentifiable = FpIdService()
    ) {
        ageGate = PrivoAgeGateInternal(
            permissionService: permissionService,
            api: api,
            app: app,
            fpIdService: fpIdService)
    }
    
    /// The method allows checking the existing Age Gate status.
    /// - Parameters:
    ///   - userIdentifier: external user identifier (please don't use empty string ("") as a value. It will cause an error. We support real values or nil if you don't have it)
    ///   - nickname: optional parameter with default value nil. Please, use nickname only in case of multi-user integration. Please don't use empty string "" in it.
    ///   - completionHandler: closure which used to handle the result of an asynchronous operation and takes as input argument.
    ///   - errorHandler: optional parameter with default value nil. Called instead of the completionHandler when an error occurs. Takes an Error instance as input argument.
    @available(*, renamed: "getStatus(userIdentifier:nickname:)")
    public func getStatus(userIdentifier: String?,
                          nickname: String? = nil,
                          completionHandler: @escaping (AgeGateEvent) -> Void,
                          errorHandler: ((Error) -> Void)? = nil)
    {
        Task {
            do {
                let result = try await getStatus(userIdentifier: userIdentifier, nickname: nickname)
                completionHandler(result)
            } catch {
                errorHandler?(error)
            }
        }
    }
    
    // TODO: documentation
    public func getStatus(userIdentifier: String?,
                          nickname: String? = nil) async throws /*(PrivoError or AgeGateError)*/ -> AgeGateEvent {
        try ageGate.helpers.checkNetwork()
        try await ageGate.helpers.checkUserData(userIdentifier: userIdentifier, nickname: nickname, agId: nil)
        let event = await ageGate.getStatusEvent(userIdentifier, nickname: nickname)
        ageGate.storage.storeInfoFromEvent(event: event)
        return event
    }
    
    /// The method runs the Age Gate check. If the birth date is passed by a partner or filled in by a user, the method will return the status. If the birth date is not passed, a user will be navigated to the corresponding entry window and forced to fill in the birthday field.
    /// - Parameters:
    ///   - data
    ///   - completionHandler: A closure to execute. Nil indicates a failure has occurred.
    @available(*, renamed: "run(_:)")
    public func run(_ data: CheckAgeData,
                    completionHandler: @escaping (AgeGateEvent?) -> Void)
    {
        Task {
            do {
                let result = try await run(data)
                completionHandler(result)
            } catch {
                completionHandler(nil)
            }
        }
    }
    
    // TODO: documentation
    public func run(_ data: CheckAgeData) async throws /*(PrivoError or AgeGateError)*/ -> AgeGateEvent {
        try await ageGate.helpers.checkRequest(data)
        let statusEvent = await ageGate.getStatusEvent(data.userIdentifier, nickname: data.nickname)
        ageGate.storage.storeInfoFromEvent(event: statusEvent)
        if (statusEvent.status != AgeGateStatus.Undefined) {
            return statusEvent
        } else {
            if (data.birthDateYYYYMMDD != nil
            ||  data.birthDateYYYYMM != nil
            ||  data.birthDateYYYY != nil
            ||  data.age != nil)
            {
                let newEvent = try await ageGate.runAgeGateByBirthDay(data)
                ageGate.storage.storeInfoFromEvent(event: newEvent)
                return newEvent
            } else {
                let event = try await ageGate.runAgeGate(data, prevEvent: nil, recheckRequired: nil)
                ageGate.storage.storeInfoFromEvent(event: event)
                return event
            }
        }
    }
    
    /// The method allows rechecking data if the birth date provided by a user was updated.
    /// - Parameters:
    ///   - data
    ///   - completionHandler: A closure to execute. Nil indicates a failure has occurred.
    @available(*, renamed: "recheck(_:)")
    public func recheck(_ data: CheckAgeData,
                        completionHandler: @escaping (AgeGateEvent?) -> Void)
    {
        Task {
            do {
                let result = try await recheck(data)
                completionHandler(result)
            } catch {
                completionHandler(nil)
            }
        }
    }
    
    // TODO: documentation
    public func recheck(_ data: CheckAgeData) async throws -> AgeGateEvent? { // TODO: AgeGateEvent nonnil
        try await ageGate.helpers.checkRequest(data)
        if (data.birthDateYYYYMMDD != nil
        ||  data.birthDateYYYYMM != nil
        ||  data.birthDateYYYY != nil
        ||  data.age != nil)
        {
            if let event = await ageGate.recheckAgeGateByBirthDay(data) {
                ageGate.storage.storeInfoFromEvent(event: event)
                return event
            }
            return nil
        } else {
            if let event = try? await ageGate.runAgeGate(data, prevEvent: nil, recheckRequired: .RecheckRequired) {
                ageGate.storage.storeInfoFromEvent(event: event)
                return event
            }
            return nil
        }
    }
    
    /// The method will link user to specified userIdentifier.
    /// It's used in multi-user flow, when account creation (on partner side) happens after age-gate.
    /// Please note that linkUser can be used only for users that doesn't have userIdentifier yet. You can't change userIdentifier if user already have it.
    /// - Parameters:
    ///   - userIdentifier: External user identifier. Please don't use empty string ("") as a value. It will cause an error. We support real values or null if you don't have it
    ///   - agId: Age gate identifier that you get as a response from sdk on previous steps.
    ///   - nickname: Please use only in case of multi-user integration. Please don't use empty string "" in it.
    ///   - completionHandler: Closure which used to handle the result of an asynchronous operation.
    ///   - errorHandler: Called instead of the completionHandler when an error occurs.
    @available(*, renamed: "linkUser(userIdentifier:agId:nickname:errorHandler:)")
    public func linkUser(userIdentifier: String,
                         agId: String,
                         nickname: String?,
                         completionHandler: @escaping (AgeGateEvent) -> Void,
                         errorHandler: ((Error) -> Void)? = nil)
    {
        Task {
            do {
                let result = try await linkUser(userIdentifier: userIdentifier, agId: agId, nickname: nickname)
                completionHandler(result)
            } catch {
                errorHandler?(error)
            }
        }
    }
    
    // TODO: documentation
    public func linkUser(userIdentifier: String,
                         agId: String,
                         nickname: String?) async throws /*(PrivoError or AgeGateError)*/ -> AgeGateEvent {
        try ageGate.helpers.checkNetwork()
        try await ageGate.helpers.checkUserData(userIdentifier: userIdentifier, nickname: nickname, agId: agId)
        let event = try await ageGate.linkUser(userIdentifier: userIdentifier, agId: agId, nickname: nickname)
        ageGate.storage.storeInfoFromEvent(event: event)
        return event
    }
    
    /// The method will show a modal dialog with user age gate identifier (can be used to contact customer support).
    /// - Parameters:
    ///   - userIdentifier: External user identifier. Please, don't use empty string ("") as a value. It will cause an error. We support real values or null if you don't have it.
    ///   - nickname: Please use only in case of multi-user integration. Please don't use empty string "" in it.
    public func showIdentifierModal(userIdentifier: String?, nickname: String? = nil) {
        Task {
            await ageGate.showAgeGateIdentifier(userIdentifier: userIdentifier, nickname: nickname)
        }
    }
    
    /// The method allows a partner to hide the Age Gate widget.
    public func hide() {
        Task.init(priority: .userInitiated) {
            await ageGate.hide()
        }
    }
    
}
