//
//  ContactController.swift
//  Tether
//
//  Created by Zach Steed on 1/5/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import UIKit
import Contacts

class ContactController {
    
    static let sharedInstance = ContactController()
    
    
    enum promptStatus {
        case Continue
        case GoToSettings
        case RequestAuthorization
    }
    
    var contacts: [String: [String: AnyObject]] {
        get {

           return fetchContacts()
        }
    }
    
    var friendsUsingApp: [Friend] = []
    var friendsNotUsingApp: [Friend] = []
    
    static func checkContactsInFirebase() {
        for (number, details) in ContactController.sharedInstance.contacts {
            
            let friend = Friend(number: number)
            if let firstName = details["firstName"] as? String {
                friend.firstName = firstName
            }
            
            if let lastName = details["lastName"] as? String {
                friend.lastName = lastName
            }
            
            if let imageData = details["imageData"] as? NSData,
                let image = UIImage(data: imageData) {
                    friend.picture = image
            }
            
            if let organizationName = details["organizationName"] as? String {
                friend.organizationName = organizationName
            }
            
            FirebaseController.base.childByAppendingPath("users/\(number)").observeSingleEventOfType(.Value, withBlock: { (data) -> Void in

                if let _ = data.value as? Bool {
                    let newArray: [Friend] = sharedInstance.friendsUsingApp + [friend]
                    sharedInstance.friendsUsingApp = newArray.sort({$0.firstName < $1.firstName })
                } else {
                    let newArray: [Friend] = sharedInstance.friendsNotUsingApp + [friend]
                    sharedInstance.friendsNotUsingApp = newArray.sort({$0.firstName < $1.firstName })
                }
            })
            
            
        }
    }
    
    // Used to display alert for error's
    func showAlert(message:String) {
        let alert = UIAlertController(title: "Contacts Access", message: message, preferredStyle: .Alert)
        
        let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        
        alert.addAction(action)
    }
    
    // Used to ask the user for access to their contacts book
    
    static func shouldPromptForContactAuthorization(completion: (promptStatus: promptStatus) -> Void ) {
        let authorizationStatus = CNContactStore.authorizationStatusForEntityType(CNEntityType.Contacts)
        switch authorizationStatus {
        case .Authorized:
            completion(promptStatus: .Continue)
        case .Denied, .Restricted:
            completion(promptStatus: .GoToSettings)
        case .NotDetermined:
            completion(promptStatus: .RequestAuthorization)
        }
    }
    
    static func requestAuthorization(completion: (success: Bool) -> Void) {
        let contactStore = CNContactStore()
        contactStore.requestAccessForEntityType(CNEntityType.Contacts) { (access, error) -> Void in
            if let _ = error {
                completion(success: false)
            } else {
                completion(success: true)
            }
        }
    }
    
    func fetchContacts() -> [String: [String: AnyObject]] {
        
        let keysToFetch = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey, CNContactThumbnailImageDataKey, CNContactOrganizationNameKey]
        
        let fetchRequest = CNContactFetchRequest(keysToFetch: keysToFetch)
        var contacts = [String: [String: AnyObject]]()
        
        CNContact.localizedStringForKey(CNLabelPhoneNumberiPhone)
        
        fetchRequest.unifyResults = true
        fetchRequest.sortOrder = .UserDefault
        fetchRequest.predicate = nil
        
        let contactStoreID = CNContactStore().defaultContainerIdentifier()
        print("\(contactStoreID)")
        
        do {
            try CNContactStore().enumerateContactsWithFetchRequest(fetchRequest) { (contact, stop) -> Void in
                if contact.phoneNumbers.count > 0 {
                    let newContacts = self.toViewContactData(contact)
                    for (key, value) in newContacts where key.characters.count > 0 {
                        if !key.contains([".","#","$","[","]"]) {
                            var number: String = key
                            if key.characters.count > 10 {
                                var numberArray: [Character] = Array(key.characters)
                                numberArray.removeFirst(numberArray.count - 10)
                                number = String(numberArray)
                            }
                            contacts[number] = value
                        }
                    }
                }
            }
        } catch let e as NSError {
            print(e.localizedDescription)
        }
        
        return contacts
    }
    
    func toViewContactData(contact:CNContact) -> [String : [String:AnyObject]] {
        
        let firstName = contact.givenName
        let lastName = contact.familyName
        let phoneNumbers = contact.phoneNumbers
        let imageData = contact.thumbnailImageData
        let organizationName = contact.organizationName
        
        var newDict = [String:[String : AnyObject]]()
        
        for phoneNumber in phoneNumbers {
            let number = "\((phoneNumber.value as! CNPhoneNumber).valueForKey("digits") as! String)"
            var subDict = [String: AnyObject]()
            
            subDict["firstName"] = firstName
            subDict["lastName"] = lastName
            subDict["imageData"] = imageData
            subDict["organizationName"] = organizationName
            newDict[number] = subDict
        }
        return newDict
    }
    
}






