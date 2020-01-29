//
//  IdVerificationService.swift
//  FunWithRxSwift
//
//  Created by Joachim Kret on 29/01/2020.
//  Copyright © 2020 Joachim Kret. All rights reserved.
//

import Foundation
import RxSwift

protocol IdVerificationService {
    
    func verifyIdentity(_ identity: VerificationReadyIndentity) -> Single<VerifiedIdentity>
}
