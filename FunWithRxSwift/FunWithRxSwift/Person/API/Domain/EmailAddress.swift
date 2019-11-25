//
//  Created by Joachim Kret on 24/11/2019.
//  Copyright © 2019 Joachim Kret. All rights reserved.
//

import Foundation

struct EmailValidationRule {
    let pattern = "^.+@.+\\..+$"
    
    func validate(_ value: String?) -> Bool {
        guard let value = value else { return false }
        return NSPredicate(format: "SELF MATCHES %@", pattern).evaluate(with: value)
    }
}

struct EmailAddress {
    let value: String
    
    init?(_ value: String) {
        guard EmailValidationRule().validate(value) else { return nil }
        self.value = value
    }
}
