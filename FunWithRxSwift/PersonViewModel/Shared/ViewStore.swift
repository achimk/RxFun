//
//  Created by Joachim Kret on 21/10/2019.
//  Copyright © 2019 Joachim Kret. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public struct ViewStore<T> {
    
    public enum Behaviour {
        case waitIfEmpty
        case loadIfEmpty
    }
    
    enum Action {
        case refresh
        case success(T)
        case failure(Swift.Error)
    }
    
    public typealias State = ViewState<T, Swift.Error>
    typealias Feedback = (ObservableSchedulerContext<State>) -> Observable<Action>
    
    public var provider: () -> Single<T>
    public var refresh: Observable<Void>
    public var behaviour: Behaviour
    public var scheduler: ImmediateSchedulerType
    
    public init(
        provider: @escaping () -> Single<T>,
        refresh: Observable<Void> = .empty(),
        behaviour: Behaviour = .loadIfEmpty,
        scheduler: ImmediateSchedulerType = SerialDispatchQueueScheduler(qos: .userInteractive)) {
        
        self.provider = provider
        self.refresh = refresh
        self.behaviour = behaviour
        self.scheduler = scheduler
    }
    
    public func create() -> Observable<State> {
        
        let reduce = prepareReducer()
        let feedbackUI = prepareUIFeedback(refresh: refresh)
        let feedbackEffect = prepareEffectFeedback(behaviour: behaviour, provider: provider)
        
        return Observable.system(
            initialState: .empty,
            reduce: reduce,
            scheduler: scheduler,
            scheduledFeedback: feedbackUI, feedbackEffect)
    }
    
    private func prepareReducer() -> (State, Action) -> State {
        return { (state, action) in
            switch action {
            case .refresh:
                return .loading(previous: state.asResult())
            case .success(let value):
                return .completed(value)
            case .failure(let error):
                return .failed(error)
            }
        }
    }
    
    private func prepareUIFeedback(refresh: Observable<Void>) -> Feedback {
        return bind { (state) -> (Bindings<Action>) in
            let events: [Observable<Action>] = [
                refresh.map { Action.refresh }
            ]
            return Bindings(
                subscriptions: [],
                events: events)
        }
    }
    
    private func prepareEffectFeedback(behaviour: Behaviour, provider: @escaping () -> Single<T>) -> Feedback {
        return react(query: { $0 }) { (state) -> Observable<Action> in
            switch state {
            case .empty:
                return behaviour == .loadIfEmpty ? .just(.refresh) : .never()
            case .loading:
                return provider()
                .asObservable()
                .map { Action.success($0) }
                .catchError { .just(Action.failure($0)) }
            case .failed,
                 .completed:
                return .never()
            }
        }
    }
}
