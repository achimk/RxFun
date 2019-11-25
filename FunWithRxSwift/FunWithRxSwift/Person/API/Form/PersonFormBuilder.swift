//
//  Created by Joachim Kret on 25/11/2019.
//  Copyright © 2019 Joachim Kret. All rights reserved.
//

import Foundation

struct PersonFormBuilder {
    
    private var personChange: PersonChange
    private var postalAddressChange: PostalAddressChange
    private var emailAddressChange: EmailAddressChange
    private var errors: PersonDetailsErrors
    
    init(_ form: PersonForm) {
        self.personChange = form.personChange
        self.postalAddressChange = form.postalAddressChange
        self.emailAddressChange = form.emailAddressChange
        self.errors = form.errors
    }
    
    init(details: PersonDetails? = nil, errors: PersonDetailsErrors? = nil) {
        personChange = PersonChange(
            name: details?.person.name,
            surname: details?.person.surname,
            age: details?.person.age)
        
        if let address = details?.address {
            
            switch address {
            case .emailOnly(let email):
                postalAddressChange = .init(street: nil, city: nil, postCode: nil)
                emailAddressChange = .init(email: email.value)
            case .postalOnly(let postal):
                postalAddressChange = .init(street: postal.street, city: postal.city, postCode: postal.postCode)
                emailAddressChange = .init(email: nil)
            case .all(let postal, let email):
                postalAddressChange = .init(street: postal.street, city: postal.city, postCode: postal.postCode)
                emailAddressChange = .init(email: email.value)
            }
            
        } else {
            postalAddressChange = .init(street: nil, city: nil, postCode: nil)
            emailAddressChange = .init(email: nil)
        }
        
        self.errors = errors ?? .init()
    }
    
    func set(name: String?) -> PersonFormBuilder {
        var builder = self
        builder.personChange = builder.personChange.updated(name: name)
        builder.errors.person[.name] = validatePerson(name: name).error
        return builder
    }
    
    func set(surname: String?) -> PersonFormBuilder {
        var builder = self
        builder.personChange = builder.personChange.updated(surname: surname)
        builder.errors.person[.surname] = validatePerson(surname: surname).error
        return builder
    }
    
    func set(age: UInt?) -> PersonFormBuilder {
        var builder = self
        builder.personChange = builder.personChange.updated(age: age)
        builder.errors.person[.age] = validatePerson(age: age).error
        return builder
    }
    
    func set(street: String?) -> PersonFormBuilder {
        var builder = self
        builder.postalAddressChange = builder.postalAddressChange.updated(street: street)
        builder.errors.address[.street] = validatePostalAddress(street: street).error.map(AddressValidationError.invalidPostal)
        return builder
    }
    
    func set(city: String?) -> PersonFormBuilder {
        var builder = self
        builder.postalAddressChange = builder.postalAddressChange.updated(city: city)
        builder.errors.address[.city] = validatePostalAddress(city: city).error.map(AddressValidationError.invalidPostal)
        return builder
    }
    
    func set(postCode: String?) -> PersonFormBuilder {
        var builder = self
        builder.postalAddressChange = builder.postalAddressChange.updated(postCode: postCode)
        builder.errors.address[.postCode] = validatePostalAddress(postCode: postCode).error.map(AddressValidationError.invalidPostal)
        return builder
    }
    
    func set(email: String?) -> PersonFormBuilder {
        var builder = self
        builder.emailAddressChange = builder.emailAddressChange.updated(email: email)
        builder.errors.address[.email] = validateEmailAddress(email).error
        return builder
    }
    
    func build() -> PersonForm {
        return PersonForm(
            personChange: personChange,
            postalAddressChange: postalAddressChange,
            emailAddressChange: emailAddressChange,
            errors: errors)
    }
}
