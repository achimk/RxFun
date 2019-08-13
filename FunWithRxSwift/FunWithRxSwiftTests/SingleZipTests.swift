//
//  SingleZipTests.swift
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

final class SingleZipTests: XCTestCase {
    
    struct TestError: Swift.Error { }
    
    var bag = DisposeBag()
    
    override func tearDown() {
        bag = DisposeBag()
    }
    
    func testSingleZip() {
        
        let source1 = Single.just(1).delay(0.3, scheduler: ConcurrentDispatchQueueScheduler(qos: .background))
        
        let source2 = Single.just(2).delay(0.2, scheduler: ConcurrentDispatchQueueScheduler(qos: .background))
        
        let source3 = Single.just(3).delay(0.1, scheduler: ConcurrentDispatchQueueScheduler(qos: .background))
        
        let error = Single<Int>.error(TestError()).delay(0.4, scheduler: ConcurrentDispatchQueueScheduler(qos: .background))
        
        let zipped = Single.zip(
            source1,
            source2,
            source3,
            error
        )
        
        let e = self.expectation(description: "")
        
        zipped
            .debug()
            .subscribe(onSuccess: { _ in
                e.fulfill()
            }, onError: { _ in
                e.fulfill()
            }).disposed(by: bag)
        
        wait(for: [e], timeout: 3)
    }
}
