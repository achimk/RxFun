//
//  Created by Joachim Kret on 24/11/2019.
//  Copyright © 2019 Joachim Kret. All rights reserved.
//

import Foundation

enum PersonValidationKey: String {
    case name
    case surname
    case age
}

enum PersonValidationError: Swift.Error {
    case invalidName
    case invalidSurname
    case invalidAge
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

func validatePerson(_ unvalidated: UnvalidatedPerson) -> ValidatedResult<Person, [PersonValidationKey: PersonValidationError]> {
    
    let nameResult = validatePerson(name: unvalidated.name)
    let surnameResult = validatePerson(surname: unvalidated.surname)
    let ageResult = validatePerson(age: unvalidated.age)
    
    do {
        
        let person = Person.init(
            id: unvalidated.id,
            name: try nameResult.get(),
            surname: try surnameResult.get(),
            age: try ageResult.get())

        return .valid(person)
        
    } catch {
        
        var errors: [PersonValidationKey: PersonValidationError] = [:]
        errors[.name] = nameResult.error
        errors[.surname] = surnameResult.error
        errors[.age] = ageResult.error
        
        return .invalid(errors)
    }
}
