//
//  ViewController.swift
//  FunWithRxSwift
//
//  Created by Joachim Kret on 19/07/2019.
//  Copyright © 2019 Joachim Kret. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {
    
    private let vm = ViewModel()
    private let button = UIButton(type: .custom)
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareView()
        bindViewModel()
    }

    private func prepareView() {
        button.frame = .init(x: 50, y: 100, width: 100, height: 44)
        button.backgroundColor = .red
        view.addSubview(button)
    }
    
    lazy var cell = Cell(button: self.button)
    lazy var updater: (ButtonViewData) -> () = updateButton(self.button)
    
    lazy var binder = prepareButtonBinding(self.button)
    
    private func bindViewModel() {
        
        let output = vm.prepare()
        output.button.debug("button").drive(onNext: binder).disposed(by: disposeBag)
    }
    
    private func updateButton(_ button: UIButton) -> (ButtonViewData) -> () {
        var bag = DisposeBag()
        return { viewData in
            bag = DisposeBag()
            button.setTitle(viewData.title, for: .normal)
            button.rx.tap.debug("tap").subscribe(onNext: viewData.handler).disposed(by: bag)
        }
    }
    
    private func prepareButtonBinding(_ button: UIButton) -> (ButtonViewData) -> () {
        return Binder().bind { (viewData, bag) in
            button.setTitle(viewData.title, for: .normal)
            button.rx.tap.debug("tap").subscribe(onNext: viewData.handler).disposed(by: bag)
        }
    }
}

class Binder {
    private var disposeBag = DisposeBag()
    
    func bind<T>(_ action: @escaping (T, DisposeBag) -> ()) -> (T) -> () {
        let disposeBag = DisposeBag()
        self.disposeBag = disposeBag
        return { obj in
            action(obj, disposeBag)
        }
    }
}

class Cell {
    
    private let button: UIButton
    private var disposeBag = DisposeBag()
    
    init(button: UIButton) {
        self.button = button
    }
    
    func configure(with viewData: ButtonViewData) {
        disposeBag = DisposeBag()
        button.setTitle(viewData.title, for: .normal)
        button.rx.tap.debug("tap").subscribe(onNext: viewData.handler).disposed(by: disposeBag)
    }
}

struct ViewModel {
    
    struct Output {
        let button: Driver<ButtonViewData>
    }
    
    func prepare() -> Output {
       
        let viewData = ButtonViewData(title: "test", handler: { print("tap!") })
//        let button = makeDriver(.just(viewData))
        
        return Output(button: .just(viewData))
    }
    
    private func makeDriver<T>(_ source: Observable<T>) -> Driver<T> {
        return source.concat(Observable.never()).asDriver(onErrorDriveWith: .empty())
    }
}

struct ButtonViewModel {
     
    struct Input {
        var tap: Signal<Void> = .empty()
    }
    
    struct Output {
        var title: Driver<String> = .empty()
    }
    
    func transform(_ input: Input) -> (DisposeBag) -> Output {
        var output = Output()
        output.title = .just("test")
        return { bag in
            input.tap.emit(onNext: { print("-> tap!") }).disposed(by: bag)
            return output
        }
    }
    
}

struct ButtonViewData {
    let title: String
    let handler: () -> ()
}
