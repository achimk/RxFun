//
//  ShareTests.swift
//  FunWithRxSwiftTests
//
//  Created by Joachim Kret on 23/07/2019.
//  Copyright © 2019 Joachim Kret. All rights reserved.
//

import Foundation
import XCTest
import RxSwift

final class ShareTests: XCTestCase {
 
    struct Error: Swift.Error { }
    
    var bag = DisposeBag()
    
    override func tearDown() {
        bag = DisposeBag()
    }
    
    func testShare() {
        
        let single = Single<Int>.create { (eventConsumer) -> Disposable in
            
            print("-> create...")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                
                eventConsumer(.success(1))
                print("-> consumed...")
            })
            
            return Disposables.create()
        }
        
        
        
        let operation = single
            .map { value -> Int in
                throw Error()
                print("-> multiply...")
                return value * 2
            }
            .asObservable()
            .share()
            .asSingle()
        
        
        let e1 = expectation(description: "")
        let e2 = expectation(description: "")
        
        subscribe(operation, label: "first", expectation: e1)
        subscribe(operation, label: "second", expectation: e2)
        
        wait(for: [e1, e2], timeout: 3)
    }
    
    private func subscribe<T>(_ single: Single<T>, label: String = "test", expectation: XCTestExpectation) {
        
        single.subscribe { (event) in
            switch event {
            case .error(let err):
                print("\(label): error \(err)", Thread.isMainThread)
                expectation.fulfill()
            case .success(let value):
                print("\(label): next \(value)", Thread.isMainThread)
                expectation.fulfill()
            }
        }.disposed(by: bag)
    }
}
