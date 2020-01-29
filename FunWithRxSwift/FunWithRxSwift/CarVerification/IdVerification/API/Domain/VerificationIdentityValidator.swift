//
//  Created by Joachim Kret on 29/01/2020.
//  Copyright © 2020 Joachim Kret. All rights reserved.
//

import Foundation

enum VerificationIdentityError: Error {
    case invalidRequirements
    case frontDocumentRequired
    case backDocumentRequired
    case selfieRequired
}

struct VerificationIdentityValidator {
    
    let requirements: VerificationRequirements
    
    func validate(with unverified: UnverifiedIdentity) -> ValidatedResult<VerificationReadyIndentity, VerificationIdentityError> {
        
        var documentInfo: DocumentInfo?
        var selfie: String?
        
        if requirements.all.contains(.frontDocument) {
            guard let data = unverified.frontDocument else { return .invalid(.frontDocumentRequired) }
            documentInfo = .singleDocument(front: data)
        }
        
        if requirements.all.contains(.backDocument) {
            guard let data = unverified.backDocument else { return .invalid(.backDocumentRequired) }
            documentInfo = documentInfo.map { DocumentInfo.doubleDocument(front: $0.front, back: data) }
        }
        
        if requirements.all.contains(.selfie) {
            guard let data = unverified.selfie else { return .invalid(.selfieRequired) }
            selfie = data
        }
        
        switch (documentInfo, selfie) {
        case let (.some(document), .some(selfie)):
            let ready = VerificationReadyIndentity(info: .all(selfie: selfie, document: document))
            return .valid(ready)
        case let (.some(document), .none):
            let ready = VerificationReadyIndentity(info: .document(document))
            return .valid(ready)
        case let (.none, .some(selfie)):
            let ready = VerificationReadyIndentity(info: .selfie(selfie))
            return .valid(ready)
        case (.none, .none):
            return .invalid(.invalidRequirements)
        }
        
    }
}
