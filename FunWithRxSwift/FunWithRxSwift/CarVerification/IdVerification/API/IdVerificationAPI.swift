//
//  IdVerificationAPI.swift
//  FunWithRxSwift
//
//  Created by Joachim Kret on 29/01/2020.
//  Copyright © 2020 Joachim Kret. All rights reserved.
//

import Foundation
import RxSwift

protocol IdVerificationFormAPI {
    func createForm(with requirements: VerificationRequirements) -> IdVerificationForm
    func update(frontDocument value: String?, for form: IdVerificationForm) -> IdVerificationForm
    func update(backDocument value: String?, for form: IdVerificationForm) -> IdVerificationForm
    func update(selfie value: String?, for form: IdVerificationForm) -> IdVerificationForm
}

protocol IdVerificationAPI: IdVerificationFormAPI {
    
    func verifyIdentity(with form: IdVerificationForm) -> Single<ValidatedResult<VerifiedIdentity, IdVerificationForm>>
}
