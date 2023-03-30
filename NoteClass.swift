//
//  NoteClass.swift
//  Play'dRiteDemo_Version_2
//
//  Created by Ben Johnson  on 1/23/23.
//

import Foundation

class NoteObject {
    
    var isRest      : Bool          //  If true, it's a rest and the pitch will be set to "UNSET", the octave and accidental will be set to 0
    var pitch       : String        //  Will be either: C, D, E, F, G, A, or B
    var octave      : Int           //  Will be between 1 or 8 typically
    var accidental  : Int           //  0 = no accidental, 1 = sharp, 2 = flat
    var length      : String        //  Can be 256th, 128th, 64th, 32nd, 16th, eighth, quarter, half, whole, breve, and long
    var isDotted    : Bool          //  Indicates whether or not the note is dotted in rhythm
    var lengthInt   : Double        //  The portion of the measure that the note length is
    var measureNumber : Int         //  Measure number
    var isCorrect     : Bool        //  Indicates whether or not it was played right
    
    init(isRest: Bool, pitch: String, octave: Int, accidental: Int, length: String, isDotted: Bool, measureNumber: Int) {
        
        self.isRest = isRest
        self.pitch = pitch
        self.octave = octave
        self.accidental = accidental
        self.length = length
        self.isDotted = isDotted
        self.lengthInt = 0
        self.measureNumber = measureNumber
        self.isCorrect = false
        
    }
    
    func setNoteLengthInt(){
        
        switch self.length {
        case "256th":
            self.lengthInt = 1/256
        case "128th":
            self.lengthInt = 1/128
        case "64th":
            self.lengthInt = 1/64
        case "32nd":
            self.lengthInt = 1/32
        case "16th":
            self.lengthInt = 1/16
        case "eighth":
            self.lengthInt = 1/8
        case "quarter":
            self.lengthInt = 1/4
        case "half":
            self.lengthInt = 1/2
        case "whole":
            self.lengthInt = 1/1
        default:
            self.lengthInt = 0
        }
        
        if isDotted {
            lengthInt = lengthInt + (lengthInt/2)
        }
    }
    
    func getFullNoteInformation() -> String {
        
        if self.isRest{
            return "This is a rest with length: " + length + " and a length in numbers: " + String(lengthInt)
        } else if self.accidental != 0 {
            return "Pitch: " + pitch + " Octave: " + String(octave) + " Accidental: " + String(accidental) + " Length: " + length + " Length in numbers: " + String(lengthInt)
        } else {
            return "Pitch: " + pitch + " Octave: " + String(octave) +  " Length: " + length + " Length in numbers: " + String(lengthInt)
        }
    }
    
    func getPitchUpperBound() -> Double {
        
        var originalPitchFrequency = self.getPitchFrequency()
        
        switch self.accidental {
            case 1:
                var newNoteName = ""
                switch self.pitch {
                case "A":
                    newNoteName = "B"
                case "B":
                    newNoteName = "C"
                    self.octave += 1
                case "C":
                    newNoteName = "D"
                case "D":
                    newNoteName = "E"
                case "E":
                    newNoteName = "F"
                case "F":
                    newNoteName = "G"
                case "G":
                    newNoteName = "A"
                default:
                    newNoteName = self.pitch
                }
                self.accidental = 0
                self.pitch = newNoteName
                return self.getPitchFrequency()
            case 2:
                self.accidental = 0
                return self.getPitchFrequency()
            default:
                self.accidental = 1
                return self.getPitchFrequency()
        }
    }
    
    func getPitchLowerBound() -> Double {
        var originalPitchFrequency = self.getPitchFrequency()
        
        switch self.accidental {
            case 2:
                var newNoteName = ""
                switch self.pitch {
                case "A":
                    newNoteName = "G"
                case "B":
                    newNoteName = "A"
                case "C":
                    newNoteName = "B"
                    self.octave -= 1
                case "D":
                    newNoteName = "C"
                case "E":
                    newNoteName = "D"
                case "F":
                    newNoteName = "E"
                case "G":
                    newNoteName = "F"
                default:
                    newNoteName = self.pitch
                }
                self.accidental = 0
                self.pitch = newNoteName
                return self.getPitchFrequency()
            case 1:
                self.accidental = 0
                return self.getPitchFrequency()
            default:
                self.accidental = 1
                return self.getPitchFrequency()
        }
    }
    
