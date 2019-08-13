//
//  Created by Joachim Kret on 06/08/2019.
//  Copyright © 2019 Joachim Kret. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxBlocking
import XCTest
@testable import FunWithRxSwift

final class FeedbackTests: XCTestCase {
    
    typealias Feedback<State, Event> = (ObservableSchedulerContext<State>) -> Observable<Event>
    
    var bag = DisposeBag()
    
    enum Action {
        case increment
        case decrement
        case reset(Int)
    }
    
    override func tearDown() {
        bag = DisposeBag()
    }
    
    func testFeedback() {
        
        let initial: Int = 0
        let plus = PublishSubject<Void>()
        let minus = PublishSubject<Void>()
        let reset = PublishSubject<Int>()
        let output = PublishSubject<Int>()
        
        let increment = { DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: { plus.onNext(()) }) }
        let decrement = { DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: { minus.onNext(()) }) }
        
        let reducer: (Int, Action) -> Int = { (state, action) in
            print(action, Thread.isMainThread)
            switch action {
            case .decrement:
                return state - 1
            case .increment:
                return state + 1
            case .reset(let count):
                return count
            }
        }

        let feedback: Feedback<Int, Action> = bind { (state) -> Bindings<Action> in
            
            let subscriptions: [Disposable] = [
                state.bind(to: output)
            ]
            
            let events: [Observable<Action>] = [
                plus.map({ _ in Action.increment }),
                minus.map({ _ in Action.decrement })
            ]
            
            return Bindings(
                subscriptions: subscriptions,
                events: events)
        }
        
        Observable.system(
            initialState: initial,
            reduce: reducer,
            scheduler: SerialDispatchQueueScheduler(qos: .background),
            scheduledFeedback: feedback)
            .subscribe(onNext: { value in
                print("value = \(value)", Thread.isMainThread)
            })
            .disposed(by: bag)
        

        let e = expectation(description: "")

        output.asDriver(onErrorDriveWith: .empty()).drive(onNext: { value in
//            print("value = \(value)", Thread.isMainThread)
            if value == 3 { e.fulfill() }
        }).disposed(by: bag)
     
        increment()
        decrement()
        increment()
        increment()
        increment()
        
        wait(for: [e], timeout: 3)
    }
}
