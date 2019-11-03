//
//  Created by Joachim Kret on 20/10/2019.
//  Copyright © 2019 Joachim Kret. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

struct PersonDetailsInput {
}

struct PersonDetailsOutput {
    var name: Driver<String> = .empty()
    var surname: Driver<String> = .empty()
}

struct PersonDetailsViewModel {
    
    let person: Person
    
    func transform(_ input: PersonDetailsInput) -> PersonDetailsOutput {
        var output = PersonDetailsOutput()
        output.name = Driver.just(person.name)
        output.surname = Driver.just(person.surname)
        return output
    }
}

struct PersonEmptyViewModel {
 
    func transform(_ input: PersonDetailsInput) -> PersonDetailsOutput {
        var output = PersonDetailsOutput()
        output.name = Driver.just("-")
        output.surname = Driver.just("-")
        return output
    }
}

struct PersonErrorViewModel {
    
    let error: Swift.Error
    
    func transform(_ input: PersonDetailsInput) -> PersonDetailsOutput {
        var output = PersonDetailsOutput()
        output.name = Driver.just("-")
        output.surname = Driver.just("-")
        return output
    }
}
