//
//  VerificationRequirements.swift
//  FunWithRxSwift
//
//  Created by Joachim Kret on 29/01/2020.
//  Copyright © 2020 Joachim Kret. All rights reserved.
//

import Foundation

enum VerificationType {
    case frontDocument
    case backDocument
    case selfie
}

struct VerificationRequirements {
    
    let first: VerificationType
    let tail: [VerificationType]
    var all: [VerificationType]
    
    init(_ types: VerificationType...) {
        self.first = types[0]
        self.tail = Array(types.dropFirst())
        self.all = types
    }
    
    init?(_ types: [VerificationType]) {
        guard let first = types.first else { return nil }
        self.first = first
        self.tail = Array(types.dropFirst())
        self.all = types
    }
}
