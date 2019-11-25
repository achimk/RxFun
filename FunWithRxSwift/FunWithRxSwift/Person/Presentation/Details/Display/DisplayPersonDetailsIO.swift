//
//  Created by Joachim Kret on 25/11/2019.
//  Copyright © 2019 Joachim Kret. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

struct DisplayPersonDetailsInput {
}

struct DisplayPersonDetailsOutput {
    var person: Driver<DisplayPersonDetailsViewData> = .empty()
    var address: Driver<DisplayAddressDetailsViewData> = .empty()
}
