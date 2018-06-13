//
//  ViewController.swift
//  conf2018rx
//
//  Created by Evgeniy Gubin on 11.06.2018.
//  Copyright © 2018 SimbirSoft. All rights reserved.
//

import UIKit
import RxSwift

class ViewController: UIViewController {

    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var buttonBottomPadding: NSLayoutConstraint!

    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        kbHeight
            .map { $0 + 20 }
            .bind(to: buttonBottomPadding.rx.constant)
            .disposed(by: disposeBag)

        button.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.textField.resignFirstResponder()
            })
            .disposed(by: disposeBag)

        textField.rx.text
            .asObservable()
            .throttle(1, scheduler: MainScheduler.asyncInstance)
            .bind(to: button.rx.title(for: .normal))
            .disposed(by: disposeBag)
    }
}

