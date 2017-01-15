//
//  ViewController.swift
//  speech2caps
//
//  Created by Tyler Angert on 1/10/17.
//  Copyright © 2017 Tyler Angert. All rights reserved.
//

import UIKit
import Speech
import AudioKit

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
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    
    static var speechDataDelegate: SpeechDataDelegate?
    static var audioDataDelegate: AudioDataDelegate?
    
    //Speech recognition
    let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))!
    var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    var recognitionTask: SFSpeechRecognitionTask?
    let audioEngine = AVAudioEngine()
    
    var mic: AKMicrophone!
    var tracker: AKFrequencyTracker!
    var silence: AKBooster!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        AKSettings.audioInputEnabled = true
        mic = AKMicrophone()
        tracker = AKFrequencyTracker.init(mic)
        silence = AKBooster(tracker, gain: 0)
        
        //some initial visual stuff
        self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Avenir", size: 20)!]
        startButton.layer.cornerRadius = startButton.layer.frame.width/2
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
                self.startButton.isEnabled = isButtonEnabled
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        AudioKit.output = silence
        AudioKit.start()
        setupPlot()
        
    }
    
    @IBAction func startRecording(_ sender: UIButton) {
        if mic.isStarted {
            mic.stop()
            recognitionRequest?.endAudio()
            startButton.setTitle("Start", for: .normal)
        } else {
            record()
            startButton.setTitle("Stop", for: .normal)
        }
    }
    
    @IBAction func resetButton(_ sender: UIButton) {
    }
    
    func record() {
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
    
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let inputNode = audioEngine.inputNode else {
            fatalError("Audio engine has no input node")
        }
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        
        recognitionRequest.shouldReportPartialResults = true
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in  //7
            
        var isFinal = false
            
        if result != nil {
        // THIS IS WHERE THE CONVERSION HAPPENS.
                
            for word in (result?.bestTranscription.segments)! {
                ViewController.speechDataDelegate?.didReceiveWord(input: word.substring)
            }
        }
            
        isFinal = (result?.isFinal)!
            
        if error != nil || isFinal {
            self.audioEngine.stop()
            inputNode.removeTap(onBus: 0)
                
            self.recognitionRequest = nil
            self.recognitionTask = nil
            self.startButton.isEnabled = true
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)  //11
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
        
        textView.text = "Say something, I'm listening!"
    }
    
    func setupPlot() {
        let plot = AKNodeOutputPlot(mic, frame: audioPlot.bounds)
        plot.plotType = .rolling
        plot.shouldFill = true
        plot.shouldMirror = true
        plot.color = UIColor.blue
        audioPlot.addSubview(plot)
    }
    
    enum audioLevel {
        case low
        case avg
        case high
    }

    func updateUI() {
        
        guard tracker.amplitude > 0.1 else {
            print("We can't hear you!")
            return
        }
        
        var frequency = Float(tracker.frequency)
        var amplitude = Float(tracker.amplitude)
        
    }

}

extension ViewController: SFSpeechRecognizerDelegate {
    
}

extension ViewController: EZMicrophoneDelegate, EZOutputDataSource {
    
    func microphone(_ microphone: EZMicrophone!, hasAudioReceived buffer: UnsafeMutablePointer<UnsafeMutablePointer<Float>?>!, withBufferSize bufferSize: UInt32, withNumberOfChannels numberOfChannels: UInt32) {
        
        let value = buffer[0]
        ViewController.audioDataDelegate?.didUpdateData(data: value!)
    }
    
    func output(_ output: EZOutput!, shouldFill audioBufferList: UnsafeMutablePointer<AudioBufferList>!, withNumberOfFrames frames: UInt32, timestamp: UnsafePointer<AudioTimeStamp>!) -> OSStatus {
        
        return 0
    }
}
