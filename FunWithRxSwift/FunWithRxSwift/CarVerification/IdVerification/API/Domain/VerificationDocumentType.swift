//
//  Created by Joachim Kret on 29/01/2020.
//  Copyright © 2020 Joachim Kret. All rights reserved.
//

import Foundation

enum VerificationDocumentType {
    case id
    case drivingLicense
    case passport
}

extension VerificationDocumentType {
 
    func toRequirements() -> VerificationRequirements {
        switch self {
        case .id:
            return VerificationRequirements(.frontDocument, .backDocument, .selfie)
        case .drivingLicense:
            return VerificationRequirements(.frontDocument, .selfie)
        case .passport:
            return VerificationRequirements(.frontDocument, .selfie)
        }
    }
}
