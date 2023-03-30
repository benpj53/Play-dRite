//
//  SheetMusicDisplayController.swift
//  Play'dRiteDemo_Version_2
//
//  Created by Ben Johnson  on 1/20/23.
//

import UIKit
import WebKit
import AVFoundation
import SwiftUI

struct MusicDataPackage {
    
    var beatsPerMinute: Int = 0
    var beatsPerMeasure: Int = 0
    var beatPulse: Int = 0
    var measuresArray: Array<Array<NoteObject>>
}

class SheetMusicDisplayController: UIViewController, AVAudioPlayerDelegate, AVAudioRecorderDelegate {
   
    var keySignature = 0
    var timeSignatureBeats = 0
    var timeSignatureBeatValue = 0
    var numberOfMeasures = 0
    
    var musicXMLString = ""
    private var sheetMusicWebViewExtension: SheetMusicWebViewExtension!
    var measuresGlobalArray: Array<Array<NoteObject>>
    
    init(scoreString: String){
        
        self.musicXMLString = scoreString
        self.measuresGlobalArray = [[NoteObject.init(isRest: true, pitch: "A", octave: 4, accidental: 0, length: "quarter", isDotted: false, measureNumber: 0)]]
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
            fatalError("init(coder:) is not supported")
        }
    
    override func viewDidLoad() {
        
        //Display the sheet music
        let sheetMusicContainverView = UIView(frame: CGRect(x: 0, y: 150, width: self.view.frame.width, height: self.view.frame.height))
        sheetMusicWebViewExtension = SheetMusicWebViewExtension(containerView: sheetMusicContainverView, musicXMLString: musicXMLString)
        self.view.addSubview(sheetMusicContainverView)
        
        self.view.backgroundColor = .white
        
    //Setup buttons:
        
        //Select new music
        let openScoreSelectorButton = UIButton(type: .system)
        openScoreSelectorButton.frame = CGRect(x: 50, y: 100, width: 100, height: 50)
        openScoreSelectorButton.setImage(UIImage(systemName: "folder"), for: .normal)
        openScoreSelectorButton.addTarget(self, action: #selector(openScoreSelection(_:)), for: .touchUpInside)
        self.view.addSubview(openScoreSelectorButton)
        
        //Start recording
        let startRecordingButton = UIButton(type: .system)
        startRecordingButton.frame = CGRect(x: 250, y: 100, width: 100, height: 50)
        startRecordingButton.setImage(UIImage(systemName: "mic.circle.fill"), for: .normal)
        startRecordingButton.addTarget(self, action: #selector(startRecording(_:)), for: .touchUpInside)
        self.view.addSubview(startRecordingButton)
        
        let notes = readDecompressedXMLFileByNote(xmlFile: musicXMLString)
        self.measuresGlobalArray = notes
        
    }
    
    @objc func openScoreSelection(_ sender: AnyObject) {
        
        let scoreSelectionDisplay = ViewController()
        scoreSelectionDisplay.welcomeText = " "
        scoreSelectionDisplay.modalPresentationStyle = .fullScreen
        present(scoreSelectionDisplay, animated: false)
        
    }
    
//MARK: - Read the XML File and get note information
    
    func readDecompressedXMLFileByNote(xmlFile: String) -> Array<Array<NoteObject>>{
        
        //Get key signature
        let keySignatureXMLFile = xmlFile.components(separatedBy: "<fifths>")
        let keySignatureXMLFileCut = keySignatureXMLFile[1].components(separatedBy: "</fifths>")
        self.keySignature = Int(keySignatureXMLFileCut[0]) ?? 0
        
        //Get time signature
        let timeSignatureXMLFile = xmlFile.components(separatedBy: "<beats>")
        let timeSignatureXMLFileCut = timeSignatureXMLFile[1].components(separatedBy: "</beats>")
        self.timeSignatureBeats = Int(timeSignatureXMLFileCut[0]) ?? 4
        
        let timeSignatureBeatValueXMLFile = xmlFile.components(separatedBy: "<beat-type>")
        let timeSignatureBeatValueXMLFileCut = timeSignatureBeatValueXMLFile[1].components(separatedBy: "</beat-type>")
        self.timeSignatureBeatValue = Int(timeSignatureBeatValueXMLFileCut[0]) ?? 4
        
        let shortenedXMLFile = xmlFile.components(separatedBy: "<measure number=")
        var measures: Array<Array<NoteObject>> = Array() //Each measure is an array of note objects
        var measureNumber = 0
        
        //Delete first measure (that's everything before the measures start)

        for measure in shortenedXMLFile {
            
            var notesByMeasureComponent = measure.components(separatedBy: "<note")
            var notes: Array<NoteObject> = Array()
            
            notesByMeasureComponent.remove(at: 0)
            
            //Delete the first note of every measure (that's everything before the ntoes start)
            
            for note in notesByMeasureComponent {
                
                //Create new note
                let noteObject = NoteObject(isRest: true, pitch: "UNSET", octave: 0, accidental: 0, length: "UNSET", isDotted: false, measureNumber: measureNumber)
                
                //Check if the note is a rest
                if note.contains("<rest />"){
                    noteObject.isRest = true
                }
                
                //Check if the note is a pitch (only other option, but just in case)
                if note.contains("<pitch>"){
                    
                    noteObject.isRest = false
                    
                    //Get the step --> This is the pitch
                    let notePitchUncut = note.components(separatedBy: "<step>")
                    let notePitchCut = notePitchUncut[1].components(separatedBy: "</step>")
                    let notePitch = notePitchCut[0]
                    noteObject.pitch = notePitch
                    
                    //Check for <alter> --> This indicates whether it is sharped or flatted
                    if note.contains("<alter>"){
                        let noteAlterUncut = note.components(separatedBy: "<alter>")
                        let noteAlterCut = noteAlterUncut[1].components(separatedBy: "</alter>")
                        let noteAlter = noteAlterCut[0]
                        if noteAlter == "1" {
                            noteObject.accidental = 1
                        } else if noteAlter == "-1" {
                            noteObject.accidental = 2
                        }
                    }
                    
                    //Get the octave
                    let noteOctaveUncut = note.components(separatedBy: "<octave>")
                    let noteOctaveCut = noteOctaveUncut[1].components(separatedBy: "</octave>")
                    let noteOctave = noteOctaveCut[0]
                    noteObject.octave = Int(noteOctave) ?? 0
                }
                
                //Get the rhythm
                if note.contains("<type>"){
                    let noteLengthUncut = note.components(separatedBy: "<type>")
                    let noteLengthCut = noteLengthUncut[1].components(separatedBy: "</type>")
                    let noteLength = noteLengthCut[0]
                    noteObject.length = noteLength
                    noteObject.setNoteLengthInt()
                    
                }
                
                //Check if the note is dotted
                if note.contains("<dot/>"){
                    noteObject.isDotted = true
                }
                
                notes.append(noteObject)
                
            }
            
            measures.append(notes)
            measureNumber = measureNumber + 1
            
        }
        
        self.numberOfMeasures = measures.count

        return measures
        
    }

//MARK: - Recording and analysis
    
    func getBPM(){
        
        let systemMessage = UIAlertController(title: "Enter BPM", message: "Please enter the bpm:", preferredStyle: .alert)
        
        systemMessage.addTextField{ field in
            field.placeholder = "BPM"
            field.returnKeyType = .continue
            field.keyboardType = .numberPad
        }
        
        systemMessage.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        systemMessage.addAction(UIAlertAction(title: "Continue", style: .default, handler: { _ in
            guard let fields = systemMessage.textFields, fields.count == 1 else {
                return
            }
            let BPMField = fields[0]
            guard let bpm = BPMField.text, !bpm.isEmpty else {
                print("Invalid entries")
                return
            }
            
            let bpmInt = Int(bpm) ?? 0
            self.countDown(bpm: bpmInt)
            
            }))
        self.present(systemMessage, animated: true, completion: nil)
        
    }
    
    func countDown(bpm: Int) {
        
        let waitTime = UInt32(Double(60)/Double(bpm) * 100)
        var i = 0
        
        self.view.backgroundColor = .red
        
        while(i < self.timeSignatureBeats){
            
            //Play sound
            
            usleep(10000 * waitTime)
            
            i+=1
        }
        
        recordAudio(bpm: bpm)
        
    }
    
    func recordAudio(bpm: Int) {
        
        self.view.backgroundColor = .green
        
        var musicDataPackage = MusicDataPackage(beatsPerMinute: bpm,
                                                beatsPerMeasure: timeSignatureBeats,
                                                    beatPulse: timeSignatureBeatValue,
                                                measuresArray: measuresGlobalArray)
       
        let tunerView = TunerView(musicRawDataPackage: musicDataPackage, rawSheetMusicView: self)
        let vc = UIHostingController(rootView: tunerView)
        let swiftuiView = vc.view!
            swiftuiView.translatesAutoresizingMaskIntoConstraints = false
        addChild(vc)
            view.addSubview(swiftuiView)
        NSLayoutConstraint.activate([
                swiftuiView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                swiftuiView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            ])
        vc.didMove(toParent: self)
        
    }
    
    @objc func startRecording(_ sender: AnyObject) {
        
        getBPM()
        
    }
    
    func openPerformanceAnalysis(noteAverageCorrect: Int) {
        
        print("MusicXMLString: ", musicXMLString)
        
        let performanceAnalysisDisplay = PerformanceAnalysisController(noteAverageCorrect: noteAverageCorrect, musicXMLString: musicXMLString)
        performanceAnalysisDisplay.modalPresentationStyle = .fullScreen
        present(performanceAnalysisDisplay, animated: false)
        
    }
    
}
