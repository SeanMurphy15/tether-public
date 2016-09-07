//
//  FirebaseController.swift
//  Tether
//
//  Created by James Pacheco on 1/5/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import Foundation
import Firebase

class FirebaseController {
    static let base = Firebase(url: "https://tetherlocation.firebaseio.com/")
    
    static func anonymousLoginToFirebase(completion: (success: Bool) -> Void) {
        base.authAnonymouslyWithCompletionBlock { (error, authData) -> Void in
            if error != nil {
                print("There was an error logging user in anonymously")
                completion(success: false)
            } else {
                print("User logged in successfully to firebase")
                completion(success: true)
                
            }
        }
    }
    
    static func setValueAtEndpoint(endpoint: String, value: AnyObject, completion: (success: Bool) -> Void) {
        FirebaseController.base.childByAppendingPath(endpoint).setValue(value) { (error, firebase) -> Void in
            if let error = error {
                print("Error setting value at endpoint \(endpoint): \(error)")
                completion(success: false)
            } else {
                completion(success: true)
            }
        }
    }
    
    static func removeValueAtEndpoint(endpoint: String, completion: (success: Bool) -> Void) {
        FirebaseController.base.childByAppendingPath(endpoint).removeValueWithCompletionBlock { (error, firebase) -> Void in
            if let error = error {
                completion(success: false)
                print("Could not remove value at endpoint \(endpoint) and received error: \(error)")
            } else {
                completion(success: true)
            }
        }
    }
    
    static func dataAtEndpoint(endpoint: String, completion: (key: String?, value: [String: AnyObject]?) -> Void) {
        FirebaseController.base.childByAppendingPath(endpoint).observeSingleEventOfType(.Value, withBlock:{ (data) -> Void in
            if let key = data.key,
                value = data.value as? [String: AnyObject] {
                    completion(key: key, value: value)
            } else {
                print("There was no value at endpoint \(endpoint)")
                completion(key: nil, value: nil)
            }
        })
    }
    
    static func observeValueAtEndpoint(endpoint: String, completion: (key: String?, value: AnyObject?) -> Void) -> FirebaseHandle {
        let handle = FirebaseController.base.childByAppendingPath(endpoint).observeEventType(.Value, withBlock: {(data) -> Void in
            if let key = data.key,
                value = data.value {
                completion(key: key, value: value)
            } else {
                print("There was no value at endpoint \(endpoint)")
                completion(key: nil, value: nil)
            }
        })
        return handle
    }
    
    static func observeChildAddedAtEndpoint(endpoint: String, completion: (key: String?, value: AnyObject?) -> Void) -> FirebaseHandle {
        let handle = FirebaseController.base.childByAppendingPath(endpoint).observeEventType(.ChildAdded, withBlock: {(data) -> Void in
            if let key = data.key,
                value = data.value {
                completion(key: key, value: value)
            } else {
                print("There was no value at endpoint \(endpoint)")
                completion(key: nil, value: nil)
            }
        })
        return handle
    }
    
    static func observeChildRemovedAtEndpoint(endpoint: String, completion: (key: String?, value: AnyObject?) -> Void) -> FirebaseHandle {
        let handle = FirebaseController.base.childByAppendingPath(endpoint).observeEventType(.ChildRemoved, withBlock: {(data) -> Void in
            if let key = data.key,
                value = data.value {
                completion(key: key, value: value)
            } else {
                print("There was no value at endpoint \(endpoint)")
                completion(key: nil, value: nil)
            }
        })
        return handle
    }
    
    static func removeAllObserversAtEndpoint(endpoint: String) {
        FirebaseController.base.childByAppendingPath(endpoint).removeAllObservers()
    }
    
    static func loadNecessaryItems() {
        TetherController.observeRequestsSent()
        TetherController.observeRequestsReceived()
        TetherController.observeTethers()
        ContactController.checkContactsInFirebase()
        
    }
    
}