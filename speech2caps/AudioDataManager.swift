//
//  AudioDataManager.swift
//  speech2caps
//
//  Created by Tyler Angert on 1/14/17.
//  Copyright © 2017 Tyler Angert. All rights reserved.
//

import Foundation
import UIKit
import Speech

class AudioDataManager {
    
    static var sharedInstance = AudioDataManager()
    var dBValues = [Float]()
    var amplitudeValues = [Float]()
    
    var inputSensitivedBValues = [Float]()
    var inputSensitiveAmplitudeValues = [Float]()
    
    func instantiate() { print("Instantiated") }
    
    init() {
        ViewController.audioDataDelegate = self
        ViewController.gotData = { data in
//            print("I got the data!")
        }
    }
}

extension AudioDataManager: AudioDataDelegate {
    func didUpdateDBValues(input: Float) {
        self.dBValues.append(input)
    }
    
    func didUpdateAmplitude(input: Float) {
        self.amplitudeValues.append(input)
    }
    
    func didReceiveSpeechSet() {
        //this updates two arrays that contain the dB and ampliutude values that correspond to each time a word is uttered.
        self.inputSensitivedBValues.append(dBValues.last!)
        self.inputSensitiveAmplitudeValues.append(amplitudeValues.last!)
        

        CombinedDataManager.sharedInstance.amplitudes = inputSensitiveAmplitudeValues
        print("Input sensitive Amplitude values: \(inputSensitiveAmplitudeValues)")
        print("All amp vals: \(amplitudeValues)")
    }
}
