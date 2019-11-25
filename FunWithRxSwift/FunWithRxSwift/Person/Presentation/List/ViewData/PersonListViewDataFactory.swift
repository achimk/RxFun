//
//  Created by Joachim Kret on 25/11/2019.
//  Copyright © 2019 Joachim Kret. All rights reserved.
//

import Foundation

struct PersonListViewDataFactory {
    
    let persons: [Person]
    let wireframe: (PersonListWireframe) -> ()
    
    func create() -> PersonListViewData {
        return PersonListViewData(items: persons.map(toPersonViewData(_:)))
    }
    
    private func toPersonViewData(_ person: Person) -> PersonListViewData.PersonViewData {
        
        let wireframe = self.wireframe
        
        return PersonListViewData.PersonViewData(
            name: person.name,
            surname: person.surname,
            age: String(person.age),
            selectHandler: { wireframe(.personSelected(person.id)) })
    }
}
