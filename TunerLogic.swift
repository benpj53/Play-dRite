import AudioKit
import AudioKitEX
import AudioKitUI
import AudioToolbox
import SoundpipeAudioKit
import SwiftUI

struct TunerData {
    var pitch: Float = 0.0
    var amplitude: Float = 0.0
}

struct RawFrequencyData {
    var pitch: Float = 0.0
    var amplitude: Float = 0.0
    var time: Int = 0
}

class TunerConductor: HasAudioEngine {
    @Published var data = TunerData()

    let engine = AudioEngine()
    let initialDevice: Device

    let mic: AudioEngine.InputNode
    let tappableNodeA: Fader
    let tappableNodeB: Fader
    let tappableNodeC: Fader
    let silence: Fader

    var tracker: PitchTap!
    
    var musicXMLString: String
    var sheetMusicView: SheetMusicDisplayController
    var musicDataPackage: MusicDataPackage
    var TOTAL_PERFORMANCE_TIME: Int
    var tuningIsFinished: Bool
    var noteAverage: Int

    init() {
        
        //Initialize empty variables which will be filled later
        var emptyMeasuresArray = [[NoteObject(isRest: false, pitch: "A", octave: 4, accidental: 0, length: "quarter", isDotted: false, measureNumber: 0)]]
        musicDataPackage = MusicDataPackage(measuresArray: emptyMeasuresArray)
        sheetMusicView = SheetMusicDisplayController(scoreString: "")
        musicXMLString = ""
        TOTAL_PERFORMANCE_TIME = 0
        tuningIsFinished = false
        noteAverage = 0
        
        //Microphone logic
        guard let input = engine.input else { fatalError() }

        guard let device = engine.inputDevice else { fatalError() }

        initialDevice = device

        mic = input
        tappableNodeA = Fader(mic)
        tappableNodeB = Fader(tappableNodeA)
        tappableNodeC = Fader(tappableNodeB)
        silence = Fader(tappableNodeC, gain: 0)
        engine.output = silence
        
        var frequencyRawData = [RawFrequencyData]()
        var i = 0

        //Track the frequencies currently being played
        tracker = PitchTap(mic) { pitch, amp in
            DispatchQueue.main.async {
                
                frequencyRawData.append(RawFrequencyData(pitch: pitch[0], amplitude: amp[0], time: i))
                i+=1
                
                if i > self.TOTAL_PERFORMANCE_TIME {
                    self.performFrequencyAnalysis(rawFrequencyData: frequencyRawData, rawMusicData: self.musicDataPackage, sheetMusicDisplay: self.sheetMusicView)
                    self.stop()
                }
            }
        }
       
        tracker.start()
       
    }
    
    func performFrequencyAnalysis(rawFrequencyData: [RawFrequencyData], rawMusicData: MusicDataPackage, sheetMusicDisplay: SheetMusicDisplayController){
        
        let beatsPerMinute = Double(rawMusicData.beatsPerMinute)
        let beatsPerMeasure = Double(rawMusicData.beatsPerMeasure)
        let beatPulse = Double(rawMusicData.beatPulse)
        
        var measureStartTime = 0.0
        var measureNumber = 1
        
        for measure in rawMusicData.measuresArray {
            
            measureStartTime = Double((measureNumber - 2)) * (beatsPerMeasure / beatsPerMinute * 60)
            var noteEndTime = 0.0
            var noteStartTime = 0.0
            
            for note in measure {
                
                if noteEndTime == 0.0 { //Note starts at the beginning of the measure
                     noteStartTime = measureStartTime
                } else {
                     noteStartTime = noteEndTime
                }
            
                noteEndTime = noteStartTime + (note.lengthInt * beatsPerMeasure / beatsPerMinute * 60)
                
                var noteLowerBound = Int(noteStartTime * 11.75)
                
                var noteUpperBound = Int(noteEndTime * 11.75)
                
                
                for dataObject in rawFrequencyData {
                    
                    if (dataObject.time > noteLowerBound) && (dataObject.time < noteUpperBound) {
                        
                        var playedPitch = Double(dataObject.pitch)
                    
                        var pitchUpperBound = note.getPitchUpperBound()
                        var pitchLowerBound = note.getPitchLowerBound()
                        
                        if pitchLowerBound < playedPitch && playedPitch < pitchUpperBound {
                            note.isCorrect = true
                        }
                        
                    }
                }
                
            }
            
            noteEndTime = 0.0
            measureNumber += 1
            
        }
        
        //Calculate the average notes played correctly
        var correctNotes = 0
        var totalNotes = 0
        for measure in rawMusicData.measuresArray {
            for note in measure {
                if note.isCorrect {
                    correctNotes += 1
                } else {
                }
                totalNotes += 1
            }
        }
        
        noteAverage = Int(Double(correctNotes)/Double(totalNotes) * 100)
        var performanceAnalysisController = PerformanceAnalysisController(noteAverageCorrect: noteAverage, musicXMLString: musicXMLString)
        performanceAnalysisController.modalPresentationStyle = .fullScreen
        sheetMusicView.present(performanceAnalysisController, animated: false)
        
    }

}

struct TunerView: View {
    
    var musicDataPackage: MusicDataPackage
    
    var sheetMusicView: SheetMusicDisplayController
    
    init(musicRawDataPackage: MusicDataPackage, rawSheetMusicView: SheetMusicDisplayController){
        
        self.musicDataPackage = musicRawDataPackage
        self.sheetMusicView = rawSheetMusicView
        
    }
    
    var conductor = TunerConductor()

    var body: some View {
        VStack {
        }
        .onAppear {
            
            let numberOfMeasures = self.musicDataPackage.measuresArray.count - 1
            let bpm = self.musicDataPackage.beatsPerMinute
            let beatsPerMeasure = self.musicDataPackage.beatsPerMeasure
            
            let totalPerformanceTime = (Double(beatsPerMeasure * numberOfMeasures) / Double(bpm)) * 60.0
            
            conductor.sheetMusicView = sheetMusicView
            conductor.musicXMLString = sheetMusicView.musicXMLString
            conductor.musicDataPackage = self.musicDataPackage
            conductor.TOTAL_PERFORMANCE_TIME = Int(totalPerformanceTime * 11.75)
            conductor.start()
        }
        .onDisappear {
            conductor.stop()
        }
    }
}
