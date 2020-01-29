//
//  Created by Joachim Kret on 29/01/2020.
//  Copyright © 2020 Joachim Kret. All rights reserved.
//

import Foundation

struct IdVerificationValidation {

    let result: ValidatedResult<VerificationReadyIndentity, VerificationIdentityError>
    var isValid: Bool { return result.isValid }
    
    init(unverified: UnverifiedIdentity, requirements: VerificationRequirements) {
        result = VerificationIdentityValidator.init(requirements: requirements).validate(with: unverified)
    }
}
