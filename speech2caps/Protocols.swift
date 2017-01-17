//
//  Protocols.swift
//  speech2caps
//
//  Created by Tyler Angert on 1/14/17.
//  Copyright © 2017 Tyler Angert. All rights reserved.
//

import Foundation
import UIKit
import Speech

protocol SpeechDataDelegate: class {
    func didReceiveSpeechSet(input: [SFTranscriptionSegment])
}

//optional function!
extension SpeechDataDelegate {
    func didReceiveWord(input: String) {}
}

protocol AudioDataDelegate {
    func didUpdateDBValues(input: Float)
    func didUpdateAmplitude(input: Float)
    func didReceiveSpeechSet()
}

protocol CombinedDataDelegate {
    func didFormatStrings(input: [NSAttributedString])
}

protocol TextFormatterDelegate {
    func willFormatText()
}
