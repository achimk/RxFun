//
//  Created by Joachim Kret on 28/11/2019.
//  Copyright © 2019 Joachim Kret. All rights reserved.
//

import XCTest
import RxSwift
import RxCocoa
import FunWithRxSwift

final class FunctionalTests: XCTestCase {
 
    var bag = DisposeBag()
    
    override func tearDown() {
        bag = DisposeBag()
    }
    
    func testIdentity() {
     
        let result = Observable
            .just(true)
            .map(identity)
        
        result.subscribe(onNext: { (value) in
            print("-> identity: \(value)")
        }).disposed(by: bag)
    }
    
    func testIgnore() {
        
        let result = Observable
            .just(true)
            .map(ignore)

        result.subscribe(onNext: { (value) in
            print("-> ignore: \(value)")
        }).disposed(by: bag)
    }
    
    func testConstant() {
        
        let result = Observable
            .just(true)
            .map(constant(1))
        
        result.subscribe(onNext: { (value) in
            print("-> constant: \(value)")
        }).disposed(by: bag)
    }
    
    func testChaining() {
        
        let result1 = Observable.just(1)
            .map { _ in true }
            .filter { $0 }
            .map { _ in () }
        
        result1.subscribe(onNext: { (_) in
            print("result 1 success!")
        }).disposed(by: bag)
        
        let result2 = Observable.just(1)
            .map(constant(true))
            .filter(identity)
            .map(ignore)
        
        result2.subscribe(onNext: { (_) in
            print("result 2 success!")
        }).disposed(by: bag)
        
    }
    
    func testClosures() {
        
        apiCall(parameter: "1", completion: ignore)
        
    }
    
    private func apiCall<T>(parameter: T, completion: (T) -> ()) {
        print("-> api call: \(parameter)")
        completion(parameter)
    }
}
