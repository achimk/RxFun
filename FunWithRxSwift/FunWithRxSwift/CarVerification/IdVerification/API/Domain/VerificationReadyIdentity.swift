//
//  Created by Joachim Kret on 29/01/2020.
//  Copyright © 2020 Joachim Kret. All rights reserved.
//

import Foundation

enum DocumentInfo {
    case singleDocument(front: String)
    case doubleDocument(front: String, back: String)
    
    var front: String {
        switch self {
        case let .singleDocument(front): return front
        case let .doubleDocument(front, _): return front
        }
    }
}

enum VerificartionReadyInfo {
    case selfie(String)
    case document(DocumentInfo)
    case all(selfie: String, document: DocumentInfo)
}

struct VerificationReadyIndentity {
    let info: VerificartionReadyInfo
}
