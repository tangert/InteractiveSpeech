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
    //Maps each word to a range of amplitude values associated with it's duration
    var word2AmplitudesDictionary = [String: [Float]]()
    
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
        
        //Taking the average and max values of the last 50 values since a word has ended.
        //Ideally find the distance via timer to find which audio values are specifically associated with a word. 
        //Create a dictionary mapping each word to an array of amplitude values.
        
        let avgDB = dBValues.last(count: 50).average()
        let avgAmp = amplitudeValues.last(count: 50).average()
        
        let maxDB = dBValues.last(count: 50).max()
        let maxAmp = amplitudeValues.last(count: 50).max()
        
//        //Average
//        self.inputSensitivedBValues.append(avgDB)
//        self.inputSensitiveAmplitudeValues.append(avgAmp)
//
        //Max
        self.inputSensitivedBValues.append(maxDB!)
        self.inputSensitiveAmplitudeValues.append(maxAmp!)
        

        CombinedDataManager.sharedInstance.amplitudes = inputSensitiveAmplitudeValues
        print("Input sensitive Amplitude values: \(inputSensitiveAmplitudeValues)")
//        print("All amp vals: \(amplitudeValues)")
    }
}