    func getPitchFrequency() -> Double {
        
        switch self.octave {
            
        case 0: //First octave
            switch self.pitch {
            case "C":
                switch self.accidental {
                case 2: //Flat
                    return 15.43
                case 1: //Sharp
                    return 17.32
                default: //No accidental
                    return 16.35
                }
            case "D":
                switch self.accidental {
                case 2: //Flat
                    return 17.32
                case 1: //Sharp
                    return 19.45
                default: //No accidental
                    return 18.35
                }
            case "E":
                switch self.accidental {
                case 2: //Flat
                    return 19.45
                case 1: //Sharp
                    return 21.83
                default: //No accidental
                    return 20.60
                }
            case "F":
                switch self.accidental {
                case 2: //Flat
                    return 20.60
                case 1: //Sharp
                    return 23.12
                default: //No accidental
                    return 21.83
                }
            case "G":
                switch self.accidental {
                case 2: //Flat
                    return 23.12
                case 1: //Sharp
                    return 25.96
                default: //No accidental
                    return 24.50
                }
            case "A":
                switch self.accidental {
                case 2: //Flat
                    return 25.96
                case 1: //Sharp
                    return 29.14
                default: //No accidental
                    return 27.50
                }
            case "B":
                switch self.accidental {
                case 2: //Flat
                    return 29.14
                case 1: //Sharp
                    return 32.70
                default: //No accidental
                    return 30.87
                }
            default:
                return 0.0
            }
            
        case 1:
            switch self.pitch {
            case "C":
                switch self.accidental {
                case 2: //Flat
                    return 30.87
                case 1: //Sharp
                    return 34.65
                default: //No accidental
                    return 32.70
                }
            case "D":
                switch self.accidental {
                case 2: //Flat
                    return 34.65
                case 1: //Sharp
                    return 38.89
                default: //No accidental
                    return 36.71
                }
            case "E":
                switch self.accidental {
                case 2: //Flat
                    return 38.89
                case 1: //Sharp
                    return 43.65
                default: //No accidental
                    return 41.20
                }
            case "F":
                switch self.accidental {
                case 2: //Flat
                    return 41.20
                case 1: //Sharp
                    return 46.25
                default: //No accidental
                    return 43.65
                }
            case "G":
                switch self.accidental {
                case 2: //Flat
                    return 46.25
                case 1: //Sharp
                    return 51.91
                default: //No accidental
                    return 49.00
                }
            case "A":
                switch self.accidental {
                case 2: //Flat
                    return 51.91
                case 1: //Sharp
                    return 58.27
                default: //No accidental
                    return 55.00
                }
            case "B":
                switch self.accidental {
                case 2: //Flat
                    return 58.27
                case 1: //Sharp
                    return 65.41
                default: //No accidental
                    return 61.74
                }
            default:
                return 0.0
            }
            
        case 2:
            switch self.pitch {
            case "C":
                switch self.accidental {
                case 2: //Flat
                    return 61.74
                case 1: //Sharp
                    return 69.30
                default: //No accidental
                    return 65.41
                }
            case "D":
                switch self.accidental {
                case 2: //Flat
                    return 69.30
                case 1: //Sharp
                    return 77.78
                default: //No accidental
                    return 73.42
                }
            case "E":
                switch self.accidental {
                case 2: //Flat
                    return 77.78
                case 1: //Sharp
                    return 87.31
                default: //No accidental
                    return 82.41
                }
            case "F":
                switch self.accidental {
                case 2: //Flat
                    return 82.41
                case 1: //Sharp
                    return 92.50
                default: //No accidental
                    return 87.31
                }
            case "G":
                switch self.accidental {
                case 2: //Flat
                    return 92.50
                case 1: //Sharp
                    return 103.83
                default: //No accidental
                    return 98.00
                }
            case "A":
                switch self.accidental {
                case 2: //Flat
                    return 103.83
                case 1: //Sharp
                    return 116.54
                default: //No accidental
                    return 110.00
                }
            case "B":
                switch self.accidental {
                case 2: //Flat
                    return 116.54
                case 1: //Sharp
                    return 130.81
                default: //No accidental
                    return 123.47
                }
            default:
                return 0.0
            }
            
        case 3:
            switch self.pitch {
            case "C":
                switch self.accidental {
                case 2: //Flat
                    return 123.47
                case 1: //Sharp
                    return 138.59
                default: //No accidental
                    return 130.81
                }
            case "D":
                switch self.accidental {
                case 2: //Flat
                    return 138.59
                case 1: //Sharp
                    return 155.56
                default: //No accidental
                    return 146.83
                }
            case "E":
                switch self.accidental {
                case 2: //Flat
                    return 155.56
                case 1: //Sharp
                    return 174.61
                default: //No accidental
                    return 164.81
                }
            case "F":
                switch self.accidental {
                case 2: //Flat
                    return 164.81
                case 1: //Sharp
                    return 185.00
                default: //No accidental
                    return 174.61
                }
            case "G":
                switch self.accidental {
                case 2: //Flat
                    return 185.00
                case 1: //Sharp
                    return 207.65
                default: //No accidental
                    return 196.00
                }
            case "A":
                switch self.accidental {
                case 2: //Flat
                    return 207.65
                case 1: //Sharp
                    return 233.08
                default: //No accidental
                    return 220.00
                }
            case "B":
                switch self.accidental {
                case 2: //Flat
                    return 233.08
                case 1: //Sharp
                    return 261.63
                default: //No accidental
                    return 246.94
                }
            default:
                return 0.0
            }
            
    case 4:
            switch self.pitch {
            case "C":
                switch self.accidental {
                case 2: //Flat
                    return 246.94
                case 1: //Sharp
                    return 277.18
                default: //No accidental
                    return 261.63
                }
            case "D":
                switch self.accidental {
                case 2: //Flat
                    return 277.18
                case 1: //Sharp
                    return 311.13
                default: //No accidental
                    return 293.66
                }
            case "E":
                switch self.accidental {
                case 2: //Flat
                    return 311.13
                case 1: //Sharp
                    return 349.23
                default: //No accidental
                    return 329.63
                }
            case "F":
                switch self.accidental {
                case 2: //Flat
                    return 329.63
                case 1: //Sharp
                    return 369.99
                default: //No accidental
                    return 349.23
                }
            case "G":
                switch self.accidental {
                case 2: //Flat
                    return 369.99
                case 1: //Sharp
                    return 415.30
                default: //No accidental
                    return 392.00
                }
            case "A":
                switch self.accidental {
                case 2: //Flat
                    return 415.30
                case 1: //Sharp
                    return 466.16
                default: //No accidental
                    return 440.00
                }
            case "B":
                switch self.accidental {
                case 2: //Flat
                    return 466.16
                case 1: //Sharp
                    return 523.25
                default: //No accidental
                    return 493.88
                }
            default:
                return 0.0
            }
            
        case 5:
            switch self.pitch {
            case "C":
                switch self.accidental {
                case 2: //Flat
                    return 493.88
                case 1: //Sharp
                    return 554.37
                default: //No accidental
                    return 523.25
                }
            case "D":
                switch self.accidental {
                case 2: //Flat
                    return 554.37
                case 1: //Sharp
                    return 622.25
                default: //No accidental
                    return 587.33
                }
            case "E":
                switch self.accidental {
                case 2: //Flat
                    return 622.25
                case 1: //Sharp
                    return 698.46
                default: //No accidental
                    return 659.25
                }
            case "F":
                switch self.accidental {
                case 2: //Flat
                    return 659.25
                case 1: //Sharp
                    return 698.46
                default: //No accidental
                    return 698.46
                }
            case "G":
                switch self.accidental {
                case 2: //Flat
                    return 698.46
                case 1: //Sharp
                    return 830.61
                default: //No accidental
                    return 739.99
                }
            case "A":
                switch self.accidental {
                case 2: //Flat
                    return 830.61
                case 1: //Sharp
                    return 932.33
                default: //No accidental
                    return 880.00
                }
            case "B":
                switch self.accidental {
                case 2: //Flat
                    return 932.33
                case 1: //Sharp
                    return 1046.50
                default: //No accidental
                    return 987.77
                }
            default:
                return 0.0
            }
            
        case 6:
            switch self.pitch {
            case "C":
                switch self.accidental {
                case 2: //Flat
                    return 987.77
                case 1: //Sharp
                    return 1108.73
                default: //No accidental
                    return 1046.50
                }
            case "D":
                switch self.accidental {
                case 2: //Flat
                    return 1108.73
                case 1: //Sharp
                    return 1244.51
                default: //No accidental
                    return 1174.66
                }
            case "E":
                switch self.accidental {
                case 2: //Flat
                    return 1244.51
                case 1: //Sharp
                    return 1396.91
                default: //No accidental
                    return 1318.51
                }
            case "F":
                switch self.accidental {
                case 2: //Flat
                    return 1318.51
                case 1: //Sharp
                    return 1479.98
                default: //No accidental
                    return 1396.91
                }
            case "G":
                switch self.accidental {
                case 2: //Flat
                    return 1479.98
                case 1: //Sharp
                    return 1661.22
                default: //No accidental
                    return 1567.98
                }
            case "A":
                switch self.accidental {
                case 2: //Flat
                    return 1661.22
                case 1: //Sharp
                    return 1864.66
                default: //No accidental
                    return 1760.00
                }
            case "B":
                switch self.accidental {
                case 2: //Flat
                    return 1864.66
                case 1: //Sharp
                    return 2093.00
                default: //No accidental
                    return 1975.53
                }
            default:
                return 0.0
            }
            
        case 7:
            switch self.pitch {
            case "C":
                switch self.accidental {
                case 2: //Flat
                    return 1975.53
                case 1: //Sharp
                    return 2217.46
                default: //No accidental
                    return 2093.00
                }
            case "D":
                switch self.accidental {
                case 2: //Flat
                    return 2217.46
                case 1: //Sharp
                    return 2489.02
                default: //No accidental
                    return 2349.32
                }
            case "E":
                switch self.accidental {
                case 2: //Flat
                    return 2489.02
                case 1: //Sharp
                    return 2793.83
                default: //No accidental
                    return 2637.02
                }
            case "F":
                switch self.accidental {
                case 2: //Flat
                    return 2637.02
                case 1: //Sharp
                    return 2959.96
                default: //No accidental
                    return 2793.83
                }
            case "G":
                switch self.accidental {
                case 2: //Flat
                    return 2959.96
                case 1: //Sharp
                    return 3322.44
                default: //No accidental
                    return 3135.96
                }
            case "A":
                switch self.accidental {
                case 2: //Flat
                    return 3322.44
                case 1: //Sharp
                    return 3729.31
                default: //No accidental
                    return 3520.00
                }
            case "B":
                switch self.accidental {
                case 2: //Flat
                    return 3729.31
                case 1: //Sharp
                    return 4186.01
                default: //No accidental
                    return 3951.07
                }
            default:
                return 0.0
            }
            
        case 8:
            switch self.pitch {
            case "C":
                switch self.accidental {
                case 2: //Flat
                    return 3951.07
                case 1: //Sharp
                    return 4434.92
                default: //No accidental
                    return 4186.01
                }
            case "D":
                switch self.accidental {
                case 2: //Flat
                    return 4434.92
                case 1: //Sharp
                    return 4978.03
                default: //No accidental
                    return 4698.63
                }
            case "E":
                switch self.accidental {
                case 2: //Flat
                    return 4978.03
                case 1: //Sharp
                    return 5587.65
                default: //No accidental
                    return 5274.04
                }
            case "F":
                switch self.accidental {
                case 2: //Flat
                    return 5274.04
                case 1: //Sharp
                    return 5919.91
                default: //No accidental
                    return 5587.65
                }
            case "G":
                switch self.accidental {
                case 2: //Flat
                    return 5919.91
                case 1: //Sharp
                    return 6644.88
                default: //No accidental
                    return 6271.93
                }
            case "A":
                switch self.accidental {
                case 2: //Flat
                    return 6644.88
                case 1: //Sharp
                    return 7458.62
                default: //No accidental
                    return 7040.00
                }
            case "B":
                switch self.accidental {
                case 2: //Flat
                    return 7458.62
                case 1: //Sharp
                    return 8372.02
                default: //No accidental
                    return 7902.13
                }
            default:
                return 0.0
            }
        
            
        default:
            return 0.0
        }
    }
}

