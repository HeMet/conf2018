//
//  Callbacks.swift
//  conf2018rx
//
//  Created by Evgeniy Gubin on 11.06.2018.
//  Copyright © 2018 SimbirSoft. All rights reserved.
//

import Foundation

let queue = DispatchQueue(label: "conf2018rx.serial.asyncComputation")

typealias CompletionHandler<T> = (T?, Error?) -> Void

func computeString(_ completionHandler: @escaping CompletionHandler<String>) {
    queue.asyncAfter(wallDeadline: .now() + .milliseconds(50)) {
        completionHandler("Developers!", nil)
    }
}

func computeInteger(_ completionHandler: @escaping CompletionHandler<Int>) {
    queue.asyncAfter(wallDeadline: .now() + .milliseconds(50)) {
        completionHandler(3, nil)
    }
}

func steveBalmer(completionHandler: @escaping CompletionHandler<String>) {
    computeString { optString, optError in
        if let error = optError {
            completionHandler(nil, error)
            return
        }

        guard let string = optString else {
            fatalError("undefined behavior")
        }

        computeInteger { optInteger, optError in
            if let error = optError {
                completionHandler(nil, error)
                return
            }

            guard let integer = optInteger else {
                fatalError("undefined behavior")
            }

            completionHandler(
                [String](repeating: string, count: integer).joined(separator: " "),
                nil
            )
        }
    }
}
