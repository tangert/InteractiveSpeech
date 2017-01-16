//
//  ViewController.swift
//  speech2caps
//
//  Created by Tyler Angert on 1/10/17.
//  Copyright © 2017 Tyler Angert. All rights reserved.
//

import UIKit
import Speech
import EZAudio

class ViewController: UIViewController {
    
    //IBOutlets
    @IBOutlet weak var lowLabel: UILabel!
    @IBOutlet weak var lowValue: UILabel!
    
    @IBOutlet weak var avgLabel: UILabel!
    @IBOutlet weak var avgValue: UILabel!
    
    @IBOutlet weak var highLabel: UILabel!
    @IBOutlet weak var highValue: UILabel!
    
    @IBOutlet weak var audioPlot: EZAudioPlot!
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var microphoneButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var plotTypeSwitch: UISegmentedControl!
    
    static var speechDataDelegate: SpeechDataDelegate?
    static var audioDataDelegate: AudioDataDelegate?
    
    //Speech recognition
    let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))!
    var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    var recognitionTask: SFSpeechRecognitionTask?
    
    var microphone: EZMicrophone!
    var fft: EZAudioFFT?
    
    var blue = UIColor(red: 73/255, green: 161/255, blue: 213/255, alpha: 1.0)
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Loaded view")
        
        AudioDataManager.sharedInstance.instantiate()
        SpeechDataManager.sharedInstance.instantiate()
        
        audioPlot.color = blue
        audioPlot.plotType = .rolling
        audioPlot.shouldFill = true
        audioPlot.shouldMirror = true
        
        microphone = EZMicrophone.shared()
        microphone?.delegate = self
        
        fft = EZAudioFFTRolling.fft(withWindowSize: 4096, sampleRate: Float(self.microphone.audioStreamBasicDescription().mSampleRate), delegate: self)
        
        self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Avenir", size: 20)!]
        microphoneButton.layer.cornerRadius = microphoneButton.layer.frame.width/2
        resetButton.layer.cornerRadius = resetButton.layer.frame.width/2
        
        //delegates
        speechRecognizer.delegate = self
        
        textView.isEditable = false
        textView.isSelectable = false
        
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            var isButtonEnabled = false
            
            switch authStatus {
            case .authorized:
                isButtonEnabled = true
                
            case .denied:
                isButtonEnabled = false
                print("User denied access to speech recognition")
                
            case .restricted:
                isButtonEnabled = false
                print("Speech recognition restricted on this device")
                
            case .notDetermined:
                isButtonEnabled = false
                print("Speech recognition not yet authorized")
            }
            
            OperationQueue.main.addOperation() {
                self.microphoneButton.isEnabled = isButtonEnabled
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    var micIsOn = false
    @IBAction func toggleMicrophone(_ sender: Any) {
        if micIsOn {
            print("stopped recording!")
            microphone.stopFetchingAudio()
            recognitionRequest?.endAudio()
            microphoneButton.setTitle("Start", for: .normal)
            micIsOn = false
        } else {
            print("started recording!")
            microphone.startFetchingAudio()
            microphoneButton.setTitle("Stop", for: .normal)
            micIsOn = true
        }
    }
  
    @IBAction func resetGraph(_ sender: Any) {
        self.audioPlot.clear()
        microphoneButton.setTitle("Start", for: .normal)
        microphone.stopFetchingAudio()
        micIsOn = false
    }
    
    @IBAction func changePlotType(_ sender: Any) {
        let selectedSegment = (sender as! UISegmentedControl).selectedSegmentIndex
        switch(selectedSegment){
        case 0:
            audioPlot.plotType = .rolling
            audioPlot.shouldFill = true
            audioPlot.shouldMirror = true
        case 1:
            audioPlot.plotType = .buffer
            audioPlot.shouldFill = false
            audioPlot.shouldMirror = false
        default:
            break
        }
    }
    
    enum audioLevel {
        case low
        case avg
        case high
    }

}

extension ViewController: SFSpeechRecognizerDelegate {
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        print("speech recognizer delegate called")
    }
}

extension ViewController: EZMicrophoneDelegate {
    
    func microphone(_ microphone: EZMicrophone, hasAudioReceived buffer: UnsafeMutablePointer<UnsafeMutablePointer<Float>?>!, withBufferSize bufferSize: UInt32, withNumberOfChannels numberOfChannels: UInt32) {

        DispatchQueue.main.async(execute: { () -> Void in
            print("New data!")
            self.audioPlot?.updateBuffer(buffer[0], withBufferSize: bufferSize);
            ViewController.audioDataDelegate?.didUpdateData()
            
            var meanVal: Float = 0.0
            var one:Float = 1.0
            vDSP_vsq(buffer[0]!, 1, buffer[0]!, 1, vDSP_Length(bufferSize))
            vDSP_meanv(buffer[0]!, 1, &meanVal, vDSP_Length(bufferSize))
            vDSP_vdbcon(&meanVal, 1, &one, &meanVal, 1, 1, 0);
            print("Decibel value: \(meanVal)")
            print("Amplitude: \(meanVal.dB2Amplitude())")
            
        });
    }
}

extension ViewController: EZAudioFFTDelegate {
    func fft(_ fft: EZAudioFFT!, updatedWithFFTData fftData: UnsafeMutablePointer<Float>!, bufferSize: vDSP_Length) {
        
    }
}
