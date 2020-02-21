//
//  CoordinatorTests.swift
//  FunWithRxSwiftTests
//
//  Created by Joachim Kret on 20/02/2020.
//  Copyright © 2020 Joachim Kret. All rights reserved.
//

import XCTest
import Foundation
import RxSwift
import RxCocoa

protocol Wireframe { }

class BaseCoordinator<W: Wireframe> {
    
    final class WireframeObservable: ObservableConvertibleType, ObserverType {

        private let publisher = PublishRelay<Wireframe>()

        func accept(_ wireframe: W) {
            publisher.accept(wireframe)
        }
        
        func on(_ event: Event<Wireframe>) {
            switch event {
            case .next(let wireframe):
                publisher.accept(wireframe)
            default: break
            }
        }
        
        func asObservable() -> Observable<Wireframe> {
            return publisher.asObservable()
        }
    }
    
    let id = UUID()
    let wireframe = WireframeObservable()
    private let bag = DisposeBag()
    private var childCoordinators: [UUID: Any] = [:]
    
    
    func coordinate<W: Wireframe, C: BaseCoordinator<W>>(to coordinator: C) {
        register(coordinator)
        let id = coordinator.id
        let bag = coordinator.bag
        coordinator.wireframe.asObservable()
            .do(onDispose: { [weak self] in self?.unregister(id) })
            .bind(to: wireframe)
            .disposed(by: bag)
    }
    
    private func register<W: Wireframe, C: BaseCoordinator<W>>(_ coordinator: C) {
        childCoordinators[coordinator.id] = coordinator
    }
    
    private func unregister(_ id: UUID) {
        childCoordinators[id] = nil
    }
}

enum WireframeA: Wireframe {
    case actionA
}

class CoordA: BaseCoordinator<WireframeA> {
    
    func notify() {
        wireframe.accept(.actionA)
    }
}

enum WireframeB: Wireframe {
    case actionB
}

class CoordB: BaseCoordinator<WireframeB> {
    
    func notify() {
        wireframe.accept(.actionB)
    }
}


final class CoordTests: XCTestCase {
    
    private var bag = DisposeBag()
    
    override func tearDown() {
        bag = DisposeBag()
        super.tearDown()
    }
    
    func testBind() {
        
        var aEvents: [Wireframe] = []
        var bEvents: [Wireframe] = []
        
        let a = CoordA()
        let b = CoordB()
        
        a.coordinate(to: b)
        
        a.wireframe.asObservable().subscribe(onNext: { wireframe in
            aEvents.append(wireframe)
        }).disposed(by: bag)
        
        b.wireframe.asObservable().subscribe(onNext: { (wireframe) in
            bEvents.append(wireframe)
        }).disposed(by: bag)
        
        b.notify()
        a.notify()
        
        XCTAssertEqual(aEvents.count, 2)
        XCTAssertEqual(bEvents.count, 1)
        
        print(aEvents) // [WireframeB.actionB, WireframeA.actionA]
        print(bEvents) // [WireframeB.actionB]
    }
}
