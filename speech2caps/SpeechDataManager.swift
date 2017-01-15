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
    
    let sharedInstance = SpeechDataManager()
    
    var originalTextArray: [String?]?
    var attributedText: NSMutableAttributedString?
    
    init() {
        ViewController.speechDataDelegate = self
    }
}

extension SpeechDataManager: SpeechDataDelegate {
    
    func didReceiveWord(input: String) {
        print("Got the shit!")
        originalTextArray?.append(input)
        print(originalTextArray)
    }
    
    func didReceiveSpeechSet(input: [String]) {
        
    }

}
