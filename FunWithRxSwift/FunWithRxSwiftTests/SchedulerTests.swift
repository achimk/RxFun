//
//  Created by Joachim Kret on 06/08/2019.
//  Copyright © 2019 Joachim Kret. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxBlocking
import XCTest

final class SchedulerTests: XCTestCase {
    
    var bag = DisposeBag()
    
    override func tearDown() {
        bag = DisposeBag()
    }
    
    func testSerialScheduler() {
        
        let source1 = Observable.just(1).delay(3, scheduler: ConcurrentDispatchQueueScheduler(qos: .background))
        
        let source2 = Observable.just(2).delay(2, scheduler: ConcurrentDispatchQueueScheduler(qos: .background))
        
        let source3 = Observable.just(3).delay(1, scheduler: ConcurrentDispatchQueueScheduler(qos: .background))
        
        
        var counter = 0
        let bag = self.bag
        let e = expectation(description: "")
        
        let dispatch: (Observable<Int>) -> () = {
            
            $0.subscribeOn(MainScheduler.instance)
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { value in
                    counter = counter.advanced(by: 1)
                    print("-> value: \(value)")
                    if counter == 3 {
                        e.fulfill()
                    }
                })
                .disposed(by: bag)
        }
        
        dispatch(source1)
        dispatch(source2)
        dispatch(source3)
        
        wait(for: [e], timeout: 10)
    }
}
