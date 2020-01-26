//
//  Created by Joachim Kret on 25/11/2019.
//  Copyright © 2019 Joachim Kret. All rights reserved.
//

import Foundation

protocol PersonFormAPI {
    func createForm() -> PersonForm
    func update(name: String?, for form: PersonForm) -> PersonForm
    func update(surname: String?, for form: PersonForm) -> PersonForm
    func update(age: UInt?, for form: PersonForm) -> PersonForm
    func update(gender: Gender?, for form: PersonForm) -> PersonForm
}
