//
//  Created by Joachim Kret on 29/01/2020.
//  Copyright © 2020 Joachim Kret. All rights reserved.
//

import Foundation
import RxSwift

final class IdVerificationApplicationSerivce: IdVerificationAPI {
    
    private let idVerificationService: IdVerificationService
    
    init(idVerificationService: IdVerificationService) {
        self.idVerificationService = idVerificationService
    }
    
    func verifyIdentity(with form: IdVerificationForm) -> Single<ValidatedResult<VerifiedIdentity, IdVerificationForm>> {
        return IdVerificationUseCase.init(form: form, service: idVerificationService).prepare()
    }
    
    func createForm(with requirements: VerificationRequirements) -> IdVerificationForm {
        return IdVerificationFormBuilder.init(requirements: requirements).build()
    }
    
    func update(frontDocument value: String?, for form: IdVerificationForm) -> IdVerificationForm {
        return IdVerificationFormBuilder.init(form: form).set(frontDocument: value).build()
    }
    
    func update(backDocument value: String?, for form: IdVerificationForm) -> IdVerificationForm {
        return IdVerificationFormBuilder.init(form: form).set(backDocument: value).build()
    }
    
    func update(selfie value: String?, for form: IdVerificationForm) -> IdVerificationForm {
        return IdVerificationFormBuilder.init(form: form).set(selfie: value).build()
    }
    
    
}
