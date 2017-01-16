//
//  CombinedDataManager.swift
//  speech2caps
//
//  Created by Tyler Angert on 1/16/17.
//  Copyright © 2017 Tyler Angert. All rights reserved.
//

import Foundation
import UIKit
import Speech

class CombinedDataManager {
    
    static var sharedInstance = CombinedDataManager()
    var delegate: CombinedDataDelegate?
    
    var words = [String]()
    var amplitudes = [Float]()
    
    
    var convertedFontSizes = [Float]()
    var attributedWords = [NSAttributedString]()
    
    func instantiate() { print("Instantiated") }
    init() {
       SpeechDataManager.sharedInstance.textFormatDelegate = self
    }
    
}

extension CombinedDataManager: TextFormatterDelegate {
    
    func willFormatText() {
//0: Clear all relevant values before starting
        convertedFontSizes.removeAll()
        attributedWords.removeAll()
        
        
        //1: Map audio values to font size
        for value in amplitudes {
            let size = mapAudioValueToFontSize(audioValue: value, amplitudeRange: (0, 0.1), fontRange: (12, 45))
            convertedFontSizes.append(size)
        }
        
        print("Amplitudes: \(amplitudes)")
        print("Words: \(words)")
        print("Converted sizes: \(convertedFontSizes)")
        print("\n")
        
        //2a: Format each string in words with respective font sizes
        //2b: Append each word to array
        for i in 0..<words.count {
            let formmatedString = formatStringWithFontSize(string: words[i], size: convertedFontSizes[i])
            attributedWords.append(formmatedString)
        }
        
        //3: send attributed words to the main vc!
        self.delegate?.didFormatStrings(input: attributedWords)
    }
    
    
    func formatStringWithFontSize(string: String, size: Float) -> NSAttributedString {
        let formattedSize = [NSFontAttributeName: UIFont.systemFont(ofSize: CGFloat(size))]
        let formattedString = NSMutableAttributedString(string: string, attributes: formattedSize)
        return formattedString
    }
    
    func mapAudioValueToFontSize(audioValue: Float, amplitudeRange: (amp1: Float, amp2: Float), fontRange: (size1: Float, size2: Float)) -> Float {
        //User linear interpolation to map [0,1] (amplitudes) to a given font range [size1, size2]
        //General form: [a,b] - > [c,d] : f(x) = ((d-c)/(b-a))*(x-a)+c
        
        let size = (fontRange.size2 - fontRange.size1)/(amplitudeRange.amp2 - amplitudeRange.amp1)*(audioValue-amplitudeRange.amp1) + fontRange.size1
        
        return size
    }
}
