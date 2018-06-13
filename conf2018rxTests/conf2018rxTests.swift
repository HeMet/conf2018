//
//  conf2018rxTests.swift
//  conf2018rxTests
//
//  Created by Evgeniy Gubin on 11.06.2018.
//  Copyright © 2018 SimbirSoft. All rights reserved.
//

import XCTest
@testable import conf2018rx

class conf2018rxTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testOldMicrosoftConference() {
        let exp = expectation(description: "Famous speech")
        steveBalmer { optSpeech, optError in

            if optSpeech == "Developers! Developers! Developers!" {
                exp.fulfill()
            }
        }

        wait(for: [exp], timeout: 0.5)
    }

    func testRxOldMicrosoftConference() {
        let exp = expectation(description: "Famous speech")
        _ = rxSteveBalmer
            .subscribe(onNext: { speech in
                if speech == "Developers! Developers! Developers!" {
                    exp.fulfill()
                }
            })

        wait(for: [exp], timeout: 0.5)
    }
}
