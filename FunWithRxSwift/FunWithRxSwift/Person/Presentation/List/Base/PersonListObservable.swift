//
//  Created by Joachim Kret on 25/11/2019.
//  Copyright © 2019 Joachim Kret. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

final class PersonListObservable: ObservableConvertibleType {
    
    struct State {
        var items: [Person]
        var isLoading: Bool
        var error: Swift.Error?
        
        static func initial() -> State {
            return State(items: [], isLoading: false, error: nil)
        }
    }
    
    private let resultState: ResultStateObservable<Void, [Person]>
    private let state = BehaviorRelay<State>(value: .initial())
    private let bag = DisposeBag()
    
    init(api: PersonAPI) {
        resultState = ResultStateObservable<Void, [Person]>.init(reducer: { api.allPersons() })
        prepareBindings()
    }
    
    private func prepareBindings() {
        
        let state = self.state
        let reduce = prepareReducer()
        
        resultState.asObservable()
            .map { reduce($0, state.value) }
            .bind(to: state)
            .disposed(by: bag)
    }
    
    private func prepareReducer() -> (ResultState<[Person], Error>, State) -> State {
        return { (result, state) in
            switch result {
            case .initial:
                return state
            case .loading:
                var state = state
                state.isLoading = true
                state.error = nil
                return state
            case .failure(let error):
                var state = state
                state.isLoading = false
                state.error = error
                return state
            case .success(let persons):
                var state = state
                state.items = persons
                state.isLoading = false
                state.error = nil
                return state
            }
        }
    }
    
    func refresh() {
        resultState.refresh()
    }
    
    func asObservable() -> Observable<State> {
        return state.asObservable()
    }
}
