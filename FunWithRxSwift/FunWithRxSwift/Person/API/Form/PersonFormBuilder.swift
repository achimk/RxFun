//
//  Created by Joachim Kret on 25/11/2019.
//  Copyright © 2019 Joachim Kret. All rights reserved.
//

import Foundation

struct PersonFormBuilder {
    
    private var change: PersonChange
    private var errors: PersonErrors
    
    init(_ form: PersonForm) {
        self.change = form.change
        self.errors = form.errors
    }
    
    init(details: PersonDetails? = nil, errors: PersonErrors? = nil) {
        change = PersonChange(
            name: details?.person.name,
            surname: details?.person.surname,
            age: details?.person.age,
            gender: details?.person.gender)
        
        self.errors = errors ?? .init()
    }
    
    init(person: Person? = nil, errors: PersonErrors? = nil) {
        change = PersonChange(
            name: person?.name,
            surname: person?.surname,
            age: person?.age,
            gender: person?.gender)
        
        self.errors = errors ?? .init()
    }
    
    func set(name: String?) -> PersonFormBuilder {
        var builder = self
        builder.change = builder.change.updated(name: name)
        builder.errors.person[.name] = validatePerson(name: name).error
        return builder
    }
    
    func set(surname: String?) -> PersonFormBuilder {
        var builder = self
        builder.change = builder.change.updated(surname: surname)
        builder.errors.person[.surname] = validatePerson(surname: surname).error
        return builder
    }
    
    func set(age: UInt?) -> PersonFormBuilder {
        var builder = self
        builder.change = builder.change.updated(age: age)
        builder.errors.person[.age] = validatePerson(age: age).error
        return builder
    }
    
    func set(gender: Gender?) -> PersonFormBuilder {
        var builder = self
        builder.change = builder.change.updated(gender: gender)
        builder.errors.person[.age] = validatePerson(gender: gender).error
        return builder
    }
    
    func build() -> PersonForm {
        return PersonForm(
            change: change,
            errors: errors)
    }
}
