//
//  CacheTests.swift
//  FunWithRxSwiftTests
//
//  Created by Joachim Kret on 23/07/2019.
//  Copyright © 2019 Joachim Kret. All rights reserved.
//

import Foundation
import RxSwift
import XCTest

final class SingleCache<Key: Hashable, Value> {
    
    fileprivate final class Cache<Key: Hashable, Value> {

        let lock = NSRecursiveLock()
        private var data: [Key : Value] = [:]
        
        var keys: [Key] {
            lock.lock(); defer { lock.unlock() }
            return data.keys.map { $0 }
        }
        
        func value(for key: Key) -> Value? {
            lock.lock(); defer { lock.unlock() }
            return data[key]
        }
        
        func set(value: Value, for key: Key) {
            lock.lock(); defer { lock.unlock() }
            data[key] = value
        }
        
        func remove(for key: Key) {
            lock.lock(); defer { lock.unlock() }
            data.removeValue(forKey: key)
        }
        
        func removeAll() {
            lock.lock(); defer { lock.unlock() }
            data.removeAll()
        }
    }
    
    private var cache = Cache<Key, Single<Value>>()
    
    var allKeys: [Key] { return cache.keys }
    
    init() { }
    
    func cached(for key: Key, otherwise: () -> Single<Value>) -> Single<Value> {
        if let source = find(for: key) { return source }
        else { return store(otherwise(), for: key) }
    }
    
    func invalidate() {
        cache.removeAll()
    }
    
    private func find(for key: Key) -> Single<Value>? {
        return cache.value(for: key)
    }
    
    @discardableResult
    private func store(_ source: Single<Value>, for key: Key) -> Single<Value> {
        let shared = source
            .asObservable()
            .do(onError: { [cache] _ in  cache.remove(for: key) })
            .share(replay: 1, scope: .forever)
            .asSingle()
        
        cache.set(value: shared, for: key)
        
        return shared
    }
}

final class CacheTests: XCTestCase {
    
    typealias CacheObservable = SingleCache
    
    struct Err: Swift.Error { }
    
    var bag = DisposeBag()
    var cache = CacheObservable<String, Int>()
    
    override func tearDown() {
        bag = DisposeBag()
        cache = CacheObservable<String, Int>()
    }
    
    func testCacheSingleSuccess() {
        
        var counter = 0
        
        let source = cache.cached(for: "first") {
//            return Observable<Int>.create({ (consumer) -> Disposable in
//
//                print("-> ... create 0 ...")
//
////                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
////
////                    consumer.onNext(0)
////
////                })
//
//                consumer.onNext(0)
//                return Disposables.create()
//            })
            
            if counter == 0 {
                counter += 1
                return Single<Int>.create(subscribe: { (consumer) -> Disposable in
                    print("... error 1 ...")
                    consumer(.error(Err()))
                    return Disposables.create()
                })
            }
            
            return Single<Int>.create(subscribe: { (consumer) -> Disposable in
                print("... create 1 ...")
                consumer(.success(1))
                return Disposables.create()
            })
            
        }
        
        let e1 = self.expectation(description: "1")
        subscribe(source, label: "first", expectation: e1)
        
        let source2 = cache.cached(for: "first") {
            
            return Single<Int>.create(subscribe: { (consumer) -> Disposable in
                print("... create 2 ...")
                consumer(.success(2))
                return Disposables.create()
            })
            
        }
        
        let e2 = self.expectation(description: "2")
        subscribe(source2, label: "second", expectation: e2)
        
        
        let e3 = self.expectation(description: "3")
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            
            let source3 = self.cache.cached(for: "first", otherwise: {
                return .just(3)
            })
            
            self.subscribe(source3, label: "third", expectation: e3)
        }
        
        wait(for: [e1, e2, e3], timeout: 6)
    }
    
    private func subscribe<T>(_ observable: Observable<T>, label: String, expectation: XCTestExpectation) {
        
        observable.subscribe { (event) in
            switch event {
            case .error(let error):
                print("\(label): error: \(error)", Thread.isMainThread)
                expectation.fulfill()
            case .next(let element):
                print("\(label): next \(element)", Thread.isMainThread)
                expectation.fulfill()
            case .completed:
                print("\(label): completed", Thread.isMainThread)
                
            }
        }.disposed(by: bag)
    }
    
    private func subscribe<T>(_ single: Single<T>, label: String, expectation: XCTestExpectation) {
        
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
