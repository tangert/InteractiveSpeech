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
    
    @IBOutlet weak var currentLabel: UILabel!
    @IBOutlet weak var currentValue: UILabel!
    
    @IBOutlet weak var highLabel: UILabel!
    @IBOutlet weak var highValue: UILabel!
    
    @IBOutlet weak var audioPlot: EZAudioPlot!
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var microphoneButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var plotTypeSwitch: UISegmentedControl!
    
    static var speechDataDelegate: SpeechDataDelegate?
    static var audioDataDelegate: AudioDataDelegate?
    
    //testing closures vs delegates
    static var gotData: ((_ data: Float) -> ())?

    
    //Speech recognition
    var audioEngine = AVAudioEngine()
    let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))!
    var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    var recognitionTask: SFSpeechRecognitionTask?
    var microphone: EZMicrophone!
    
    var blue = UIColor(red: 73/255, green: 161/255, blue: 213/255, alpha: 1.0)
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Loaded view")
        
        CombinedDataManager.sharedInstance.delegate = self
        AudioDataManager.sharedInstance.instantiate()
        SpeechDataManager.sharedInstance.instantiate()
        CombinedDataManager.sharedInstance.instantiate()
        
        audioPlot.color = blue
        audioPlot.plotType = .buffer
        
        microphone = EZMicrophone.shared()
        microphone?.delegate = self
        
        self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Avenir", size: 20)!]
        microphoneButton.layer.cornerRadius = microphoneButton.layer.frame.width/2
        resetButton.layer.cornerRadius = resetButton.layer.frame.width/2
        
        //delegates
        speechRecognizer.delegate = self
        
        textView.isEditable = false
        textView.isScrollEnabled = true
        
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
            print("\n")
            print("STOP")
            audioEngine.stop()
            recognitionRequest?.endAudio()
            microphone.stopFetchingAudio()
            microphoneButton.setTitle("Start", for: .normal)
            micIsOn = false
        } else {
            print("\n")
            print("START")
            
            AudioDataManager.sharedInstance.clearAllData()
            SpeechDataManager.sharedInstance.clearAllData()
            CombinedDataManager.sharedInstance.clearAllData()
            
            startSpeechRecognition()
            microphone.startFetchingAudio()
            microphoneButton.setTitle("Stop", for: .normal)
            micIsOn = true
        }
    }
  
    @IBAction func resetGraph(_ sender: Any) {
        audioPlot.clear()
        microphoneButton.setTitle("Start", for: .normal)
        microphone.stopFetchingAudio()
        audioEngine.stop()
        recognitionRequest?.endAudio()
        micIsOn = false
        
        AudioDataManager.sharedInstance.clearAllData()
        SpeechDataManager.sharedInstance.clearAllData()
        CombinedDataManager.sharedInstance.clearAllData()
        
        lowValue.text = "0.00"
        currentValue.text = "0.00"
        highValue.text = "0.00"
        textView.text = "" 
    }
    
    @IBAction func changePlotType(_ sender: Any) {
        let selectedSegment = (sender as! UISegmentedControl).selectedSegmentIndex
        switch(selectedSegment){
        case 0:
            audioPlot.plotType = .buffer
            audioPlot.shouldFill = false
            audioPlot.shouldMirror = false
        case 1:
            audioPlot.plotType = .rolling
            audioPlot.shouldFill = true
            audioPlot.shouldMirror = true
        default:
            break
        }
    }
    
    var counter = 0
    func startSpeechRecognition() {
        
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let inputNode = audioEngine.inputNode else {
            fatalError("Audio engine has no input node")
        }
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            
            var isFinal = false
            
            if result != nil {
                self.counter+=1
                isFinal = (result?.isFinal)!
                ViewController.audioDataDelegate?.didReceiveSpeechSet()
                ViewController.speechDataDelegate?.didReceiveSpeechSet(input: (result?.bestTranscription.segments)!)
                print("Count: \(self.counter)")
                
            }
            
            if error != nil || isFinal {  //10
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.microphoneButton.isEnabled = true
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
    }

}


extension ViewController: CombinedDataDelegate {
    func didFormatStrings(input: [NSAttributedString]) {
        
        let fullString = NSMutableAttributedString()
        
        //receive string
        for word in input {
            let space = NSAttributedString(string: " ")
            let wordWithSpace = NSMutableAttributedString()
            
            wordWithSpace.append(word)
            wordWithSpace.append(space)
            
            fullString.append(wordWithSpace)
        }
        
        self.textView.attributedText = fullString
    }
}


extension ViewController: SFSpeechRecognizerDelegate {

    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            microphoneButton.isEnabled = true
        } else {
            microphoneButton.isEnabled = false
        }
    }
}

extension ViewController: EZMicrophoneDelegate {
    
    func microphone(_ microphone: EZMicrophone, hasAudioReceived buffer: UnsafeMutablePointer<UnsafeMutablePointer<Float>?>!, withBufferSize bufferSize: UInt32, withNumberOfChannels numberOfChannels: UInt32) {

        DispatchQueue.main.async(execute: { () -> Void in
            self.audioPlot?.updateBuffer(buffer[0], withBufferSize: bufferSize);
            
            //meanVal is the mean value from the buffer which represents the current decibel
            var meanVal: Float = 0.0
            var one:Float = 1.0
            vDSP_vsq(buffer[0]!, 1, buffer[0]!, 1, vDSP_Length(bufferSize))
            vDSP_meanv(buffer[0]!, 1, &meanVal, vDSP_Length(bufferSize))
            vDSP_vdbcon(&meanVal, 1, &one, &meanVal, 1, 1, 0);
            
            ViewController.audioDataDelegate?.didUpdateDBValues(input: meanVal)
            ViewController.audioDataDelegate?.didUpdateAmplitude(input: meanVal.dB2Amplitude())
            ViewController.gotData?(meanVal)
            
            self.lowValue.text = String(format: "%0.2f", AudioDataManager.sharedInstance.amplitudeValues.min()!)
            self.currentValue.text = String(format: "%0.2f", AudioDataManager.sharedInstance.amplitudeValues.last!)
            self.highValue.text = String(format: "%0.2f", AudioDataManager.sharedInstance.amplitudeValues.max()!)
        });
    }
}
