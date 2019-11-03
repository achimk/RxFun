//
//  Created by Joachim Kret on 20/10/2019.
//  Copyright © 2019 Joachim Kret. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

struct PersonPrepareViewModel {
    
    let api: PersonAPI
    
    
    func transform() {
        
//        let empty: () -> PersonEmptyViewModel = {
//            return PersonEmptyViewModel()
//        }
//
//        let error: (Swift.Error) -> PersonErrorViewModel = {
//            return PersonErrorViewModel(error: $0)
//        }
        
        let detailsInput = PersonDetailsInput()
        let details: (Person) -> PersonDetailsViewModel = {
            return PersonDetailsViewModel(person: $0)
        }
        
        let fetch = PersonFetchViewModel(provider: { [api] in
            api.person(for: PersonId(value: "1"))
        })
        
        let input = PersonFetchInput()
        let output = fetch.transform(input)

        let d = output.result.drive { (person) in
            person.map { details($0) }.map { $0.transform(detailsInput) }
        }
        .asDriver(onErrorDriveWith: .never())
        
    }
}
