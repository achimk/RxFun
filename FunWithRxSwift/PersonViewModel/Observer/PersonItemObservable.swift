//
//  Created by Joachim Kret on 04/11/2019.
//  Copyright © 2019 Joachim Kret. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

final class PersonItemObservable: ObservableConvertibleType {

    enum Action {
        case update(person: Person)
    }
    
    let trigger = PublishSubject<Action>()
    let state: Observable<ViewState<PersonItem, Swift.Error>>
    let id: PersonId
    let api: PersonAPI
    let bag = DisposeBag()
    
    init(item: PersonItem, api: PersonAPI) {
     
        let provider: (Action) -> Single<PersonItem> = { action in
            switch action {
            case .update(let person):
                let newItem = PersonItem(id: item.id, initials: person.name + " " + person.surname)
                return .just(newItem)
                
            }
        }
        
        self.id = item.id
        self.api = api
        self.state = ViewStoreFactory<Action, PersonItem>.using(
            provider: provider,
            refresh: trigger,
            behaviour: .completed(item))
            .create()
            .map { $0.state }
    }
    
    func dispatch(_ action: Action) {
        trigger.onNext(action)
    }
    
    func asObservable() -> Observable<ViewState<PersonItem, Swift.Error>> {
        return state
    }
    
    func asPersonDetailsObservable() -> PersonDetailsObservable {
        let observable = PersonDetailsObservable(id: id, api: api)
        
        observable.state
            .compactMap { $0.value }
            .map { Action.update(person: $0) }
            .subscribe(trigger)
            .disposed(by: bag)
        
        return observable
    }
}
