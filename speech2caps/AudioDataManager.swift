//
//  AudioDataManager.swift
//  speech2caps
//
//  Created by Tyler Angert on 1/14/17.
//  Copyright © 2017 Tyler Angert. All rights reserved.
//

import Foundation
import UIKit

class AudioDataManager {
    
    let sharedInstance = AudioDataManager()
    var allAudioData: [Float]?
    var lowFreq: Float?
    var lowAmp: Float?
    var avgFreq: Float?
    var avgAmp: Float?
    var highFreq: Float?
    var highAmp: Float?
    
    init() {
        ViewController.audioDataDelegate = self
    }
}

extension AudioDataManager: AudioDataDelegate {
    func didUpdateData(data: Any) {
        print("I'm receiving audio data! I'm the delegate!")
        print(data)
    }
}
