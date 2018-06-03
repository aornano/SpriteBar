//
//  SpriteBar.swift
//  SpriteBar
//
//  Created by Alessandro Ornano on 03/06/2018.
//  Copyright © 2018 Alessandro Ornano. All rights reserved.
//

import Foundation
import SpriteKit

class SpriteBar: SKSpriteNode {
    var textureReference = ""
    var atlas: SKTextureAtlas!
    var availableTextureAddresses = Array<Int>()
    var timer = Timer()
    var timerInterval = TimeInterval()
    var currentTime = TimeInterval()
    var timerTarget: AnyObject!
    var timerSelector: Selector!
    
    init() {
        let defaultAtlas = SKTextureAtlas(named: "sb_default")
        let firstTxt = defaultAtlas.textureNames[0].replacingOccurrences(of: "@2x", with: "")
        let texture = defaultAtlas.textureNamed(firstTxt)
        super.init(texture: texture, color: .clear, size: texture.size())
        self.atlas = defaultAtlas
        commonInit()
    }
    convenience init(textureAtlas: SKTextureAtlas?) {
        self.init()
        self.atlas = textureAtlas
        commonInit()
    }
    func commonInit() {
        self.textureReference = "progress"
        resetProgress()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func closestAvailableToPercent(_ percent:Int)->Int {
        var closest = 0
        for thisPerc in self.availableTextureAddresses {
            if labs(Int(thisPerc) - percent) < labs(closest - percent) {
                closest = Int(thisPerc)
            }
        }
        return closest
    }
    func percentFromTextureName(_ string:String) -> Int? {
        let clippedString = string.replacingOccurrences(of: "@2x", with: "")
        let pattern = "(?<=\(textureReference)_)([0-9]+)(?=.png)"
        let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        let matches = regex?.matches(in: clippedString, options: [], range: NSRange(location: 0, length: clippedString.count))
        // If the matches don't equal 1, you have done something wrong.
        if matches?.count != 1 {
            NSException(name: NSExceptionName(rawValue: String("SpriteBar: Incorrect texture naming.")), reason: "Textures should follow naming convention: \(textureReference)_#.png. Failed texture name: \(string)", userInfo: nil).raise()
        }
        for match: NSTextCheckingResult? in matches ?? [NSTextCheckingResult?]() {
            let matchRange = match?.range(at: 1)
            let range = Range(matchRange!, in: clippedString)!
            return Int(clippedString[range.lowerBound..<range.upperBound])
        }
        return nil
    }
    
    func resetProgress() {
        self.texture = self.atlas.textureNamed("\(self.textureReference)_\(closestAvailableToPercent(0)).png")
        self.availableTextureAddresses = []
        for name in self.atlas.textureNames {
            self.availableTextureAddresses.append(self.percentFromTextureName(name)!)
        }
        self.invalidateTimer()
        self.currentTime = 0
    }
    func setProgress(_ progress:CGFloat) {
        // Set texure
        let percent: CGFloat = CGFloat(lrint(Double(progress * 100)))
        let name = "\(textureReference)_\(self.closestAvailableToPercent(Int(percent))).png"
        self.texture = self.atlas.textureNamed(name)
        // If we have reached 100%, invalidate the timer and perform selector on passed in object.
        if fabsf(Float(progress)) >= fabsf(1.0) {
            if timerTarget != nil && timerTarget.responds(to: timerSelector) {
                typealias MyTimerFunc = @convention(c) (AnyObject, Selector) -> Void
                let imp: IMP = timerTarget.method(for: timerSelector)
                let newImplementation = unsafeBitCast(imp, to: MyTimerFunc.self)
                newImplementation(self.timerTarget, self.timerSelector)
            }
            timer.invalidate()
        }
    }
    func setProgressWithValue(_ progress:CGFloat, ofTotal maxValue:CGFloat) {
        self.setProgress(progress/maxValue)
    }
    
    func numberOfFrames(inAnimation animationName: String) -> Int {
        // Get the number of frames in the animation.
        let allAnimationNames = atlas.textureNames
        let nameFilter = NSPredicate(format: "SELF CONTAINS[cd] %@", animationName)
        return ((allAnimationNames as NSArray).filtered(using: nameFilter)).count
    }
    func startBarProgress(withTimer seconds: TimeInterval, target: Any?, selector: Selector) {
        resetProgress()
        timerTarget = target as AnyObject
        timerSelector = selector
        // Split the progress time between animation frames
        timerInterval = seconds / TimeInterval((numberOfFrames(inAnimation: textureReference) - 1))
        timer = Timer.scheduledTimer(timeInterval: timerInterval, target: self, selector: #selector(self.timerTick(_:)), userInfo: seconds, repeats: true)
    }
    @objc func timerTick(_ timer: Timer) {
        // Increment timer interval counter
        currentTime += timerInterval
        // Make sure we don't exceed the total time
        if currentTime <= timer.userInfo as! Double {
            setProgressWithValue(CGFloat(currentTime), ofTotal: timer.userInfo as! CGFloat)
        }
    }
    func invalidateTimer() {
        timer.invalidate()
    }
}
