//
//  Created by Joachim Kret on 25/11/2019.
//  Copyright © 2019 Joachim Kret. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

final class ViewDataStateObservable<Request, Response>: ObservableConvertibleType {

    typealias State = ViewDataState<Response, Swift.Error>
    
    private let dispatcher = PublishSubject<(Request, Bool)>()
    private let state = BehaviorRelay<State>(value: .initial)
    private var bag = DisposeBag()
    
    init(scheduler: SchedulerType = MainScheduler.instance,
         reducer: @escaping (Request) -> Single<Response>) {
        prepareReduce(scheduler: scheduler, reducer: reducer)
    }

    func dispatch(_ request: Request, force: Bool = false) {
        dispatcher.onNext((request, force))
    }
    
    func asObservable() -> Observable<State> {
        return state.asObservable()
    }
}

extension ViewDataStateObservable {
    
    private func prepareReduce(
        scheduler: SchedulerType,
        reducer: @escaping (Request) -> Single<Response>) {
        
        let request = dispatcher
            .observeOn(scheduler)
            .map { [state] (request, force) in
                return (request, force, state.value)
            }.filter { (_, force, state) in
                force || !state.isLoading
            }.share(replay: 1)
        
        let onLoad = request.flatMap { (_, force, state) -> Observable<State> in
            if force && state.isLoading { return .empty() }
            return .just(.loading(previous: state.lastState))
        }
        
        let onResult = request.flatMapLatest { (request, _, _) -> Observable<State> in
            reducer(request)
                .asObservable()
                .map { State.success($0) }
                .catchError { .just(State.failure($0)) }
        }
        
        Observable
            .merge(onLoad, onResult)
            .subscribeOn(scheduler)
            .bind(to: state)
            .disposed(by: bag)
    }
}

extension ViewDataStateObservable where Request == Void {
    
    func refresh(force: Bool = false) {
        dispatch((), force: force)
    }
}
