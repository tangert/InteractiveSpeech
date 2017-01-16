//
//  SpeechDataManager.swift
//  speech2caps
//
//  Created by Tyler Angert on 1/14/17.
//  Copyright © 2017 Tyler Angert. All rights reserved.
//

import Foundation
import UIKit
import Speech

class SpeechDataManager {
        
    static var sharedInstance = SpeechDataManager()
    var originalTextArray = [String]()
    var fontSizes = [Int]()
    var attributedText: NSMutableAttributedString?
    var textFormatDelegate: TextFormatterDelegate?
    
    func instantiate() { print("Instantiated") }
    
    init() {
        ViewController.speechDataDelegate = self
    }
}

extension SpeechDataManager: SpeechDataDelegate {
    
    func didReceiveWord(input: String) {
    }
    
    func didReceiveSpeechSet(input: [SFTranscriptionSegment]) {
        originalTextArray.removeAll()
        for word in input {
            originalTextArray.append(word.substring)
        }
        
        CombinedDataManager.sharedInstance.words = originalTextArray
        SpeechDataManager.sharedInstance.textFormatDelegate?.willFormatText()
    }

}
