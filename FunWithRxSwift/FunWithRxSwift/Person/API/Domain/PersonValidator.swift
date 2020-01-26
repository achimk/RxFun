//
//  Created by Joachim Kret on 24/11/2019.
//  Copyright © 2019 Joachim Kret. All rights reserved.
//

import Foundation

enum PersonValidationKey: String {
    case name
    case surname
    case age
    case gender
}

enum PersonValidationError: Swift.Error {
    case invalidName
    case invalidSurname
    case invalidAge
    case invalidGender
}

func validatePerson(name: String?) -> Result<String, PersonValidationError> {
    let value: String? = name.flatMap { value in
        if value.count > 0 { return value }
        else { return nil }
    }
    
    return value.map(Result.success) ?? .failure(.invalidName)
}

func validatePerson(surname: String?) -> Result<String, PersonValidationError> {
    let value: String? = surname.flatMap { value in
        if value.count > 0 { return value }
        else { return nil }
    }
    
    return value.map(Result.success) ?? .failure(.invalidSurname)
}

func validatePerson(age: UInt?) -> Result<UInt, PersonValidationError> {
    let value: UInt? = age.flatMap { value in
        if value >= 18 { return value }
        else { return nil }
    }
    
    return value.map(Result.success) ?? .failure(.invalidAge)
}

func validatePerson(gender: Gender?) -> Result<Gender, PersonValidationError> {
    return gender.map(Result.success) ?? Result.failure(.invalidGender)
}

func validatePerson(_ unvalidated: UnvalidatedPerson, id: PersonId) -> ValidatedResult<Person, [PersonValidationKey: PersonValidationError]> {
    
    let nameResult = validatePerson(name: unvalidated.name)
    let surnameResult = validatePerson(surname: unvalidated.surname)
    let ageResult = validatePerson(age: unvalidated.age)
    let genderResult = validatePerson(gender: unvalidated.gender)
    
    do {
        
        let person = Person.init(
            id: id,
            name: try nameResult.get(),
            surname: try surnameResult.get(),
            age: try ageResult.get(),
            gender: try genderResult.get())

        return .valid(person)
        
    } catch {
        
        var errors: [PersonValidationKey: PersonValidationError] = [:]
        errors[.name] = nameResult.error
        errors[.surname] = surnameResult.error
        errors[.age] = ageResult.error
        errors[.gender] = genderResult.error
        
        return .invalid(errors)
    }
}
