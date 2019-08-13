//
//  ActivityIdicatorTests.swift
//  FunWithRxSwiftTests
//
//  Created by Joachim Kret on 13/08/2019.
//  Copyright © 2019 Joachim Kret. All rights reserved.
//

import XCTest
import RxSwift
import RxCocoa
import FunWithRxSwift

final class ActivityIndicatorTests: XCTestCase {
    
    var bag = DisposeBag()
    
    override func tearDown() {
        bag = DisposeBag()
    }
    
    func testActivityIndicator() {
        
        var states: [Bool] = []
        let activity = ActivityIndicator()
        let e = expectation(description: #function)
        
        let r = Observable.just(1)
            .flatMap { _ in
                return Single<Int>
                    .just(2)
                    .delay(1, scheduler: MainScheduler.instance)
                    .trackActivity(activity)
        }
        
        activity.asObservable().subscribe(onNext: { state in
            states.append(state)
            print("-> activity: ", state)
            if states == [false, true, false] {
                e.fulfill()
            }
        }).disposed(by: bag)
        
        r.subscribe(onNext: { value in
            XCTAssertTrue(value == 2)
        }, onError: { _ in
            XCTFail("should never happen")
        }).disposed(by: bag)
        
        waitForExpectations(timeout: 3)
    }
}
