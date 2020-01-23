//
//  Created by Joachim Kret on 25/11/2019.
//  Copyright © 2019 Joachim Kret. All rights reserved.
//

import Foundation
import RxSwift

final class PersonDetailsObservable: ObservableConvertibleType {
    
    enum Action {
        case refresh
        case update(UnvalidatedPerson, UnvalidatedAddress)
    }
    
    private let state: ResultStateObservable<Action, PersonDetails>
    
    init(api: PersonAPI, id: PersonId) {
        self.state = ResultStateObservable<Action, PersonDetails> { (action) -> Single<PersonDetails> in
            switch action {
            case .refresh:
                return api.person(with: id)
            case .update(let person, let address):
                return api.update(with: id, person: person, address: address)
            }
        }
    }
    
    func refresh() {
        dispatch(.refresh)
    }
    
    func dispatch(_ action: Action) {
        state.dispatch(action)
    }
    
    func asObservable() -> Observable<ResultState<PersonDetails, Swift.Error>> {
        return state.asObservable()
    }
}
