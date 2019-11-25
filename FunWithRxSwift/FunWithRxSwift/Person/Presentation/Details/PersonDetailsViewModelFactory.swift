//
//  Created by Joachim Kret on 25/11/2019.
//  Copyright © 2019 Joachim Kret. All rights reserved.
//

import Foundation
import RxSwift

struct PersonDetailsViewModelFactory {
    
    typealias ViewModel = (PersonDetailsInput) -> (DisposeBag) -> PersonDetailsOutput
    
    static func create(api: PersonAPI, id: PersonId) -> ViewModel {
        let state = PersonDetailsObservable(api: api, id: id)
        let localizer = StubPersonDetailsLocalizer()
        return PersonDetailsViewModel(state: state, localizer: localizer).transform(_:)
    }
    
}
