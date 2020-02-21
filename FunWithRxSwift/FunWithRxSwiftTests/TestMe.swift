//
//  TestMe.swift
//  FunWithRxSwiftTests
//
//  Created by Joachim Kret on 17/02/2020.
//  Copyright © 2020 Joachim Kret. All rights reserved.
//

import XCTest
import RxSwift
import RxCocoa

final class TestMe: XCTestCase {
    
    class Container {
        
        struct NotFoundError: Error { }
        
        private let values: [Int]
        
        init(_ values: [Int] = []) { self.values = values }
        
        func retrieve(at index: Int) throws -> Int {
            if values.indices.contains(index) {
                return values[index]
            } else {
                throw NotFoundError()
            }
        }
    }
    
    func testA() throws {
        print("-> test A")

        let empty = Container([])
        
        _ = try empty.retrieve(at: 1)
        
        XCTFail("Should never happen!")
    }
    
    func testB() throws {
        print("-> test B")

        let empty = Container([1, 2, 3])
        
        let element = try empty.retrieve(at: 1)
        
        XCTAssertEqual(element, 2)
    }
}
