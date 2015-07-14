//
//  RAAudioEngine.swift
//  Doodler
//
//  Created by Ryan Ackermann on 2/20/15.
//  Copyright (c) 2015 Ryan Ackermann. All rights reserved.
//

import AudioToolbox

enum SoundEffect: Int {
    case TapSoundEffect = 0,
    SaveSoundEffect = 1,
    ClearSoundEffect = 2,
    ErrorSoundEffect = 3
}

class RAAudioEngine: NSObject
{
    // Singleton Instance
    static let sharedEngine = RAAudioEngine()
    
    var tapAudioEffect: SystemSoundID = 0
    var saveAudioEffect: SystemSoundID = 0
    var clearAudioEffect: SystemSoundID = 0
    var errorAudioEffect: SystemSoundID = 0
    
    override init() {
        super.init()
        
        var tapSoundPath = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("woody_click", ofType: "wav")!)
        var saveSoundPath = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("music_marimba_chord", ofType: "wav")!)
        var clearSoundPath = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("short_whoosh1", ofType: "wav")!)
        var errorSoundPath = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("fancy_toast", ofType: "wav")!)
        
        AudioServicesCreateSystemSoundID(tapSoundPath! as CFURLRef, &tapAudioEffect)
        AudioServicesCreateSystemSoundID(saveSoundPath! as CFURLRef, &saveAudioEffect)
        AudioServicesCreateSystemSoundID(clearSoundPath! as CFURLRef, &clearAudioEffect)
        AudioServicesCreateSystemSoundID(errorSoundPath! as CFURLRef, &errorAudioEffect)
    }
    
    func destroy() {
        AudioServicesDisposeSystemSoundID(tapAudioEffect)
        AudioServicesDisposeSystemSoundID(saveAudioEffect)
        AudioServicesDisposeSystemSoundID(clearAudioEffect)
        AudioServicesDisposeSystemSoundID(errorAudioEffect)
    }
    
    func play(sound: SoundEffect) {
        switch sound {
        case .SaveSoundEffect:
            AudioServicesPlaySystemSound(saveAudioEffect)
        case .TapSoundEffect:
            AudioServicesPlaySystemSound(tapAudioEffect)
        case .ClearSoundEffect:
            AudioServicesPlaySystemSound(clearAudioEffect)
        case .ErrorSoundEffect:
            AudioServicesPlaySystemSound(errorAudioEffect)
        }
    }
    
}
