//
//  Created by Joachim Kret on 25/11/2019.
//  Copyright © 2019 Joachim Kret. All rights reserved.
//

import Foundation
import RxSwift

struct PersonListTransformBagViewModelFactory {
    
    static func create(api: PersonAPI, wireframe: @escaping (PersonListWireframe) -> ()) -> PersonListTransformBagViewModel {
        let state = PersonListObservable(api: api)
        let localizer = StubPersonListLocalizer()
        return PersonListTransformBagViewModel(state: state, localizer: localizer, wireframe: wireframe)
    }
}
