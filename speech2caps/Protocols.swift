//
//  Protocols.swift
//  speech2caps
//
//  Created by Tyler Angert on 1/14/17.
//  Copyright © 2017 Tyler Angert. All rights reserved.
//

import Foundation

protocol SpeechDataDelegate {
    func didReceiveWord(input: String)
    func didReceiveSpeechSet(input: [String])
}

protocol AudioDataDelegate {
    func didUpdateData(data: Any)
}

protocol AttributeStringDelegate {
    func didReceiveString(string: String)
}
