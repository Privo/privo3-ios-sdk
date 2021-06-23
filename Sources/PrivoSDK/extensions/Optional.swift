//
//  File.swift
//  
//
//  Created by alex slobodeniuk on 23.06.2021.
//

public extension Optional where Wrapped == String {
    fileprivate var _boundString: String? {
        get {
            return self
        }
        set {
            self = newValue
        }
    }
    var boundString: String {
        get {
            return _boundString ?? ""
        }
        set {
            _boundString = newValue.isEmpty ? nil : newValue
        }
    }
}
