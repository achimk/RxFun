//
//  Created by Joachim Kret on 23/01/2020.
//  Copyright © 2020 Joachim Kret. All rights reserved.
//

import XCTest
import RxSwift
import RxCocoa
import RxTest
@testable import FunWithRxSwift

final class ViewDataStateObservableTests: XCTestCase {
    
    enum Error: Swift.Error {
        case test
    }
    
    enum Action {
        case refresh
        case succeeded(Int)
        case failed(Swift.Error)
    }
    
    typealias State = ViewDataState<Int, Swift.Error>
    typealias StateObservable = ViewDataStateObservable<Action, Int>
    
    private var bag = DisposeBag()
    
    override func tearDown() {
        bag = DisposeBag()
        super.tearDown()
    }
    
    func testInitial() {
    
        let scheduler = TestScheduler.init(initialClock: 0)
        let sut = StateObservable.init(scheduler: scheduler, reducer: prepareReducer())
        let output = scheduler.createObserver(State.self)
        
        sut.asObservable().bind(to: output).disposed(by: bag)
        
        XCTAssertEqual(output.events, [
            .next(0, .initial)
        ])
    }
    
    func testSuccess() {
        
        let sut = StateObservable.init(reducer: prepareReducer())
        let output = TestScheduler.init(initialClock: 0).createObserver(State.self)
        
        sut.asObservable().bind(to: output).disposed(by: bag)
        sut.dispatch(.succeeded(1))
        
        
        XCTAssertEqual(output.events, [
            .next(0, .initial),
            .next(0, .loading(previous: .initial)),
            .next(0, .success(1))
        ])
    }
    
    func testFailure() {
        
        let sut = StateObservable.init(reducer: prepareReducer())
        let output = TestScheduler.init(initialClock: 0).createObserver(State.self)
        
        sut.asObservable().bind(to: output).disposed(by: bag)
        sut.dispatch(.failed(Error.test))
        
        XCTAssertEqual(output.events, [
            .next(0, .initial),
            .next(0, .loading(previous: .initial)),
            .next(0, .failure(Error.test))
        ])
    }
    
    func testLoadingFinishSuccess() {
        
        let trigger = PublishSubject<Int>()
        let reducer = prepareReducer(onRefresh: { trigger.take(1).asSingle() })
        let sut = StateObservable.init(reducer: reducer)
        let output = TestScheduler.init(initialClock: 0).createObserver(State.self)
        
        sut.asObservable().bind(to: output).disposed(by: bag)
        
        XCTAssertEqual(output.events, [
            .next(0, .initial)
        ])
        
        sut.dispatch(.refresh)
        
        XCTAssertEqual(output.events, [
            .next(0, .initial),
            .next(0, .loading(previous: .initial))
        ])
        
        trigger.onNext(1)
        
        XCTAssertEqual(output.events, [
            .next(0, .initial),
            .next(0, .loading(previous: .initial)),
            .next(0, .success(1))
        ])
    }
    
    func testLoadingFinishFailure() {
        
        let trigger = PublishSubject<Int>()
        let reducer = prepareReducer(onRefresh: { trigger.take(1).asSingle() })
        let sut = StateObservable.init(reducer: reducer)
        let output = TestScheduler.init(initialClock: 0).createObserver(State.self)
        
        sut.asObservable().bind(to: output).disposed(by: bag)
        
        XCTAssertEqual(output.events, [
            .next(0, .initial)
        ])
        
        sut.dispatch(.refresh)
        
        XCTAssertEqual(output.events, [
            .next(0, .initial),
            .next(0, .loading(previous: .initial))
        ])
        
        trigger.onError(Error.test)
        
        XCTAssertEqual(output.events, [
            .next(0, .initial),
            .next(0, .loading(previous: .initial)),
            .next(0, .failure(Error.test))
        ])
    }
    
    func testDispatchNextAfterPrevious() {
        
        let sut = StateObservable.init(reducer: prepareReducer())
        let output = TestScheduler.init(initialClock: 0).createObserver(State.self)
        
        sut.asObservable().bind(to: output).disposed(by: bag)
        sut.dispatch(.succeeded(1))
        
        XCTAssertEqual(output.events, [
            .next(0, .initial),
            .next(0, .loading(previous: .initial)),
            .next(0, .success(1))
        ])
        
        sut.dispatch(.failed(Error.test))
        
        XCTAssertEqual(output.events, [
            .next(0, .initial),
            .next(0, .loading(previous: .initial)),
            .next(0, .success(1)),
            .next(0, .loading(previous: .success(1))),
            .next(0, .failure(Error.test))
        ])
    }
    
    func testDispatchNextDuringLoadingShouldBeRejected() {
        
        let trigger = PublishSubject<Int>()
        let reducer = prepareReducer(onRefresh: { trigger.take(1).asSingle() })
        let sut = StateObservable.init(reducer: reducer)
        let output = TestScheduler.init(initialClock: 0).createObserver(State.self)

        sut.asObservable().bind(to: output).disposed(by: bag)
        
        XCTAssertEqual(output.events, [
            .next(0, .initial)
        ])
        
        sut.dispatch(.refresh)
        
        XCTAssertEqual(output.events, [
            .next(0, .initial),
            .next(0, .loading(previous: .initial))
        ])
        
        sut.dispatch(.succeeded(1))
        
        XCTAssertEqual(output.events, [
            .next(0, .initial),
            .next(0, .loading(previous: .initial))
        ])
        
        trigger.onNext(2)
        
        XCTAssertEqual(output.events, [
            .next(0, .initial),
            .next(0, .loading(previous: .initial)),
            .next(0, .success(2))
        ])
    }
    
    func testForceDispatchNextDuringLoadingShouldBeAccepted() {
        
        let trigger = PublishSubject<Int>()
        let reducer = prepareReducer(onRefresh: { trigger.take(1).asSingle() })
        let sut = StateObservable.init(reducer: reducer)
        let output = TestScheduler.init(initialClock: 0).createObserver(State.self)

        sut.asObservable().bind(to: output).disposed(by: bag)
        
        XCTAssertEqual(output.events, [
            .next(0, .initial)
        ])
        
        sut.dispatch(.refresh)
        
        XCTAssertEqual(output.events, [
            .next(0, .initial),
            .next(0, .loading(previous: .initial))
        ])
        
        sut.dispatch(.succeeded(1), force: true)
        
        XCTAssertEqual(output.events, [
            .next(0, .initial),
            .next(0, .loading(previous: .initial)),
            .next(0, .success(1))
        ])
        
        trigger.onNext(2)
        
        XCTAssertEqual(output.events, [
            .next(0, .initial),
            .next(0, .loading(previous: .initial)),
            .next(0, .success(1))
        ])
    }
    
    private func prepareReducer(onRefresh: @escaping () -> Single<Int> = { .just(1) }) -> (Action) -> Single<Int> {
        
        return { action in
            
            switch action {
            case .refresh: return onRefresh()
            case .succeeded(let value): return .just(value)
            case .failed(let error): return .error(error)
            }
        }
    }
}
