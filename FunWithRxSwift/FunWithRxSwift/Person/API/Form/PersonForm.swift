//
//  Created by Joachim Kret on 25/11/2019.
//  Copyright © 2019 Joachim Kret. All rights reserved.
//

import Foundation

struct PersonForm {
    let personChange: PersonChange
    let postalAddressChange: PostalAddressChange
    let emailAddressChange: EmailAddressChange
    let errors: PersonDetailsErrors
}

extension PersonForm {
    
    var isModified: Bool {
        return personChange.isModified || postalAddressChange.isModified || emailAddressChange.isModified
    }
}
