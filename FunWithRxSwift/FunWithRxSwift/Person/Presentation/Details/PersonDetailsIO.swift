//
//  Created by Joachim Kret on 25/11/2019.
//  Copyright © 2019 Joachim Kret. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

struct PersonDetailsInput {
    var refresh: Signal<Void> = .empty()
}

struct PersonDetailsOutput {
 
    typealias DisplayViewModel = (DisplayPersonDetailsInput) -> DisplayPersonDetailsOutput
    
    var inProgress: Driver<Bool> = .empty()
    var display: Driver<DisplayViewModel> = .empty()
    var lastError: Driver<String> = .empty()
}
