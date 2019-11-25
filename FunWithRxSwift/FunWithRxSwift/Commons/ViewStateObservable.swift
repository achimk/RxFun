//
//  Created by Joachim Kret on 25/11/2019.
//  Copyright © 2019 Joachim Kret. All rights reserved.
//

import Foundation
import RxSwift

final class ViewStateObservable<Request, Response>: ObservableConvertibleType {

    typealias State = ViewState<Response, Swift.Error>
    
    private let dispatcher = PublishSubject<Request>()
    private let state = BehaviorSubject<State>(value: .initial)
    private var bag = DisposeBag()
    
    init(reducer: @escaping (Request) -> Single<Response>) {
        prepareReduce(with: reducer)
    }
    
    private func prepareReduce(with reducer: @escaping (Request) -> Single<Response>) {
        let consumeState: (State) -> () = self.state.onNext
        Observable.combineLatest(dispatcher, state)
            .filter { (_, state) in !state.isLoading }
            .do(onNext: { (_, state) in consumeState(.loading(previous: state)) })
            .flatMapLatest { (request, _) -> Observable<State> in
                return reducer(request)
                    .asObservable()
                    .map { State.success($0) }
                    .catchError { .just(State.failure($0)) }
            }
            .subscribe(onNext: consumeState)
            .disposed(by: bag)
    }
    
    func dispatch(_ request: Request) {
        dispatcher.onNext(request)
    }
    
    func asObservable() -> Observable<State> {
        return state.asObservable()
    }
}
