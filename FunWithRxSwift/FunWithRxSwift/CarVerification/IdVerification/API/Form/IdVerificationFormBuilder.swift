//
//  IdVerificationFormBuilder.swift
//  FunWithRxSwift
//
//  Created by Joachim Kret on 29/01/2020.
//  Copyright © 2020 Joachim Kret. All rights reserved.
//

import Foundation

struct IdVerificationFormBuilder {
    
    private var change: IdVerificationChange
    private var validation: IdVerificationValidation
    private let requirements: VerificationRequirements
    
    init(form: IdVerificationForm) {
        self.change = form.change
        self.validation = form.validation
        self.requirements = form.requirements
    }
    
    init(requirements: VerificationRequirements) {
        let unverified = UnverifiedIdentity()
        self.change = IdVerificationChange(requirements: requirements)
        self.validation = IdVerificationValidation(unverified: unverified, requirements: requirements)
        self.requirements = requirements
    }
    
    func set(frontDocument value: String?) -> Self {
        var builder = self
        builder.change = change.update(frontDocument: value)
        validate(for: &builder)
        return builder
    }
    
    func set(backDocument value: String?) -> Self {
        var builder = self
        builder.change = change.update(backDocument: value)
        validate(for: &builder)
        return builder
    }
    
    func set(selfie value: String?) -> Self {
        var builder = self
        builder.change = change.update(selfie: value)
        validate(for: &builder)
        return builder
    }
    
    func build() -> IdVerificationForm {
        return IdVerificationForm(change: change, validation: validation, requirements: requirements)
    }
    
    private func validate(for builder: inout IdVerificationFormBuilder) {
        let unverified = prepareUnverified(for: builder.change)
        builder.validation = IdVerificationValidation(unverified: unverified, requirements: requirements)
    }
    
    private func prepareUnverified(for change: IdVerificationChange) -> UnverifiedIdentity {
        return UnverifiedIdentity(
            frontDocument: change.frontDocument.current,
            backDocument: change.backDocument.current,
            selfie: change.selfie.current)
    }
}
