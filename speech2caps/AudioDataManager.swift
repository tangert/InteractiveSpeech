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
    
    func clearAllData() {
        dBValues.removeAll()
        amplitudeValues.removeAll()
        inputSensitiveAmplitudeValues.removeAll()
        inputSensitivedBValues.removeAll()
    }
    
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
        //inputSensitiveAmplitudeValues.removeAll()
        //inputSensitivedBValues.removeAll()
        
        let avgDB = dBValues.last(count: 20).average()
        let avgAmp = amplitudeValues.last(count: 20).average()
        
        let maxDB = dBValues.last(count: 20).max()
        let maxAmp = amplitudeValues.last(count: 20).max()
        
//        //Average
//        self.inputSensitivedBValues.append(avgDB)
//        self.inputSensitiveAmplitudeValues.append(avgAmp)
        
        //Max
        self.inputSensitivedBValues.append(maxDB!)
        self.inputSensitiveAmplitudeValues.append(maxAmp!)
        

        CombinedDataManager.sharedInstance.amplitudes = inputSensitiveAmplitudeValues
        print("Input sensitive Amplitude values: \(inputSensitiveAmplitudeValues)")
//        print("All amp vals: \(amplitudeValues)")
    }
}
