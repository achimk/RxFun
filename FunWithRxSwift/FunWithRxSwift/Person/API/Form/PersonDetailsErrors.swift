//
//  Created by Joachim Kret on 25/11/2019.
//  Copyright © 2019 Joachim Kret. All rights reserved.
//

import Foundation

struct PersonDetailsErrors {
    var person: [PersonValidationKey: PersonValidationError] = [:]
    var address: [AddressValidationKey: AddressValidationError] = [:]
    var hasErrors: Bool { return !person.isEmpty || !address.isEmpty }
}
