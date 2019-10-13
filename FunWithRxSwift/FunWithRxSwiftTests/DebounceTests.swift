//
//  DebounceTests.swift
//  FunWithRxSwiftTests
//
//  Created by Joachim Kret on 30/07/2019.
//  Copyright © 2019 Joachim Kret. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxBlocking
import XCTest

final class DebounceTests: XCTestCase {
    
    var disposeBag = DisposeBag()
    
    override func tearDown() {
        disposeBag = DisposeBag()
    }
    
    func testDebounce() {
        
        let observableA = BehaviorRelay(value: 0)
        let observableB = BehaviorRelay(value: 1)
        
        observableA
            .debounce(.seconds(3), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe(onNext: { value in
                observableB.accept(value)
            }).disposed(by: disposeBag)
        
        observableA.accept(2)
        
        let result = try? observableB.skip(1).toBlocking().first()
        
        print(result)
    }
}
