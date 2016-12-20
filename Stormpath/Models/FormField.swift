//
//  FormField.swift
//  Stormpath
//
//  Created by Edward Jiang on 12/15/16.
//  Copyright © 2016 Stormpath. All rights reserved.
//

import UIKit

class FormField {
    let name: String
    let label: String
    let placeholder: String
    let required: Bool
    let type: String
    
    init?(json: JSON) {
        guard let name = json["name"].string,
            let label = json["label"].string,
            let placeholder = json["placeholder"].string,
            let required = json["required"].bool,
            let type = json["type"].string else {
                return nil
        }
        self.name = name
        self.label = label
        self.placeholder = placeholder
        self.required = required
        self.type = type
    }
}
