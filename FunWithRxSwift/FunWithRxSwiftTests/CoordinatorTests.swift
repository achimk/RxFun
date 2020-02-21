//
//  CoordinatorTests.swift
//  FunWithRxSwiftTests
//
//  Created by Joachim Kret on 20/02/2020.
//  Copyright © 2020 Joachim Kret. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol Wireframe { }

class BaseCoordinator<W: Wireframe> {
    let id = UUID()
    let wireframe = PublishRelay<W>()
    
    private let bag = DisposeBag()
    private var childCoordinators: [UUID: Any] = [:]
    
    func coordinate<C: BaseCoordinator>(to coordinator: C) {
        register(coordinator)
        let id = coordinator.id
        let bag = coordinator.bag
        coordinator.wireframe
            .do(onDispose: { [weak self] in self?.unregister(id) })
            .bind(to: wireframe)
            .disposed(by: bag)
    }
    
    private func register<C: BaseCoordinator>(_ coordinator: C) {
        childCoordinators[coordinator.id] = coordinator
    }
    
    private func unregister(_ id: UUID) {
        childCoordinators[id] = nil
    }
}
