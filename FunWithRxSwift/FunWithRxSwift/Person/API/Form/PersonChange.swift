//
//  Created by Joachim Kret on 25/11/2019.
//  Copyright © 2019 Joachim Kret. All rights reserved.
//

import Foundation

struct PersonChange {
    
    struct Change<T> {
        var original: T
        var value: T
        var isModified: Bool
    }
    
    let name: Change<String?>
    let surname: Change<String?>
    let age: Change<UInt?>
    let gender: Change<Gender?>
    let isModified: Bool
    
    private init(name: Change<String?>,
                 surname: Change<String?>,
                 age: Change<UInt?>,
                 gender: Change<Gender?>) {
        
        self.name = name
        self.surname = surname
        self.age = age
        self.gender = gender
        self.isModified = name.isModified || surname.isModified || age.isModified || gender.isModified
    }
    
    init(name: String?, surname: String?, age: UInt?, gender: Gender?) {
        self.name = .init(original: name, value: name, isModified: false)
        self.surname = .init(original: surname, value: surname, isModified: false)
        self.age = .init(original: age, value: age, isModified: false)
        self.gender = .init(original: gender, value: gender, isModified: false)
        self.isModified = false
    }
    
    func updated(name value: String?) -> PersonChange {
        var change = name
        change.value = value
        change.isModified = change.original != value
        return PersonChange(name: change, surname: surname, age: age, gender: gender)
    }
    
    func updated(surname value: String?) -> PersonChange {
        var change = surname
        change.value = value
        change.isModified = change.original != value
        return PersonChange(name: name, surname: change, age: age, gender: gender)
    }
    
    func updated(age value: UInt?) -> PersonChange {
        var change = age
        change.value = value
        change.isModified = change.original != value
        return PersonChange(name: name, surname: surname, age: change, gender: gender)
    }
    
    func updated(gender value: Gender?) -> PersonChange {
        var change = gender
        change.value = value
        change.isModified = change.original != value
        return PersonChange(name: name, surname: surname, age: age, gender: change)
    }
}
