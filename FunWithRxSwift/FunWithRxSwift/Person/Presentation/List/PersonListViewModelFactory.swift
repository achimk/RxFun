//
//  Created by Joachim Kret on 25/11/2019.
//  Copyright © 2019 Joachim Kret. All rights reserved.
//

import Foundation
import RxSwift

struct PersonListViewModelFactory {
    
    typealias ViewModel = (PersonListInput) -> (DisposeBag) -> PersonListOutput
    
    static func create(api: PersonAPI, wireframe: @escaping (PersonListWireframe) -> ()) -> ViewModel {
        let state = PersonListObservable(api: api)
        let localizer = StubPersonListLocalizer()
        return PersonListViewModel(state: state, localizer: localizer, wireframe: wireframe).transform(_:)
    }
}
