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
    var attributedText: NSMutableAttributedString?
    var textFormatDelegate: TextFormatterDelegate?
    
    func instantiate() { print("Instantiated") }
    
    func clearAllData() {
        originalTextArray.removeAll()
    }
    
    init() {
        ViewController.speechDataDelegate = self
    }
}

extension SpeechDataManager: SpeechDataDelegate {

    func didReceiveSpeechSet(input: [SFTranscriptionSegment]) {
        originalTextArray.removeAll()
        for word in input {
            originalTextArray.append(word.substring)
            print("\(word.substring) timestamp: \(word.timestamp)\n")
        }
        
        //Everytime speech in inputted, calculate the duration of time it took since the last word.
        //Keep a counter variable for the audio data to match up each.
        for i in 1..<input.count {
            print("Duration of \(input[i].substring): \(input[i].timestamp - input[i-1].timestamp)")
        }
        
        CombinedDataManager.sharedInstance.words = originalTextArray
        SpeechDataManager.sharedInstance.textFormatDelegate?.willFormatText()
    }

}
