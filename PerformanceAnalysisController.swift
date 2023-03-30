//
//  PerformanceAnalysisController.swift
//  Play'dRiteDemo_Version_2
//
//  Created by Ben Johnson  on 1/20/23.
//

import UIKit

class PerformanceAnalysisController: UIViewController {
    
    
    var notesCorrect = 0
    var musicXMLString = ""
    init(noteAverageCorrect: Int, musicXMLString: String){
        
        self.notesCorrect = noteAverageCorrect
        self.musicXMLString = musicXMLString
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        
        //Set background image
        let background = UIImage(named: "sheet-music-background.jpg")
        self.view.backgroundColor = .white
        
        var imageView : UIImageView!
        imageView = UIImageView(frame: view.bounds)
        imageView.contentMode = UIView.ContentMode.scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = background
        imageView.center = view.center
        imageView.layer.opacity = 0.2
        view.addSubview(imageView)
        self.view.sendSubviewToBack(imageView)
        
        //Performance Analysis Label
        let performanceAnalysisLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 350, height: 150))
        let performanceAnalysisLabelYAxis = view.center.y - 250
        performanceAnalysisLabel.center = CGPoint(x: view.center.x, y: performanceAnalysisLabelYAxis)
        performanceAnalysisLabel.text = "Performance Analysis:"
        performanceAnalysisLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        performanceAnalysisLabel.numberOfLines = 0
        performanceAnalysisLabel.textAlignment = NSTextAlignment.center
        performanceAnalysisLabel.font = UIFont(name: "Times New Roman", size: 30)
        self.view.addSubview(performanceAnalysisLabel)
        
        //Note Average Label
        let noteAverageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 150, height: 150))
        let noteAverageLabelYAxis = view.center.y - 100
        noteAverageLabel.center = CGPoint(x: view.center.x, y: noteAverageLabelYAxis)
        noteAverageLabel.text = "Note Average:"
        noteAverageLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        noteAverageLabel.numberOfLines = 0
        noteAverageLabel.textAlignment = NSTextAlignment.center
        noteAverageLabel.font = UIFont(name: "Times New Roman", size: 25)
        self.view.addSubview(noteAverageLabel)
        
        //Note Average Data Label
        let noteAverageDataLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 150, height: 150))
        let noteAverageDataLabelYAxis = view.center.y - 50
        noteAverageDataLabel.center = CGPoint(x: view.center.x, y: noteAverageDataLabelYAxis)
        noteAverageDataLabel.text = "\(notesCorrect)%"
        noteAverageDataLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        noteAverageDataLabel.numberOfLines = 0
        noteAverageDataLabel.textAlignment = NSTextAlignment.center
        noteAverageDataLabel.font = UIFont(name: "Times New Roman", size: 35)
        self.view.addSubview(noteAverageDataLabel)
        
        //Add button to retry the sheet music
        let goBackToSheetMusicButton = UIButton(type: .system)
        goBackToSheetMusicButton.frame = CGRect(x: 20, y: 100, width: 100, height: 50)
        goBackToSheetMusicButton.setImage(UIImage(systemName: "arrowshape.turn.up.backward.circle"), for: .normal)
        goBackToSheetMusicButton.addTarget(self, action: #selector(goBackToSheetMusic(_:)), for: .touchUpInside)
        self.view.addSubview(goBackToSheetMusicButton)
        
        
        //Add button to pick a new piece
        let openScoreSelectorButton = UIButton(type: .system)
        openScoreSelectorButton.frame = CGRect(x: 250, y: 100, width: 100, height: 50)
        openScoreSelectorButton.setImage(UIImage(systemName: "folder"), for: .normal)
        openScoreSelectorButton.addTarget(self, action: #selector(openScoreSelection(_:)), for: .touchUpInside)
        self.view.addSubview(openScoreSelectorButton)
        
    }
    
    //MARK: - Button Functionality
    
    @objc func openScoreSelection(_ sender: AnyObject) {

        let scoreSelectionDisplay = ViewController()
        scoreSelectionDisplay.welcomeText = " "
        scoreSelectionDisplay.modalPresentationStyle = .fullScreen
        present(scoreSelectionDisplay, animated: false)

    }
    
    @objc func goBackToSheetMusic(_ sender: AnyObject) {

        let sheetMusicDisplay = SheetMusicDisplayController(scoreString: musicXMLString)
        sheetMusicDisplay.modalPresentationStyle = .fullScreen
        present(sheetMusicDisplay, animated: false)

    }
    
}
