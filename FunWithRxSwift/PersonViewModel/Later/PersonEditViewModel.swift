//
//  Created by Joachim Kret on 20/10/2019.
//  Copyright © 2019 Joachim Kret. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

struct PersonEditInput {
    var name: Signal<String?> = .empty()
    var surname: Signal<String?> = .empty()
    var submit: Signal<Void> = .empty()
}

struct PersonEditOutput {
    
}

struct PersonEditViewModel {
    
    func transform(_ input: PersonEditInput) -> PersonEditOutput {
        
        var output = PersonEditOutput()
        
        return output
    }
}
