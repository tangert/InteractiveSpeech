//
//  SpeechDataManager.swift
//  speech2caps
//
//  Created by Tyler Angert on 1/14/17.
//  Copyright © 2017 Tyler Angert. All rights reserved.
//

import Foundation
import UIKit

class SpeechDataManager {
    
    static var sharedInstance = SpeechDataManager()
    
    var originalTextArray: [String?]?
    var fontSizes: [Int]?
    var attributedText: NSMutableAttributedString?
    
    func instantiate() { print("Instantiated") }
    
    init() {
        ViewController.speechDataDelegate = self
    }
}

extension SpeechDataManager: SpeechDataDelegate {
    
    func didReceiveWord(input: String) {
        print("Got the shit!")
        originalTextArray?.append(input)
        print(originalTextArray!)
    }
    
    func didReceiveSpeechSet(input: [String]) {
        
    }

}
