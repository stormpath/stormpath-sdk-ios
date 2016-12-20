//
//  LoginModel.swift
//  Stormpath
//
//  Created by Edward Jiang on 12/15/16.
//  Copyright © 2016 Stormpath. All rights reserved.
//

import UIKit

class LoginModel {
    let fields: [FormField]
    let accountStores: [AccountStore]
    
    init?(json: JSON) {
        guard let fields = json["form"]["fields"].array?.flatMap({FormField(json: $0)}),
            let accountStores = json["accountStores"].array?.flatMap({AccountStore(json: $0)}) else {
                return nil
        }
        self.fields = fields
        self.accountStores = accountStores
    }
}
