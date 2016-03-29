//
//  GasStationListener.swift
//  GasStationsAppSwift
//
//  Created by Alfredo Israel López Alcalá on 27/03/2016.
//  Copyright © 2016 Alfredo Lopez. All rights reserved.
//

import Foundation
import IBMMobileFirstPlatformFoundation

class GasStationListener : NSObject, WLDelegate {
    
    override init() {
        print("Instance Created")
    }
    
    func onSuccess(response: WLResponse!) {
        print("Connection Success: " + response.responseText)
    }
    
    func onFailure(response: WLFailResponse!) {
        print("Connection Failure: " + response.responseText)
    }
}