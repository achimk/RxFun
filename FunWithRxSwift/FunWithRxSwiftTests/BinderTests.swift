//
//  Created by Joachim Kret on 21/02/2020.
//  Copyright © 2020 Joachim Kret. All rights reserved.
//

import Foundation
import XCTest
import RxSwift
import RxCocoa
@testable import FunWithRxSwift

final class BinderTests: XCTestCase {
    
    private var bag = DisposeBag()
    
    override func tearDown() {
        bag = DisposeBag()
        super.tearDown()
    }
    
    func testBind() {

        var results: [Int] = []
        let publisher = PublishRelay<Int>()
        let aBinder = Binder(publisher)
        
        publisher.subscribe(onNext: { value in
            results.append(value)
        }).disposed(by: bag)
        
        let input = PublishRelay<Int>()
        input.bind(to: aBinder).disposed(by: bag)
        
        input.accept(1)
        input.accept(2)
        input.accept(3)
        
        XCTAssertEqual(results, [1, 2, 3])
    }
}
