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
    
    static var sharedInstance = AudioDataManager()
    var dBValues = [Float]()
    var amplitudeValues = [Float]()
    
    var inputSensitivedBValues = [Float]()
    var inputSensitiveAmplitudeValues = [Float]()
    
    func instantiate() { print("Instantiated") }
    
    init() {
        ViewController.audioDataDelegate = self
    }
}

extension AudioDataManager: AudioDataDelegate {
    func didUpdateDBValues(input: Float) {
        self.dBValues.append(input)
    }
    
    func didUpdateAmplitude(input: Float) {
        self.amplitudeValues.append(input)
    }
}
