//
//  Created by Joachim Kret on 26/02/2020.
//  Copyright © 2020 Joachim Kret. All rights reserved.
//

import XCTest
import RxSwift
import RxCocoa
import RxTest

final class CounterObservable: ObservableConvertibleType {
    
    private let state = BehaviorRelay<Int>(value: 0)
    
    var current: Int { return state.value }
    
    func increment() {
        state.accept(state.value + 1)
    }
    
    func decrement() {
        state.accept(state.value - 1)
    }
    
    func asObservable() -> Observable<Int> {
        return state.asObservable()
    }
}

final class CounterViewModel {
    
    struct Input {
        var increment: Binder<Void>
        var decrement: Binder<Void>
    }
    
    struct Output {
        var current: Driver<String>
    }
    
    let input: Input
    let output: Output
    
    init(state: CounterObservable) {
        
        // Input
        let increment = Binder<Void>(state, binding: { (state, _) in state.increment() })
        let decrement = Binder<Void>(state, binding: { (state, _) in state.decrement() })
        
        // Output
        let current = state
            .asObservable()
            .map { "Counter: \($0)" }
            .asDriver(onErrorDriveWith: .empty())
        
        // Setup
        self.input = Input(increment: increment, decrement: decrement)
        self.output = Output(current: current)
    }
    
}

final class ScheduledCounterObservableTests: XCTestCase {
    
    private var bag = DisposeBag()
    
    override func tearDown() {
        bag = DisposeBag()
        super.tearDown()
    }
    
    func testInitialState() {
        
        let state = CounterObservable()
        let scheduler = TestScheduler(initialClock: 200)
        let pipeline = scheduler.start { () -> Observable<Int> in
            return state.asObservable()
        }
        
        XCTAssertEqual(pipeline.events, [
            .next(200, 0)
        ])
        
        XCTAssertEqual(state.current, 0)
    }
    
    func testIncrement() {

        let state = CounterObservable()
        let scheduler = TestScheduler(initialClock: 200)
        
        scheduler.scheduleAt(400, action: state.increment)
        scheduler.scheduleAt(600, action: state.increment)
        scheduler.scheduleAt(800, action: state.increment)
        
        let pipeline = scheduler.start { () -> Observable<Int> in
            return state.asObservable()
        }

        XCTAssertEqual(pipeline.events, [
            .next(200, 0),
            .next(400, 1),
            .next(600, 2),
            .next(800, 3),
        ])
        
        XCTAssertEqual(state.current, 3)
    }
    
    func testDecrement() {
        
        let state = CounterObservable()
        let scheduler = TestScheduler(initialClock: 200)
        
        scheduler.scheduleAt(400, action: state.decrement)
        scheduler.scheduleAt(600, action: state.decrement)
        scheduler.scheduleAt(800, action: state.decrement)
        
        let pipeline = scheduler.start { () -> Observable<Int> in
            return state.asObservable()
        }

        XCTAssertEqual(pipeline.events, [
            .next(200, 0),
            .next(400, -1),
            .next(600, -2),
            .next(800, -3),
        ])
        
        XCTAssertEqual(state.current, -3)
    }
    
    func testIncrementAndDecrement() {
        
        let state = CounterObservable()
        let scheduler = TestScheduler(initialClock: 200)
        
        scheduler.scheduleAt(400, action: state.increment)
        scheduler.scheduleAt(600, action: state.decrement)
        
        let pipeline = scheduler.start { () -> Observable<Int> in
            return state.asObservable()
        }

        XCTAssertEqual(pipeline.events, [
            .next(200, 0),
            .next(400, 1),
            .next(600, 0),
        ])
        
        XCTAssertEqual(state.current, 0)
    }
}

final class ScheduledCounterViewModelTests: XCTestCase {
    
    func testBind() {
        
        let components = prepareTestCompoments()
        let scheduler = TestScheduler(initialClock: 200)
        
        let pipeline = scheduler.start { () -> Observable<String> in
            return components.viewModel.output.current.asObservable()
        }
        
        XCTAssertEqual(pipeline.events, [
            .next(200, "Counter: 0")
        ])
    }
    
    func testIncrement() {
        
        let components = prepareTestCompoments()
        let scheduler = TestScheduler(initialClock: 200)
        
        scheduler.scheduleAt(400, action: components.action.increment)
        
        let pipeline = scheduler.start { () -> Observable<String> in
            return components.viewModel.output.current.asObservable()
        }
        
        XCTAssertEqual(pipeline.events, [
            .next(200, "Counter: 0"),
            .next(400, "Counter: 1"),
        ])
    }
    
    func testDecrement() {
        
        let components = prepareTestCompoments()
        let scheduler = TestScheduler(initialClock: 200)
        
        scheduler.scheduleAt(400, action: components.action.decrement)
        
        let pipeline = scheduler.start { () -> Observable<String> in
            return components.viewModel.output.current.asObservable()
        }
        
        XCTAssertEqual(pipeline.events, [
            .next(200, "Counter: 0"),
            .next(400, "Counter: -1"),
        ])
    }
    
