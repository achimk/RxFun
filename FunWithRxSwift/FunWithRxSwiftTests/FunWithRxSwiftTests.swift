//
//  FunWithRxSwiftTests.swift
//  FunWithRxSwiftTests
//
//  Created by Joachim Kret on 19/07/2019.
//  Copyright © 2019 Joachim Kret. All rights reserved.
//

import XCTest
import RxSwift
import RxBlocking
@testable import FunWithRxSwift

class FunWithRxSwiftTests: XCTestCase {
    
    var bag = DisposeBag()

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        bag = DisposeBag()
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let hasCache = true
        
        let cache: Observable<Int> = hasCache
            ? Observable.just(1).debug("cached")
            : Observable.empty()
        
        let suffix: Observable<Int> = Observable
            .just(2)
            .debug("source")
            .delay(1, scheduler: MainScheduler.instance)
            .do(onNext: { print("-> cache value: \($0)") })
        
        let operation = Observable.concat(cache, suffix).asSingle()
        
        let e = expectation(description: "")
        
        operation.subscribe { (event) in
            switch event {
            case .error(let err):
                print(": error \(err)")
                e.fulfill()
            case .success(let value):
                print(": next \(value)")
                e.fulfill()
//            case .next(let value):
//                print(": next \(value)")
//            case .completed:
//                print(": completed")
//                e.fulfill()
            }
        }.disposed(by: bag)
        
        wait(for: [e], timeout: 3)
    }

    
    func testCacheLatest() {
        
        let subject = PublishSubject<Int>()
        
        let zipped = Observable.zip(subject, subject.skip(1)).take(1).asSingle()
        
        let operation = zipped
        
        operation.subscribe { (event) in
            switch event {
            case .success(let element):
                print(": success \(element)")
            case .error(let err):
                print(": error \(err)")
//                e.fulfill()
//            case .next(let value):
//                print(": next \(value)")
//            case .completed:
//                print(": completed")
//                e.fulfill()
            }
            }.disposed(by: bag)
        
        subject.onNext(1)
        subject.onNext(2)
        subject.onNext(3)
    }

}

func skip() -> Observable<(Int?, Int?)> {
    
    let subject = PublishSubject<Int?>()
    
    return Observable.zip(subject, subject.skip(1))
}

func zippedCache(_ generate: @escaping (Int?) -> Int) -> Observable<Int> {
    
    let lhs = PublishSubject<Int?>()
    let rhs = PublishSubject<Int?>()
    
    let d = Observable.zip(lhs, rhs).map { (l, r) -> Int in
        let value = generate(l)
        lhs.onNext(value)
        return value
    }
    
    fatalError()
}

enum Result<T, E> {
    case success(T)
    case failure(E)
}

enum CacheError {
    case empty
    case error(Swift.Error)
}

func cacheLatest<T>(_ factory: @escaping () -> Observable<T>) -> Observable<T> {
    
    let lhs = PublishSubject<Result<T, CacheError>>()
    let rhs = PublishSubject<Result<T, CacheError>>()
    
    
    
    let zipped = Observable.zip(lhs, rhs)
    
    lhs.onNext(.failure(.empty))
    rhs.onNext(.failure(.empty))
    
    
    
//    return
    
    fatalError()
}
