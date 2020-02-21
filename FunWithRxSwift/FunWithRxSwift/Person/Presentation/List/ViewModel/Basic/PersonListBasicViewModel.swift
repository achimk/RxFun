//
//  Created by Joachim Kret on 21/02/2020.
//  Copyright © 2020 Joachim Kret. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

struct PersonListBasicViewModel {
    
    struct Input {
        let refresh: Binder<Void>
    }

    struct Output {
        var inProgress: Driver<Bool> = .empty()
        var items: Driver<PersonListViewData> = .empty()
        var lastError: Driver<String?> = .empty()
    }
    
    lazy var input: Input = prepareInput()
    lazy var output: Output = prepareOutput()
    
    private let state: PersonListObservable
    private let localizer: PersonListLocalizing
    private let wireframe: (PersonListWireframe) -> ()
    private let refreshTrigger = PublishRelay<Void>()
    private let bag = DisposeBag()

    init(state: PersonListObservable,
         localizer: PersonListLocalizing,
         wireframe: @escaping (PersonListWireframe) -> ()) {
        
        self.state = state
        self.localizer = localizer
        self.wireframe = wireframe
    }
    
    private func prepareInput() -> Input {
        return Input(refresh: Binder(refreshTrigger))
    }
    
    private func prepareOutput() -> Output {
        let localizer = self.localizer
        var output = Output()
        
        refreshTrigger.bind(onNext: self.state.refresh).disposed(by: bag)
        
        let state = self.state.asObservable().share()
        
        output.inProgress = state
            .map { $0.isLoading }
            .asDriver(onErrorJustReturn: false)
        
        output.items = state
            .map(prepareViewDataFactory())
            .asDriver(onErrorDriveWith: .empty())
        
        output.lastError = state
            .flatMap { state -> Observable<String?> in
                if state.error != nil {
                    let message = localizer.localizedUnexpectedError
                    return Observable.concat(.just(message), .just(nil))
                } else {
                    return .just(nil)
                }
            }
            .asDriver(onErrorDriveWith: .empty())

        return output
    }
    
    private func prepareViewDataFactory() -> (PersonListObservable.State) -> PersonListViewData {
        let wireframe = self.wireframe
        return { state in
            return PersonListViewDataFactory(persons: state.items, wireframe: wireframe).create()
        }
    }
}
