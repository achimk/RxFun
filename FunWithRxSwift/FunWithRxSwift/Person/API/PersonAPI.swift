//
//  Created by Joachim Kret on 24/11/2019.
//  Copyright © 2019 Joachim Kret. All rights reserved.
//

import Foundation
import RxSwift

protocol PersonAPI {
    func allPersons() -> Single<[Person]>
    func person(with id: PersonId) -> Single<PersonDetails>
    func update(with id: PersonId, person: UnvalidatedPerson, address: UnvalidatedAddress) -> Single<PersonDetails>
    func submit(with id: PersonId, form: PersonForm) -> Single<ValidatedResult<Void, PersonForm>>
}
