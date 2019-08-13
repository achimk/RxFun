//
//  SingleInFlatMapTests.swift
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

final class SingleInFlatMapTests: XCTestCase {
    
    struct TestError: Swift.Error { }
    
    var bag = DisposeBag()
    
    override func tearDown() {
        bag = DisposeBag()
    }
    
    func testSingleInFlatMap() {
        
        let trigger = PublishSubject<Void>()
        let e = expectation(description: "")
        
        var counter = 0
        trigger
            .flatMap {
                return Single.just(1)
            }
            .flatMap { _ in
                return Single.just(2)
            }
            .flatMap { _ in
                return Single<Int>.error(TestError())
            }
            .debug("observable")
            .subscribe(onNext: { value in
                counter = counter + value
                if counter == 6 {
                    e.fulfill()
                }
            }, onError: { _ in
                e.fulfill()
            })
            .disposed(by: bag)
        
        Single.just(3).debug("single").subscribe().disposed(by: bag)

        trigger.onNext(())
        trigger.onNext(())
        trigger.onNext(())
        
        wait(for: [e], timeout: 3)
    }
}
