//
//  Created by Joachim Kret on 29/01/2020.
//  Copyright © 2020 Joachim Kret. All rights reserved.
//

import Foundation

struct IdVerificationChange {
    
    struct Change<T> {
        var original: T
        var current: T
        var isIgnored: Bool
        var isModified: Bool
    }
    
    var frontDocument: Change<String?>
    var backDocument: Change<String?>
    var selfie: Change<String?>
    
    var isModified: Bool {
        return frontDocument.isModified || backDocument.isModified || selfie.isModified
    }
    
    init(requirements: VerificationRequirements) {
        var isIgnored = !requirements.all.contains(.frontDocument)
        frontDocument = Change.init(original: nil, current: nil, isIgnored: isIgnored, isModified: false)
        isIgnored = !requirements.all.contains(.backDocument)
        backDocument = Change.init(original: nil, current: nil, isIgnored: isIgnored, isModified: false)
        isIgnored = !requirements.all.contains(.selfie)
        selfie = Change.init(original: nil, current: nil, isIgnored: isIgnored, isModified: false)
    }
    
    private init(frontDocument: Change<String?>,
                 backDocument: Change<String?>,
                 selfie: Change<String?>) {
        self.frontDocument = frontDocument
        self.backDocument = backDocument
        self.selfie = selfie
    }
    
    func update(frontDocument value: String?) -> IdVerificationChange {
        var change = frontDocument
        change.isModified = value != change.current
        change.current = value
        return IdVerificationChange(frontDocument: change, backDocument: backDocument, selfie: selfie)
    }
    
    func update(backDocument value: String?) -> IdVerificationChange {
        var change = backDocument
        change.isModified = value != change.current
        change.current = value
        return IdVerificationChange(frontDocument: frontDocument, backDocument: change, selfie: selfie)
    }
    
    func update(selfie value: String?) -> IdVerificationChange {
        var change = selfie
        change.isModified = value != change.current
        change.current = value
        return IdVerificationChange(frontDocument: frontDocument, backDocument: backDocument, selfie: change)
    }
}
