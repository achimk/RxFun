//
//  Created by Joachim Kret on 25/11/2019.
//  Copyright © 2019 Joachim Kret. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

struct PersonListViewModel {
    
    let state: PersonListObservable
    let localizer: PersonListLocalizing
    let wireframe: (PersonListWireframe) -> ()
    
    func transform(_ input: PersonListInput) -> (DisposeBag) -> PersonListOutput {
        
        let localizer = self.localizer
        let wireframe = self.wireframe
        var output = PersonListOutput()
        
        output.inProgress = state
            .asObservable()
            .map { $0.isLoading }
            .asDriver(onErrorJustReturn: false)
        
        output.items = state
            .asObservable()
            .map { state -> PersonListViewData in
                if case .success(let data) = state {
                    return PersonListViewDataFactory(persons: data, wireframe: wireframe).create()
                } else {
                    return PersonListViewDataFactory(persons: [], wireframe: wireframe).create()
                }
            }
            .asDriver(onErrorDriveWith: .empty())
        
        output.lastError = state
            .asObservable()
            .compactMap { state in
                if case .failure = state { return localizer.localizedUnexpectedError }
                else { return nil }
            }
            .asDriver(onErrorDriveWith: .empty())
        
        let refresh = state.refresh
        
        return { bag in
            
            input.refresh.emit(onNext: refresh).disposed(by: bag)
            
            return output
        }
    }
}
