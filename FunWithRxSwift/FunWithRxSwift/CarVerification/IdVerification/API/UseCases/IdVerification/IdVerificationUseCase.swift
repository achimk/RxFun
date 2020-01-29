//
//  Created by Joachim Kret on 29/01/2020.
//  Copyright © 2020 Joachim Kret. All rights reserved.
//

import Foundation
import RxSwift

struct IdVerificationUseCase {
    
    let form: IdVerificationForm
    let service: IdVerificationService
    
    func prepare() -> Single<ValidatedResult<VerifiedIdentity, IdVerificationForm>> {
        
        guard let identity = form.validation.result.value else {
            return .just(.invalid(form))
        }
        
        return service.verifyIdentity(identity).map { .valid($0) }
    }
}
