//
//  Created by Joachim Kret on 28/02/2020.
//  Copyright © 2020 Joachim Kret. All rights reserved.
//

import XCTest
import RxSwift
import RxCocoa

final class ViewModelBinderTests: XCTestCase {
 
    final class Input {
        
        init(enterSearch: Binder<Void>, cancelSearch: Binder<Void>, searchText: Binder<String>) {
            self.enterSearch = enterSearch
            self.cancelSearch = cancelSearch
            self.searchText = searchText
        }
        
        var enterSearch: Binder<Void>
        var cancelSearch: Binder<Void>
        var searchText: Binder<String>
    }
    
    final class ViewModel {
   
        var enterSearch: Binder<Void>
        var cancelSearch: Binder<Void>
        var searchText: Binder<String>
        
        let input: Input
        let obj: NSObject
        
        init() {
            
            let obj = NSObject()
            
            let enterSearch = Binder<Void>(obj, binding: { (_, _) in
                print("-> enter search")
            })
            let cancelSearch = Binder<Void>(obj, binding: { (_, _) in
                print("-> cancel search")
            })
            let searchText = Binder<String>(obj, binding: { (_, _) in
                print("-> search text")
            })
            
                
            
            self.obj = obj
            self.enterSearch = enterSearch
            self.cancelSearch = cancelSearch
            self.searchText = searchText
            
            self.input = Input(enterSearch: enterSearch, cancelSearch: cancelSearch, searchText: searchText)
        }
    }
    
    
    
    private struct TestError: Error { }
    private var lastExpectation: XCTestExpectation?
    private var lastState: SearchResultsViewState? {
        didSet { lastExpectation?.fulfill(); lastExpectation = nil }
    }
    private var bag = DisposeBag()
    
    override func tearDown() {
        lastState = nil
        bag = DisposeBag()
        super.tearDown()
    }
    
    
    
    func testBinders() {
        let viewModel = ViewModel()
        viewModel.input.enterSearch.on(.next(()))
        viewModel.input.cancelSearch.onNext(())
        viewModel.input.searchText.onNext("test")
    }
    
    func testInputs() {
        
        let obj = NSObject()
        
        let enterSearch = Binder<Void>(obj, binding: { (_, _) in
            print("-> enter search")
        })
        let cancelSearch = Binder<Void>(obj, binding: { (_, _) in
            print("-> cancel search")
        })
        let searchText = Binder<String>(obj, binding: { (_, _) in
            print("-> search text")
        })
        
        let input = Input(enterSearch: enterSearch, cancelSearch: cancelSearch, searchText: searchText)
        
        input.enterSearch.on(.next(()))
        input.cancelSearch.onNext(())
        input.searchText.onNext("test")
    }
}
