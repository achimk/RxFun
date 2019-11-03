//
//  Created by Joachim Kret on 21/10/2019.
//  Copyright © 2019 Joachim Kret. All rights reserved.
//

import XCTest
import RxSwift
import RxCocoa
import FunWithRxSwift

final class ViewStoreTests: XCTestCase {
    
    private var bag = DisposeBag()
    
    override func tearDown() {
        bag = DisposeBag()
    }
    
    func testWaitIfEmptyStore() {
     
        let e = expectation(description: #function)
        let state = ViewStoreFactory<Void, Int>
            .using(provider: { Single<Int>.just(1) }, refresh: .empty(), shouldLoadIfEmpty: false)
            .create()
        
        state.subscribe(onNext: { (viewState) in
            print("*", viewState)
            viewState.ifEmpty { e.fulfill() }
        }).disposed(by: bag)
        
        waitForExpectations(timeout: 3)
    }
    
    func testLoadIfEmptyStore() {
     
        let e = expectation(description: #function)
        let state = ViewStoreFactory<Void, Int>
            .using(provider: { Single<Int>.just(1) }, refresh: .empty(), shouldLoadIfEmpty: true)
            .create()
        
        state.subscribe(onNext: { (viewState) in
            print("*", viewState)
            viewState.ifLoading { _ in e.fulfill() }
        }).disposed(by: bag)
        
        waitForExpectations(timeout: 3)
    }
    
    func testRefreshStore() {
        
        let e = expectation(description: #function)
        let refresh = PublishSubject<Void>()
        let state = ViewStoreFactory<Void, Int>
            .using(provider: { Single<Int>.just(1) }, refresh: refresh, shouldLoadIfEmpty: false)
            .create()
        
        state.subscribe(onNext: { (viewState) in
            print("*", viewState)
            viewState.ifLoading { _ in e.fulfill() }
        }).disposed(by: bag)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            refresh.onNext(())
        }
        
        waitForExpectations(timeout: 3)
    }
    
    func testCompleteWithSuccessStore() {
        
        let e = expectation(description: #function)
        let refresh = PublishSubject<Void>()
        let state = ViewStoreFactory<Void, Int>
            .using(provider: { Single<Int>.just(1) }, refresh: refresh, shouldLoadIfEmpty: false)
            .create()
        
        state.subscribe(onNext: { (viewState) in
            print("*", viewState)
            viewState.ifCompleted { _ in e.fulfill() }
        }).disposed(by: bag)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            refresh.onNext(())
        }
        
        waitForExpectations(timeout: 3)
    }
    
    func testCompleteWithFailureStore() {
        
        let e = expectation(description: #function)
        let error = NSError(domain: "test", code: 0, userInfo: nil)
        let refresh = PublishSubject<Void>()
        let state = ViewStoreFactory<Void, Int>
            .using(provider: { Single<Int>.error(error) }, refresh: refresh, shouldLoadIfEmpty: false)
            .create()
        
        state.subscribe(onNext: { (viewState) in
            print("*", viewState)
            viewState.ifFailed { _ in e.fulfill() }
        }).disposed(by: bag)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            refresh.onNext(())
        }
        
        waitForExpectations(timeout: 3)
    }
}
