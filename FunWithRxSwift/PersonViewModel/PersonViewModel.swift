//
//  Created by Joachim Kret on 21/10/2019.
//  Copyright © 2019 Joachim Kret. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

struct PersonInput {
    var refresh: Signal<Void> = .empty()
}

struct PersonOutput {
    var inProgress: Driver<Bool> = .empty()
    var name: Driver<String> = .empty()
    var surname: Driver<String> = .empty()
}

struct PersonViewModel {

    let provider: () -> Single<Person>
    
    func transform(_ input: PersonInput) -> PersonOutput {
        
        let detailsInput = PersonDetailsInput()
        let fetchInput = FetchInput(refresh: input.refresh)
        
        let fetchVM = FetchViewModel(provider: provider, mapper: { PersonDetailsViewModel(person: $0) })

        let fetchOutput = fetchVM.transform(fetchInput)
        let detailsOutput = fetchOutput.result.drive {
            $0.map { $0.transform(detailsInput) }
        }.asDriver(onErrorDriveWith: .never())
        
        return PersonOutput(
            inProgress: fetchOutput.inProgress,
            name: detailsOutput.flatMap { $0.name },
            surname: detailsOutput.flatMap { $0.surname })
    }
}
