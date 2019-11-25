//
//  Created by Joachim Kret on 25/11/2019.
//  Copyright © 2019 Joachim Kret. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

struct EmptyPersonDetailsViewModel {
    
    func transform(_ input: DisplayPersonDetailsInput) -> DisplayPersonDetailsOutput {
        
        let personViewData = preparePersonViewData()
        let addressViewData = prepareAddressViewData()
        
        var output = DisplayPersonDetailsOutput()
        output.person = Driver.just(personViewData)
        output.address = Driver.just(addressViewData)
        return output
    }
    
    private func preparePersonViewData() -> DisplayPersonDetailsViewData {
        
        let viewData = DisplayPersonDetailsViewData(
            name: "-",
            surname: "-",
            age: "-")
        
        return viewData
    }
    
    private func prepareAddressViewData() -> DisplayAddressDetailsViewData {
        
        var viewData = DisplayAddressDetailsViewData()
        viewData.street = "-"
        viewData.city = "-"
        viewData.postCode = "-"
        viewData.email = "-"
        
        return viewData
    }
}
