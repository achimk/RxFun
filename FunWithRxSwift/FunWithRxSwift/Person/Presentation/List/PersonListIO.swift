//
//  Created by Joachim Kret on 25/11/2019.
//  Copyright © 2019 Joachim Kret. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

struct PersonListInput {
    var refresh: Signal<Void> = .empty()
}

struct PersonListOutput {
    var inProgress: Driver<Bool> = .empty()
    var items: Driver<PersonListViewData> = .empty()
    var lastError: Driver<String> = .empty()
}
