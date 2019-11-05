//
//  Created by Joachim Kret on 20/10/2019.
//  Copyright © 2019 Joachim Kret. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol PersonAPI {
    func person(for id: PersonId) -> Single<Person>
    func allPersons() -> Single<[PersonItem]>
    func update(name: String, surname: String, for id: PersonId) -> Single<Person>
}
