//
//  DispatchTests.swift
//  FunWithRxSwiftTests
//
//  Created by Joachim Kret on 23/07/2019.
//  Copyright © 2019 Joachim Kret. All rights reserved.
//

import Foundation
import XCTest
import RxSwift

final class DispatchTests: XCTestCase {
    
    var bag = DisposeBag()
    
    override func tearDown() {
        bag = DisposeBag()
    }
    
    func testDispatch() {
    
        let single = Single.just(1)
            .map { data -> String in
                print(data, Thread.isMainThread)
                return String(data)
            }
            .map { data -> Int in
                print(data, Thread.isMainThread)
                return Int(data) ?? 1
            }
            .flatMap { data -> Single<Int> in
                print(data, Thread.isMainThread)
                return Single.just(2)
            }
        
        let e = expectation(description: "")
        
        let operation = dispatch(single)
        
        operation.subscribe { (event) in
            switch event {
            case .error(let err):
                print(": error \(err)", Thread.isMainThread)
                e.fulfill()
            case .success(let value):
                print(": next \(value)", Thread.isMainThread)
                e.fulfill()
            }
            }.disposed(by: bag)
        
        wait(for: [e], timeout: 3)
    }
    
    private func dispatch<T>(_ single: Single<T>) -> Single<T> {
        
        return single
            .subscribeOn(SerialDispatchQueueScheduler.init(qos: .userInteractive))
            .observeOn(MainScheduler.instance)
        
//        fatalError()
    }
}
