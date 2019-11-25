//
//  Created by Joachim Kret on 24/11/2019.
//  Copyright © 2019 Joachim Kret. All rights reserved.
//

import Foundation

enum AddressValidationKey: String {
    case street
    case city
    case postCode
    case email
}

enum AddressValidationError: Swift.Error {
    case invalidPostal(PostalAddressValidationError)
    case invalidEmail
}

enum PostalAddressValidationError: Swift.Error {
    case invalidStreet
    case invalidCity
    case invalidPostCode
}

func validatePostalAddress(street: String?) -> Result<String, PostalAddressValidationError> {
    let value: String? = street.flatMap { value in
        if value.count > 0 { return value }
        else { return nil }
    }
    
    return value.map(Result.success) ?? .failure(.invalidStreet)
}

func validatePostalAddress(city: String?) -> Result<String, PostalAddressValidationError> {
    let value: String? = city.flatMap { value in
        if value.count > 0 { return value }
        else { return nil }
    }
    
    return value.map(Result.success) ?? .failure(.invalidCity)
}

func validatePostalAddress(postCode: String?) -> Result<String, PostalAddressValidationError> {
    let value: String? = postCode.flatMap { value in
        if value.count > 0 { return value }
        else { return nil }
    }
    
    return value.map(Result.success) ?? .failure(.invalidPostCode)
}

func validatePostalAddress(_ unvalidated: UnvalidatedAddress) -> ValidatedResult<PostalAddress, [AddressValidationKey: PostalAddressValidationError]> {

    let streetResult = validatePostalAddress(street: unvalidated.street)
    let cityResult = validatePostalAddress(city: unvalidated.city)
    let postCodeResult = validatePostalAddress(postCode: unvalidated.postCode)
    
    do {
        let address = PostalAddress(
            street: try streetResult.get(),
            city: try cityResult.get(),
            postCode: try postCodeResult.get())
        return .valid(address)
    } catch {
        var errors: [AddressValidationKey: PostalAddressValidationError] = [:]
        errors[.street] = streetResult.error
        errors[.city] = cityResult.error
        errors[.postCode] = postCodeResult.error
        return .invalid(errors)
    }
}

func validateEmailAddress(_ value: String?) -> Result<EmailAddress, AddressValidationError> {
    
    return value
        .flatMap(EmailAddress.init)
        .map(Result.success)
        ?? .failure(AddressValidationError.invalidEmail)
}

func validateAddress(_ unvalidated: UnvalidatedAddress) -> ValidatedResult<AddressInfo, [AddressValidationKey: AddressValidationError]> {
    
    let emailResult = ValidatedResult(validateEmailAddress(unvalidated.email))
    let postalResult = validatePostalAddress(unvalidated)
    
    switch (emailResult, postalResult) {
    case (.valid(let email), .valid(let postal)):
        return .valid(.all(postal, email))
    case (.valid(let email), .invalid):
        return .valid(.emailOnly(email))
    case (.invalid, .valid(let postal)):
        return .valid(.postalOnly(postal))
    case (.invalid(let emailError), .invalid(let postalErrors)):
        var errors: [AddressValidationKey: AddressValidationError] = [:]
        errors[.street] = postalErrors[.street].map(AddressValidationError.invalidPostal)
        errors[.city] = postalErrors[.city].map(AddressValidationError.invalidPostal)
        errors[.postCode] = postalErrors[.postCode].map(AddressValidationError.invalidPostal)
        errors[.email] = emailError
        return .invalid(errors)
    }
}
