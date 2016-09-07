//
//  RequestController.swift
//  Tether
//
//  Created by James Pacheco on 1/5/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import Foundation
import UIKit

class TetherController {
    
    static func requestTether(friend: Friend, completion: (success: Bool, approved: Bool?) -> Void) {
        let endpoint = "requests/\(friend.number)"

        FirebaseController.setValueAtEndpoint(endpoint, value: [UserController.sharedInstance.currentUser.number: false]) { (success) -> Void in
            if !success {
                print("Could not create request to \(friend.number)")
            }
        }
    }
    
    static func removeRequest(endpoint: String, completion: (success: Bool) -> Void) {
        FirebaseController.removeValueAtEndpoint(endpoint) { (success) -> Void in
            if success {
                completion(success: true)
            } else {
                completion(success: false)
                print("Could not remove tether request at endpoint \(endpoint)")
            }
        }
    }
    
    static func rejectRequest(friend: Friend, completion: (success: Bool) -> Void) {
        let endpoint = "requests/\(UserController.sharedInstance.currentUser.number)/\(friend.number)"
        TetherController.removeRequest(endpoint) { (success) -> Void in
            if success {
                completion(success: true)
            } else {
                completion(success: false)
            }
        }
    }
    
    static func cancelRequest(friend: Friend, completion: (success: Bool) -> Void) {
        let endpoint = "requests/\(friend.number)/\(UserController.sharedInstance.currentUser.number)"
        TetherController.removeRequest(endpoint) { (success) -> Void in
            if success {

                completion(success: true)
            } else {
                completion(success: false)
            }
        }
    }
    
    static func acceptRequest(friend: Friend, completion: (success: Bool) -> Void) {
        createTether(friend, completion: { (success) -> Void in
            if success {
                let endpoint = "requests/\(UserController.sharedInstance.currentUser.number)/\(friend.number)"
                removeRequest(endpoint, completion: { (success) -> Void in
                })
                print("Successfully created tether with \(friend.number)")
            } else {
                print("Could not create tether with \(friend.number)")
            }
        })
        
    }
    static func createTether(friend: Friend, completion: (success: Bool) -> Void) {
        let value = [friend.number: true, UserController.sharedInstance.currentUser.number: true]
        FirebaseController.base.childByAppendingPath("tethers").childByAutoId().setValue(value, withCompletionBlock: { (error, firebase) -> Void in
            if let error = error {
                completion(success: false)
                print("Received error creating tether with \(friend.number). Error: \(error)")
            } else {
                }
                completion(success: true)
        })
    }
    static func removeTether(tether: Tether, completion: (success: Bool) -> Void) {
        let endpoint = "tethers/\(tether.identifier)"
        FirebaseController.removeValueAtEndpoint(endpoint) { (success) -> Void in
            if !success {
                print("Could not remove tether \(tether.identifier)")
            } else {
                UIApplication.sharedApplication().cancelAllLocalNotifications()

            }
        }
    }
    
    static func observeRequestsReceived() {
        let endpoint = "requests/\(UserController.sharedInstance.currentUser.number)"
        FirebaseController.base.childByAppendingPath(endpoint).observeEventType(.Value, withBlock: { (data) -> Void in
            if let dictionary = data.value as? [String: Bool] {
                let requests = dictionary.flatMap({FriendController.friendFromContacts($0.0)})
                UserController.sharedInstance.requestsReceived = requests
            } else {
                UserController.sharedInstance.requestsReceived = []
            }
        })
    }
    
    static func observeRequestsSent() {
        let endpoint = "requests"
        FirebaseController.base.childByAppendingPath(endpoint).queryOrderedByChild(UserController.sharedInstance.currentUser.number).queryStartingAtValue(false).queryEndingAtValue(true).observeEventType(.Value, withBlock: { (data) -> Void in
            if let value = data.value as? [String: [String: AnyObject]] {
                let requestsApprovedDictionary = value.filter({$0.1[UserController.sharedInstance.currentUser.number] as! Bool == true})
                let requestsApproved = requestsApprovedDictionary.flatMap({$0.0})
                for number in requestsApproved {
                    let friend = FriendController.friendFromContacts(number)
                    createTether(friend, completion: { (success) -> Void in
                        if success {
                            let endpoint = "requests/\(friend.number)/\(UserController.sharedInstance.currentUser.number)"
                            removeRequest(endpoint, completion: { (success) -> Void in
                            })
                            print("Successfully created tether with \(number)")
                        } else {
                            print("Could not create tether with \(number)")
                        }
                    })
                }

                let requestsPendingDictionary = value.filter({$0.1[UserController.sharedInstance.currentUser.number] as! Bool == false})
                let requestsPending = requestsPendingDictionary.flatMap({FriendController.friendFromContacts($0.0)})
                UserController.sharedInstance.requestsSent = requestsPending
                
            } else {
                UserController.sharedInstance.requestsSent = []
            }
        })

    }
    
    static func observeTethers() {
        let endpoint = "tethers"
        FirebaseController.base.childByAppendingPath(endpoint).queryOrderedByChild(UserController.sharedInstance.currentUser.number).queryStartingAtValue(true).queryEndingAtValue(true).observeEventType(.Value, withBlock: {(data) -> Void in
            if let dictionary = data.value as? [String: [String: AnyObject]] {
                let tethers = dictionary.flatMap({Tether(identifier: $0.0, friend: FriendController.friendFromContacts($0.1.flatMap({$0.0}).first! != UserController.sharedInstance.currentUser.number ? $0.1.flatMap({$0.0}).first!:$0.1.flatMap({$0.0})[1])) })
                UserController.sharedInstance.tethered = tethers
            } else {
                UserController.sharedInstance.tethered = []
            }
        })
    }
}