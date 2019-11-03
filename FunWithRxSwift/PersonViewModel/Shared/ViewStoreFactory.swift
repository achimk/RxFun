//
//  Created by Joachim Kret on 21/10/2019.
//  Copyright © 2019 Joachim Kret. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public struct ViewStoreFactory<Request, Response> {
    
    public typealias State = ViewStateRequest<Request, Response, Swift.Error>
    
    public enum Behaviour {
        case waitIfEmpty
        case loadIfEmpty(Request)
    }
    
    internal typealias Feedback = (ObservableSchedulerContext<State>) -> Observable<Action>
    
    internal enum Action {
        case refresh(Request)
        case Response(Response)
        case failure(Swift.Error)
    }
    
    public var provider: (Request) -> Single<Response>
    public var refresh: Observable<Request>
    public var behaviour: Behaviour
    public var scheduler: ImmediateSchedulerType
    
    private init(
        provider: @escaping (Request) -> Single<Response>,
        refresh: Observable<Request>,
        behaviour: Behaviour,
        scheduler: ImmediateSchedulerType? = nil) {
        
        self.provider = provider
        self.refresh = refresh
        self.behaviour = behaviour
        self.scheduler = scheduler ?? SerialDispatchQueueScheduler(qos: .userInteractive)
    }
    
    public func create() -> Observable<State> {
        
        let reduce = prepareReducer()
        let feedbackUI = prepareUIFeedback(refresh: refresh)
        let feedbackEffect = prepareEffectFeedback(behaviour: behaviour, provider: provider)
        
        return Observable.system(
            initialState: .init(),
            reduce: reduce,
            scheduler: scheduler,
            scheduledFeedback: feedbackUI, feedbackEffect)
    }
    
    private func prepareReducer() -> (State, Action) -> State {
        return { (state, action) in
            switch action {
            case .refresh(let request):
                return state.toLoading(request)
            case .Response(let value):
                return state.toCompleted(value)
            case .failure(let error):
                return state.toFailed(error)
            }
        }
    }
    
    private func prepareUIFeedback(refresh: Observable<Request>) -> Feedback {
        return bind { (state) -> (Bindings<Action>) in
            let events: [Observable<Action>] = [
                refresh.map { Action.refresh($0) }
            ]
            return Bindings(
                subscriptions: [],
                events: events)
        }
    }
    
    private func prepareEffectFeedback(behaviour: Behaviour, provider: @escaping (Request) -> Single<Response>) -> Feedback {
        return react(query: { $0 }, areEqual: prepareStateEqual()) { (request) -> Observable<Action> in
            
            var action: Observable<Action> = .empty()
            
            request.ifEmpty {
                if case .loadIfEmpty(let request) = behaviour {
                    action = .just(.refresh(request))
                }
            }
            
            request.ifLoading { (request) in
                action = provider(request)
                    .asObservable()
                    .map { Action.Response($0) }
                    .catchError { .just(Action.failure($0)) }
            }
            
            return action
        }
    }
    
    private func prepareStateEqual() -> (State, State) -> Bool {
        return { (lhs, rhs) in
            switch (lhs.state, rhs.state) {
            case (.empty, .empty): return true
            case (.loading, .loading): return true
            case (.completed, .completed): return true
            case (.failed, .failed): return true
            default: return false
            }
        }
    }
}

extension ViewStoreFactory {
    
    public static func using(
        provider: @escaping () -> Single<Response>,
        refresh: Observable<Void>,
        shouldLoadIfEmpty: Bool = true,
        scheduler: ImmediateSchedulerType? = nil) -> ViewStoreFactory<Void, Response> {
        
        let behaviour: ViewStoreFactory<Void, Response>.Behaviour = shouldLoadIfEmpty
            ? .loadIfEmpty(())
            : .waitIfEmpty
        
        return .init(provider: { _ in provider() }, refresh: refresh, behaviour: behaviour, scheduler: scheduler)
    }
    
    public static func using(
        provider: @escaping (Request) -> Single<Response>,
        refresh: Observable<Request>,
        behaviour: Behaviour,
        scheduler: ImmediateSchedulerType? = nil) -> ViewStoreFactory<Request, Response> {
        
        return .init(provider: provider, refresh: refresh, behaviour: behaviour, scheduler: scheduler)
    }
}
