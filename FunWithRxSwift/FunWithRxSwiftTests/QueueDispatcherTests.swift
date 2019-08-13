//
//  QueueDispatcherTests.swift
//  FunWithRxSwiftTests
//
//  Created by Joachim Kret on 08/08/2019.
//  Copyright © 2019 Joachim Kret. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxBlocking
import XCTest
@testable import FunWithRxSwift

final class QueueDispatcherTests: XCTestCase {
    
    struct TestError: Swift.Error { }
    
    enum Action {
        case increment
        case decrement
        case offset(Int)
    }
    
    var bag = DisposeBag()
    
    override func tearDown() {
        bag = DisposeBag()
    }
    
    func testQueueDispatch() {
        
        let source1 = Single.just(1).delay(0.3, scheduler: ConcurrentDispatchQueueScheduler(qos: .background))
        
        let source2 = Single.just(2).delay(0.2, scheduler: ConcurrentDispatchQueueScheduler(qos: .background))
        
        let source3 = Single.just(3).delay(0.1, scheduler: ConcurrentDispatchQueueScheduler(qos: .background))
        
        let error = Single<Int>.error(TestError()).delay(0.1, scheduler: ConcurrentDispatchQueueScheduler(qos: .background))
        
        let e = expectation(description: "")
        
        typealias Factory<T> = (T) -> Single<T>
        let aggregate = BehaviorSubject<Int>(value: 0)
        let source = PublishSubject<Factory<Int>>()
        
        let r = Observable
            .zip(source, aggregate)
            .observeOn(SerialDispatchQueueScheduler(qos: .userInitiated))
            .flatMap { (data) -> Observable<Int> in
                let (factory, value) = data
                return factory(value)
                    .do(onSuccess: { aggregate.onNext($0) },
                        onError: { _ in aggregate.onNext(value) })
                    .asObservable()
                    .catchError { _ in .empty() }
            }
        
        r.debug()
        .observeOn(MainScheduler.instance)
        .subscribe(onNext: { value in
            
            print("<- \(value)", Thread.isMainThread)
            
            if value == 3 { e.fulfill() }
            
        }).disposed(by: bag)
        
        
        source.onNext({ value in print("-> \(value)", Thread.isMainThread); return source1 })
        
        source.onNext({ value in print("-> \(value)", Thread.isMainThread); return source2 })
        
        source.onNext({ value in print("-> \(value)", Thread.isMainThread); return error })
        
        source.onNext({ value in print("-> \(value)", Thread.isMainThread); return source3 })
        
        wait(for: [e], timeout: 3)
    }
    
    func testDispatcher() {
        
        let reducer: (Int, Action) -> Observable<Int> = { (state, action) in
            
            switch action {
                
            case .increment:
                return .just(state.advanced(by: 1))
                
            case .decrement:
                return .just(state.advanced(by: -1))
                
            case .offset(let value):
                return .just(state.advanced(by: value))
            }
        }
        
        let (consumer, state) = Dispatcher<Int, Action>.prepare(
            initialState: 0,
            reduce: reducer,
            scheduler: SerialDispatchQueueScheduler(qos: .userInitiated))
        
        
        let e = self.expectation(description: #function)
        state
            .debug()
            .subscribe(onNext: { value in
              
                if value == 3 { e.fulfill() }
                
            }).disposed(by: bag)
        
        consumer(.increment)
        consumer(.decrement)
        consumer(.increment)
        consumer(.increment)
        consumer(.increment)
        
        waitForExpectations(timeout: 3)
    }
}

final class Dispatcher<State, Event> {
    
    static func prepare(
        initialState: State,
        reduce: @escaping (State, Event) -> Observable<State>,
        scheduler: ImmediateSchedulerType) -> (consumer: (Event) -> (), state: Observable<State>) {
        
        let stateSubject = BehaviorSubject(value: initialState)
        let eventPublisher = PublishSubject<Event>()
        let stateObservable = Observable
            .zip(stateSubject, eventPublisher)
            .observeOn(scheduler)
            .flatMap { reduce($0.0, $0.1) }
            .do(onNext: stateSubject.onNext)
        
        return (eventPublisher.onNext, stateObservable)
    }
}
