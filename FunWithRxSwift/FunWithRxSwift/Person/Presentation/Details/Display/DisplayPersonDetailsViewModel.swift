//
//  Created by Joachim Kret on 25/11/2019.
//  Copyright © 2019 Joachim Kret. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

struct DisplayPersonDetailsViewModel {
    
    let details: PersonDetails
    
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
            name: details.person.name,
            surname: details.person.surname,
            age: String(details.person.age))
        
        return viewData
    }
    
    private func prepareAddressViewData() -> DisplayAddressDetailsViewData {
        
        var viewData = DisplayAddressDetailsViewData()
        
        switch details.address {
        case .emailOnly(let email):
            viewData.email = email.value
        case .postalOnly(let postal):
            viewData.street = postal.street
            viewData.city = postal.city
            viewData.postCode = postal.postCode
        case .all(let postal, let email):
            viewData.street = postal.street
            viewData.city = postal.city
            viewData.postCode = postal.postCode
            viewData.email = email.value
        }
        
        return viewData
    }
}
