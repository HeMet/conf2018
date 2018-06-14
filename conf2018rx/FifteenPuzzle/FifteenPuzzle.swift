//
//  FifteenGame.swift
//  conf2018rx
//
//  Created by Evgeniy Gubin on 11.06.2018.
//  Copyright © 2018 SimbirSoft. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources
import RxFeedback

enum Event {
    case tappedAt(IndexPath)
    case viewModelInvalidated
}

struct FifteenPuzzle {
    // model
    var items: [[Int]] = [
        [15, 14, 13, 12],
        [11, 10,  9,  8],
        [7,   6,  5,  4],
        [3,   2,  1,  16],
    ]

    var from: IndexPath?

    var turnCounter = 0

    // view model
    var viewModel: FifteenViewController.ViewModel!

    init() {
        viewModel = makeViewModel()
    }

    static func reduce(_ state: FifteenPuzzle, event: Event) -> FifteenPuzzle {
        var new = state
        switch event {
        case .tappedAt(let indexPath):
            new.onTapped(at: indexPath)
        case .viewModelInvalidated:
            new.updateViewModel()
        }
        return new
    }

    mutating func onTapped(at: IndexPath) {
        switch(from, self[at]) {
        case (nil, let value) where value != 16:
            from = at
        case (let value?, _):
            move(from: value, to: at)
            from = nil
        default:
            break
        }
     }

    mutating func move(from: IndexPath, to: IndexPath) {
        guard
            self[to] == 16,
            to.distance(from: from) == 1
        else {
            return
        }

        self[to] = self[from]
        self[from] = 16

        turnCounter += 1
    }

    mutating func updateViewModel() {
        viewModel = makeViewModel()
    }

    typealias VM = FifteenViewController.ViewModel

    func makeViewModel() -> VM {
        let viewItems = zip(items, 0...).map { row, idx in
            AnimatableSectionModel<String, VM.Item>(
                model: "row \(idx)",
                items: zip(row, 0...).map {
                    VM.Item(
                        value: $0,
                        text: $0 == 16 ? "" : "\($0)",
                        selected: from == IndexPath(item: $1, section: idx)
                    )
                }
            )
        }
        let cheer = cheers[(turnCounter / 3) % cheers.count]

        return VM(
            rows: viewItems,
            cheer: cheer,
            turns: "Число ходов: \(turnCounter)",
            timestamp: Date()
        )
    }

    subscript(_ indexPath: IndexPath) -> Int {
        get {
            return items[indexPath.section][indexPath.row]
        }
        set {
            items[indexPath.section][indexPath.row] = newValue
        }
    }
}

private let cheers = [
    "Давай!",
    "У тебя все получится!",
    "Powered by RxFeedback"
]

extension IndexPath {
    func distance(from: IndexPath) -> Int {
        return abs(section - from.section) + abs(row - from.row)
    }
}

let updateViewModel: Driver<Any>.Feedback<FifteenPuzzle, Event> = react(
    query: { $0 },
    areEqual: { (lhs: FifteenPuzzle, rhs: FifteenPuzzle) -> Bool in
        lhs.from == rhs.from && lhs.items == rhs.items
    },
    effects: { state in
        return .just(Event.viewModelInvalidated)
    }
)

func ==(lhs: [[Int]], rhs: [[Int]]) -> Bool {
    guard lhs.count == rhs.count else {
        return false
    }

    return zip(lhs, rhs).map { $0 == $1 }.reduce(true, { $0 && $1 })
}
