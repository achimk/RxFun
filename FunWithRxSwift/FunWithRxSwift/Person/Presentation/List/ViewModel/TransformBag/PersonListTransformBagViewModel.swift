//
//  Created by Joachim Kret on 25/11/2019.
//  Copyright © 2019 Joachim Kret. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

struct PersonListTransformBagViewModel {
    
    struct Input {
        var refresh: Signal<Void> = .empty()
    }

    struct Output {
        var inProgress: Driver<Bool> = .empty()
        var items: Driver<PersonListViewData> = .empty()
        var lastError: Driver<String?> = .empty()
    }
    
    let state: PersonListObservable
    let localizer: PersonListLocalizing
    let wireframe: (PersonListWireframe) -> ()
    
    func transform(_ input: Input, with bag: DisposeBag) -> Output {
        
        let localizer = self.localizer
        var output = Output()
        
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
        
        let refresh = self.state.refresh
        input.refresh.emit(onNext: refresh).disposed(by: bag)
        
        return output
    }
    
    private func prepareViewDataFactory() -> (PersonListObservable.State) -> PersonListViewData {
        let wireframe = self.wireframe
        return { state in
            return PersonListViewDataFactory(persons: state.items, wireframe: wireframe).create()
        }
    }
}
