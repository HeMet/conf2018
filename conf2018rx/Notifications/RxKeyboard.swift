//
//  RxKeyboard.swift
//  conf2018rx
//
//  Created by Evgeniy Gubin on 11.06.2018.
//  Copyright © 2018 SimbirSoft. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

let kbWillShowRect = NotificationCenter.default.rx
    .notification(Notification.Name.UIKeyboardWillShow, object: nil)
    .map { notification in
        return notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! CGRect
    }

let kbWillHideRect = NotificationCenter.default.rx
    .notification(Notification.Name.UIKeyboardWillHide, object: nil)
    .map { notification -> CGRect in
        return .zero
    }

let kbHeight = Observable
    .merge(kbWillShowRect, kbWillHideRect)
    .map { $0.height }
