//
//  NotificationViewer.swift
//  B2M
//
//  Created by Gurcan Yavuz on 26.07.2018.
//  Copyright © 2018 Bring2Me. All rights reserved.
//

import Foundation
import CRNotifications

public class NotificationViewer {
    static func mustSelectSizeToAddBag() {
        CRNotifications.showNotification(type: .error, title: NSLocalizedString("Please select size", comment: ""), message:  NSLocalizedString("You must select size for adding to bag", comment: ""), dismissDelay: 3)
    }
    
    static func notEnoughQuantityToIncrease() {
       CRNotifications.showNotification(type: .error, title: NSLocalizedString("Not enough", comment: ""), message:  NSLocalizedString("We dont have more than that quantity", comment: ""), dismissDelay: 3)
    }
    
    static func productSuccessfullyAddedToBag() {
        CRNotifications.showNotification(type: .success, title: NSLocalizedString("Production", comment: ""), message:  NSLocalizedString("You production successfully added to bag", comment: ""), dismissDelay: 3)
    }
    
    static func dontHaveStockForOption() {
        CRNotifications.showNotification(type: .error, title: NSLocalizedString("Not in stock", comment: ""), message:  NSLocalizedString("We dont have enough stock for that option", comment: ""), dismissDelay: 3)
    }
}
