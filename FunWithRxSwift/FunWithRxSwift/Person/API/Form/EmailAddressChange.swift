//
//  Created by Joachim Kret on 25/11/2019.
//  Copyright © 2019 Joachim Kret. All rights reserved.
//

import Foundation

struct EmailAddressChange {
    
    struct Change<T> {
        var original: T
        var value: T
        var isModified: Bool
    }
    
    let email: Change<String?>
    let isModified: Bool
    
    private init(email: Change<String?>) {
        self.email = email
        self.isModified = email.isModified
    }
    
    init(email: String?) {
        self.email = .init(original: email, value: email, isModified: false)
        self.isModified = false
    }
    
    func updated(email value: String?) -> EmailAddressChange {
        var change = email
        change.value = value
        change.isModified = change.original != value
        return EmailAddressChange.init(email: change)
    }
}
