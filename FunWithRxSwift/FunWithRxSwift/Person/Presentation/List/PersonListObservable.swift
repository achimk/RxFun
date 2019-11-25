//
//  Created by Joachim Kret on 25/11/2019.
//  Copyright © 2019 Joachim Kret. All rights reserved.
//

import Foundation
import RxSwift

final class PersonListObservable: ObservableConvertibleType {
    
    enum Action {
        case refresh
    }
    
    private let state: ViewStateObservable<Action, [Person]>
    
    init(api: PersonAPI) {
        self.state = ViewStateObservable<Action, [Person]>.init(reducer: { (action) -> Single<[Person]> in
            switch action {
            case .refresh:
                return api.allPersons()
            }
        })
    }
    
    func refresh() {
        dispatch(.refresh)
    }
    
    func dispatch(_ action: Action) {
        state.dispatch(action)
    }
    
    func asObservable() -> Observable<ViewState<[Person], Swift.Error>> {
        return .empty()
    }
}