    func testIncrementAndDecrement() {
        
        let components = prepareTestCompoments()
        let scheduler = TestScheduler(initialClock: 200)
        
        scheduler.scheduleAt(400, action: components.action.increment)
        scheduler.scheduleAt(600, action: components.action.decrement)
        
        let pipeline = scheduler.start { () -> Observable<String> in
            return components.viewModel.output.current.asObservable()
        }
        
        XCTAssertEqual(pipeline.events, [
            .next(200, "Counter: 0"),
            .next(400, "Counter: 1"),
            .next(600, "Counter: 0"),
        ])
    }
    
    typealias TestComponents = (viewModel: CounterViewModel, state: CounterObservable, action: Action)
    typealias Action = (increment: () -> (), decrement: () -> ())
    
    private func prepareTestCompoments() -> TestComponents {
        
        let state = CounterObservable()
        
        let viewModel = CounterViewModel(state: state)
        
        let increment = { viewModel.input.increment.onNext(()) }
        let decrement = { viewModel.input.decrement.onNext(()) }
    
        return (viewModel, state, (increment, decrement))
    }
}

final class NaturalCounterObservableTests: XCTestCase {
    
    private var lastExpectation: XCTestExpectation?
    private var lastState: [Int] = [] {
        didSet { lastExpectation?.fulfill(); lastExpectation = nil }
    }
    private var bag = DisposeBag()
    
    override func tearDown() {
        lastState = []
        bag = DisposeBag()
        super.tearDown()
    }
    
    func testInitialState() {
        
        let components = prepareTestComponents()
        bind(components.state)
        
        XCTAssertEqual(lastState, [0])
    }
    
    func testIncrement() {
        
        let components = prepareTestComponents()
        bind(components.state)
        
        wait(for: components.action.increment)
        
        XCTAssertEqual(lastState, [0, 1])
    }
    
    func testDecrement() {
        
        let components = prepareTestComponents()
        bind(components.state)
        
        wait(for: components.action.decrement)
        
        XCTAssertEqual(lastState, [0, -1])
    }
    
    func testIncrementAndDecrement() {
        
        let components = prepareTestComponents()
        bind(components.state)
        
        wait(for: components.action.increment)
        wait(for: components.action.decrement)
        
        XCTAssertEqual(lastState, [0, 1, 0])
    }
    
    private func bind(_ state: CounterObservable) {
        state.asObservable().subscribe(onNext: { [weak self] value in
            self?.lastState.append(value)
        }).disposed(by: bag)
    }
    
    private func wait(for action: () -> ()) {
        let e = expectation(description: "wait")
        self.lastExpectation = e
        action()
        wait(for: [e], timeout: 1)
    }
    
    private typealias TestComponents = (state: CounterObservable, action: Action)
    private typealias Action = (increment: () -> (), decrement: () -> ())
    
    private func prepareTestComponents() -> TestComponents {
        
        let state = CounterObservable()
        let increment = state.increment
        let decrement = state.decrement
        
        return (state, (increment, decrement))
    }
}

final class NaturalCounterViewModelTests: XCTestCase {
    
    private var lastExpectation: XCTestExpectation?
    private var lastState: [String] = [] {
        didSet { lastExpectation?.fulfill(); lastExpectation = nil }
    }
    private var bag = DisposeBag()
    
    override func tearDown() {
        lastState = []
        bag = DisposeBag()
        super.tearDown()
    }
    
    func testInitialState() {
        
        let components = prepareTestComponents()
        bind(components.viewModel)
        
        XCTAssertEqual(lastState, ["Counter: 0"])
    }
    
    func testIncrement() {
        
        let components = prepareTestComponents()
        bind(components.viewModel)
        
        wait(for: components.action.increment)
        
        XCTAssertEqual(lastState, [
            "Counter: 0",
            "Counter: 1"
        ])
    }
    
    func testDecrement() {
        
        let components = prepareTestComponents()
        bind(components.viewModel)

        wait(for: components.action.decrement)
        
        XCTAssertEqual(lastState, [
            "Counter: 0",
            "Counter: -1"
        ])
    }
    
    func testIncrementAndDecrement() {
        
        let components = prepareTestComponents()
        bind(components.viewModel)
        
        wait(for: components.action.increment)
        wait(for: components.action.decrement)
        
        XCTAssertEqual(lastState, [
            "Counter: 0",
            "Counter: 1",
            "Counter: 0"
        ])
        
        
    }
    
    private func bind(_ viewModel: CounterViewModel) {
        viewModel.output.current.drive(onNext: { [weak self] value in
            self?.lastState.append(value)
        }).disposed(by: bag)
    }
    
    private func wait(for action: () -> ()) {
        let e = expectation(description: "wait")
        self.lastExpectation = e
        action()
        wait(for: [e], timeout: 1)
    }
    
    private typealias TestComponents = (state: CounterObservable, viewModel: CounterViewModel, action: Action)
    private typealias Action = (increment: () -> (), decrement: () -> ())
    
    private func prepareTestComponents() -> TestComponents {
        
        let state = CounterObservable()
        let viewModel = CounterViewModel(state: state)
        let increment = { viewModel.input.increment.onNext(()) }
        let decrement = { viewModel.input.decrement.onNext(()) }
        
        return (state, viewModel, (increment, decrement))
    }
}
