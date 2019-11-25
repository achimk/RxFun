//
//  Created by Joachim Kret on 25/11/2019.
//  Copyright © 2019 Joachim Kret. All rights reserved.
//

import Foundation
import RxSwift

final class PersonDetailsObservable: ObservableConvertibleType {
    
    func asObservable() -> Observable<ViewState<[Person], Swift.Error>> {
        return .empty()
    }
}
