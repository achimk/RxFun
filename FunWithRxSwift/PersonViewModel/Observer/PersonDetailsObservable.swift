//
//  Created by Joachim Kret on 04/11/2019.
//  Copyright © 2019 Joachim Kret. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

final class PersonDetailsObservable: ObservableConvertibleType {

    enum Action {
        case refresh
        case update(name: String, surname: String)
    }
    
    let trigger = PublishSubject<Action>()
    let state: Observable<ViewState<Person, Swift.Error>>
    
    init(id: PersonId, api: PersonAPI) {
        
        let provider: (Action) -> Single<Person> = { action in
            switch action {
            case .refresh:
                return api.person(for: id)
            case .update(let name, let surname):
                return api.update(name: name, surname: surname, for: id)
            }
        }
        
        state = ViewStoreFactory<Action, Person>.using(
            provider: provider,
            refresh: trigger,
            behaviour: .loadIfEmpty(.refresh))
            .create()
            .map { $0.state }
    }
    
    func dispatch(_ action: Action) {
        trigger.onNext(action)
    }
    
    func asObservable() -> Observable<ViewState<Person, Swift.Error>> {
        return state
    }
    
}
