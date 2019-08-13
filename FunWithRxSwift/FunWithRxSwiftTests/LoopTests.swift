//
//  LoopTests.swift
//  FunWithRxSwiftTests
//
//  Created by Joachim Kret on 03/08/2019.
//  Copyright © 2019 Joachim Kret. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxBlocking
import XCTest

final class LoopTests: XCTestCase {
    
    var disposeBag = DisposeBag()
    
    override func tearDown() {
        disposeBag = DisposeBag()
    }
    
    func testLoop() {
        
        let (observable, publisher) = prepareStatusObservable()
        
        let e = expectation(description: "")
        subscribe(observable, label: "loop", expectation: e)
        
//        publisher.onNext(Date())
        
        wait(for: [e], timeout: 20)
        
    }
    
    private func prepareStatusObservable() -> (Observable<Int>, PublishSubject<Date>) {
        
        let timeout = Date().addingTimeInterval(10)
        let shouldTimeout: (Date) -> Bool = { timeout < $0 }
        
        let threshold = Observable<Date>.create { (observer) -> Disposable in
            let date = Date()
            observer.onNext(date)
            observer.onCompleted()
            return Disposables.create()
        }

        let statusProvider: () -> Single<Int> = {
            return .just(1)
        }
        
        let publisher = PublishSubject<Date>()//.debug("-> publisher")
//        let e = self.expectation(description: "")
//        subscribe(publisher.asObservable(), label: "publisher", expectation: e)
        
//        publisher.subscribe(onNext: { _ in
//            publisher.onNext(Date())
//        }).disposed(by: disposeBag)
        
        let observable = Observable<Int>.create { (observer) -> Disposable in

            let publisher = PublishSubject<Date>()//.debug("-> publisher")
            
            let delayed = publisher.delay(1, scheduler: MainScheduler.instance)
            
            let subscriber =
//                delayed
                Observable
                .merge(delayed.debug("debug"), threshold.debug("trigger"))
                .flatMap { date in statusProvider().map { (date, $0) } }
//                .map { ($0, 1) }
                .subscribe(onNext: { (date, status) in
                    
                    var status = status
                    
                    if shouldTimeout(date) {
                        print("-> should timeout!")
                        status = 10
                    }
                    
                    observer.onNext(status)
                    
                    if status < 10 {
                        publisher.onNext(Date())
                    } else {
                        observer.onCompleted()
                    }

                }, onError: { error in
                    observer.onError(error)
                })
            
//            publisher.onNext(Date())
            
            return subscriber
        }
        
        return (observable, publisher)
    }
    
    private func subscribe<T>(_ observable: Observable<T>, label: String, expectation: XCTestExpectation) {
        
        observable.subscribe { (event) in
            switch event {
            case .error(let error):
                print("\(label): error: \(error)", Thread.isMainThread)
            case .next(let element):
                print("\(label): next \(element)", Thread.isMainThread)
            case .completed:
                print("\(label): completed", Thread.isMainThread)
                expectation.fulfill()
                
            }
            }.disposed(by: disposeBag)
    }
}
