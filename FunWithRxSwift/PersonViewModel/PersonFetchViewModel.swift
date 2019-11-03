//
//  Created by Joachim Kret on 20/10/2019.
//  Copyright © 2019 Joachim Kret. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

struct PersonFetchInput {
    var refresh: Signal<Void> = .empty()
}

struct PersonFetchOutput {
    var inProgress: Driver<Bool> = .empty()
    var result: Driver<Person> = .empty()
}

struct PersonFetchViewModel {

    let provider: () -> Single<Person>
//    let mapper: (Person) -> T
    let progressIndicator = ActivityIndicator()
    
    func transform(_ input: PersonFetchInput) -> PersonFetchOutput {
        
        let provider = self.provider
        let progress = progressIndicator
        
        var output = PersonFetchOutput()
        output.inProgress = progress.asDriver()
        output.result = Observable.merge(
            Observable<Void>.just(()),
            input.refresh.asObservable())
            .withLatestFrom(progress)
            .filter { $0 == false }
            .flatMapLatest { _ in provider().trackActivity(progress) }
            .asDriver(onErrorDriveWith: .never())

        return output
    }
}
