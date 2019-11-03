//
//  Created by Joachim Kret on 21/10/2019.
//  Copyright © 2019 Joachim Kret. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

struct PersonReturningVMInput {
    var refresh: Signal<Void> = .empty()
}

struct PersonReturningVMOutput {
    var inProgress: Driver<Bool> = .empty()
    var result: Driver<PersonDetailsViewModel> = .empty()
}

struct PersonReturningVM {

    let provider: () -> Single<Person>
    let progressIndicator = ActivityIndicator()
    
    func transform(_ input: PersonReturningVMInput) -> PersonReturningVMOutput {
        
        let provider = self.provider
        let progress = progressIndicator
        
        var output = PersonReturningVMOutput()
        output.inProgress = progress.asDriver()
        output.result = Observable.merge(
            Observable<Void>.just(()),
            input.refresh.asObservable())
            .withLatestFrom(progress)
            .filter { $0 == false }
            .flatMapLatest { _ in provider().trackActivity(progress) }
            .map { PersonDetailsViewModel(person: $0) }
            .asDriver(onErrorDriveWith: .never())

        return output
    }
}

struct PersonReturningVMWithFetchVM {

    let provider: () -> Single<Person>
    
    func transform(_ input: PersonReturningVMInput) -> PersonReturningVMOutput {
        
        let vm = FetchViewModel(provider: provider, mapper: { PersonDetailsViewModel(person: $0) })

        let output = vm.transform(FetchInput(refresh: input.refresh))
        
        return PersonReturningVMOutput(inProgress: output.inProgress, result: output.result)
    }
}

