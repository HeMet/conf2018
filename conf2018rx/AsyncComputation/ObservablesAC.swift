//
//  ObservablesAC.swift
//  conf2018rx
//
//  Created by Evgeniy Gubin on 11.06.2018.
//  Copyright © 2018 SimbirSoft. All rights reserved.
//

import Foundation
import RxSwift

let rxComputeString = Observable<String>.create { observer in
    queue.asyncAfter(wallDeadline: .now() + .milliseconds(50)) {
        observer.onNext("Developers!")
        observer.onCompleted()
    }

    return Disposables.create()
}

let rxComputeInteger = Observable<Int>.create { observer in
    queue.asyncAfter(wallDeadline: .now() + .milliseconds(50)) {
        observer.onNext(3)
        observer.onCompleted()
    }

    return Disposables.create()
}

let rxSteveBalmer = Observable
    .zip(rxComputeString, rxComputeInteger)
    .map { string, integer in
        [String](repeating: string, count: integer).joined(separator: " ")
    }
