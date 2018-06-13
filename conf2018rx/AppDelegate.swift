//
//  AppDelegate.swift
//  conf2018rx
//
//  Created by Evgeniy Gubin on 11.06.2018.
//  Copyright © 2018 SimbirSoft. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxFeedback

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let disposeBag = DisposeBag()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        let win = UIWindow()

        window = win

        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "\(FifteenViewController.self)") as! FifteenViewController


        Driver<Any>
            .system(
                initialState: FifteenPuzzle(),
                reduce: FifteenPuzzle.reduce(_:event:),
                feedback: [
                    bind { state in
                        Bindings(subscriptions: [
                            state
                                .map { $0.viewModel }
                                .distinctUntilChanged {
                                    $0.timestamp == $1.timestamp
                                }
                                .drive(vc._viewModel)
                            ],
                                 events: [vc.events()])
                    },
                    updateViewModel
                ]
            )
            .drive()
            .disposed(by: disposeBag)

        win.rootViewController = vc

        win.makeKeyAndVisible()

        return true
    }
}
