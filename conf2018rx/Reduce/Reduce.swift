//
//  Reduce.swift
//  conf2018rx
//
//  Created by Evgeniy Gubin on 14.06.2018.
//  Copyright © 2018 SimbirSoft. All rights reserved.
//

import Foundation
import RxSwift

struct Clock {
    var date: Date
}

private enum ClockEvent {
    case tick
    case syncWithServer
}

private let ticks = Observable<Int>.timer(0, period: 1, scheduler: MainScheduler.asyncInstance)
private let syncClockWithServer = Observable
    .deferred {
        return .just(Date())
    }

private let clockEvents = ticks
    .map { _ in ClockEvent.tick }

let syncClock = clockEvents
    .scan(Clock(date: Date())) { clock, event in
        var copy = clock
        switch event {
        case .tick:
            copy.date = copy.date.addingTimeInterval(1)
        case .syncWithServer:
            break // ???
        }
        return copy
    }

private let clockEvents2 = Observable
    .merge(
        clockEvents,
        Observable
            .just(ClockEvent.syncWithServer)
            .delay(5, scheduler: MainScheduler.asyncInstance)
    )

let asyncClock = clockEvents2
    .scan(Observable.just(Clock(date: Date()))) { (clock, event) in
        switch event {
        case .tick:
            return clock
                .map {
                    var copy = $0
                    copy.date = copy.date.addingTimeInterval(1)
                    return copy
                }
                .share(replay: 1)
        case .syncWithServer:
            return clock
                .flatMap { _ in
                    syncClockWithServer
                        .map { Clock(date: $0) }
                }
                .share(replay: 1)
        }
    }
    .switchLatest()

func clockWithSideEffects() -> Observable<Clock> {
    let state = ReplaySubject<Clock>.create(bufferSize: 1)

    let syncEffect: Observable<ClockEvent> = state
        .observeOn(MainScheduler.asyncInstance)
        .scan(0) { (counter, _)  in
            counter + 1
        }
        .flatMap { counter in
            Observable.from(optional: counter % 10 == 0 ? ClockEvent.syncWithServer : nil)
        }

    let events = Observable
        .merge(
            clockEvents,
            syncEffect
        )

    return events
        .scan(Observable.just(Clock(date: Date()))) { (clock, event) in
            switch event {
            case .tick:
                return clock
                    .map {
                        var copy = $0
                        copy.date = copy.date.addingTimeInterval(1)
                        return copy
                    }
                    .share(replay: 1)
            case .syncWithServer:
                return clock
                    .flatMap { _ in
                        syncClockWithServer
                            .map { Clock(date: $0) }
                    }
                    .share(replay: 1)
            }
        }
        .switchLatest()
        .do(onNext: {
            state.onNext($0)
        }, onSubscribed: {
            
        })
        .subscribeOn(MainScheduler.asyncInstance)
        .observeOn(MainScheduler.asyncInstance)
}
