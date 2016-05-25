/*-
 *
 * Author:
 *    Pal Dorogi "ilap" <pal.dorogi@gmail.com>
 *
 * Copyright (c) 2016 Pal Dorogi
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import XCTest
@testable import BioSwift


class BioSwiftParserTests: XCTestCase {
    let mainBundle = NSBundle.mainBundle()
    let testBundle = NSBundle(forClass: BioSwiftParserTests.self)

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }


    func testParsingCasOffinderOutput() {
        //let filePath = testBundle.resourcePath
        let fileName = testBundle.pathForResource("Resources/ParsersTest/result", ofType: "bwt")

        // FileParserFacade facade = new FileParserFacade();
        let facade = ScoreParseManager()

        do {
            try facade.parseFile(fileName!)
            for result in (facade.parser?.results)! {
                print("ITEM: \(result.guideRNA)")
            }
        } catch let error {
            print ("BIOSWIFT ERROR:: \(error)")
        }


    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}

