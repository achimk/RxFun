//
//  ErrorTrackerTests.swift
//  FunWithRxSwiftTests
//
//  Created by Joachim Kret on 13/08/2019.
//  Copyright © 2019 Joachim Kret. All rights reserved.
//

import XCTest
import RxSwift
import RxCocoa
import FunWithRxSwift

final class ErrorTrackerTests: XCTestCase {
    
    struct TestError: Swift.Error { }
    
    var bag = DisposeBag()
    
    override func tearDown() {
        bag = DisposeBag()
    }
    
    func testErrorTracker() {
        
        let errorTracker = ErrorTracker()
        let e = expectation(description: #function)
        
        let r = Observable.just(1)
            .flatMap { _ in
                return Single<Int>
                    .error(TestError())
                    .trackError(errorTracker)
            }
        
        errorTracker.asObservable().subscribe(onNext: { error in
            XCTAssertNotNil(error as? TestError)
            e.fulfill()
        }).disposed(by: bag)
        
        r.subscribe(onNext: { _ in
            XCTFail("should never happen")
        }, onError: { error in
            XCTAssertNotNil(error as? TestError)
        }).disposed(by: bag)

        waitForExpectations(timeout: 3)
    }
}
