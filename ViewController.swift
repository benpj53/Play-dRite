//
//  ViewController.swift
//  Play'dRiteDemo_Version_2
//
//  Created by Ben Johnson  on 1/20/23.
//

import Foundation
import UIKit
import CoreData
import MobileCoreServices
import UniformTypeIdentifiers

class ViewController: UIViewController, UIDocumentPickerDelegate, UITableViewDelegate, UITableViewDataSource  {
    
    let downloadedScoreListTableView = UITableView()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var welcomeText = "Welcome to Play'd-Rite. Let's play better, together."
    var scoreList: [String] = []
    var scoreFileList: [URL] = []
    var scores: [NSManagedObject] = []
    
    let cellReuseIdentifier = "cell"

    //MARK: - Setup Initial View
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        setupLabels()
        
        //Refresh score list
        self.scoreList = getAllSheetMusicNames()
        
        loadPreviouslyUsedScoreList()
        
        //Import a new score
        let importNewScoreButton = UIButton(type: .system)
        let importNewScoreButtonXAxis = view.center.x + 10
        let importNewScoreButtonYAxis = view.center.y - 150
        importNewScoreButton.frame = CGRect(x: importNewScoreButtonXAxis, y: importNewScoreButtonYAxis, width: 200, height: 100)
        importNewScoreButton.setImage(UIImage(systemName: "folder"), for: .normal)
        importNewScoreButton.addTarget(self, action: #selector(importNewScoreSelection(_:)), for: .touchUpInside)
        self.view.addSubview(importNewScoreButton)
        
    }
    
    func setupLabels(){
        
        //Welcome label
        let welcomeLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 350, height: 150))
        let welcomeLabelYAxis = view.center.y - 250
        welcomeLabel.center = CGPoint(x: view.center.x, y: welcomeLabelYAxis)
        welcomeLabel.text = welcomeText
        welcomeLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        welcomeLabel.numberOfLines = 0
        welcomeLabel.textAlignment = NSTextAlignment.center
        welcomeLabel.font = UIFont(name: "Times New Roman", size: 30)
        self.view.addSubview(welcomeLabel)
        
        //Score selection label
        let selectionText = "Please select a previous score or choose a new one:"
        let selectionLabelYAxis = view.center.y - 150
        let selectionLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 100))
        selectionLabel.center = CGPoint(x: view.center.x, y: selectionLabelYAxis)
        selectionLabel.text = selectionText
        selectionLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        selectionLabel.numberOfLines = 0
        selectionLabel.textAlignment = NSTextAlignment.center
        selectionLabel.font = UIFont(name: "Times New Roman", size: 22)
        self.view.addSubview(selectionLabel)
        
    }
    
    func loadPreviouslyUsedScoreList(){
        
        //Load previously used score selections - Create a scrolling list
        let downloadScoreListWidth = 300
        let downloadScoreListXAxis = Int(view.center.x) - (downloadScoreListWidth/2)
        let downloadScoreListYAxis = Int(view.center.y) - 60
        downloadedScoreListTableView.frame = CGRect(x: CGFloat(downloadScoreListXAxis), y: CGFloat(downloadScoreListYAxis), width: CGFloat(downloadScoreListWidth), height: 450)
        downloadedScoreListTableView.isScrollEnabled = true
        downloadedScoreListTableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        downloadedScoreListTableView.translatesAutoresizingMaskIntoConstraints = false
        downloadedScoreListTableView.dataSource = self
        downloadedScoreListTableView.allowsSelection = true
        //downloadedScoreListTableView.
        self.view.addSubview(downloadedScoreListTableView)
        
    }
    
    //MARK: - Setup Button Functionality and Document Selection
    
    @objc func importNewScoreSelection(_ sender: AnyObject){
        
        let supportedTypes: [UTType] = [UTType.item]
        
        //Create document picker and specify the types we want
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: supportedTypes, asCopy: true)
        documentPicker.delegate = self
        self.present(documentPicker, animated: true)

    }
    
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            
        guard let myURL = urls.first else {
            return
        }
        
        //First, make sure it's an xml file
        if myURL.pathExtension == "musicxml" {
            
            //Get the name --> Last path component without "." + path extension
            let uncutFileName = myURL.lastPathComponent
            let cutFileName = uncutFileName.components(separatedBy: ".\(myURL.pathExtension)")
            let fileName = cutFileName[0]
    
            guard var sheetMusicString = try? String(contentsOf: myURL) else {
                print("Couldn't read the MusicXML file")
                return
            }
            
            //Add the sheet music to core data
            addNewSheetMusicItem(sheetMusicName: fileName, xmlString: sheetMusicString, bpm: 120)
        
                controller.dismiss(animated: true)
            
                //Display sheet music
                let sheetMusicDisplay = SheetMusicDisplayController(scoreString: sheetMusicString)
                sheetMusicDisplay.modalPresentationStyle = .fullScreen
                present(sheetMusicDisplay, animated: false)
            
        } else {
            
            //Display pop-up that the user has selected the wrong file type
            let systemMessage = UIAlertController(title: "Invalid File Type", message: "\(myURL.pathExtension) is not a supported music type. Please select a MusicXML file", preferredStyle: .alert)
            let dismiss = UIAlertAction(title: "Dismiss", style: .default, handler: { (action) -> Void in
                 print("")
              })
            systemMessage.addAction(dismiss)
            self.present(systemMessage, animated: true, completion: nil)
            
        }
        
    }
    
    
    //MARK: - TableView Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.scoreList.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let score = scoreList[indexPath.row]
        
        let cell = downloadedScoreListTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
   
        cell.textLabel?.text = score
        
        let cellButton = UIButton(type: .system)
        cellButton.frame = cell.frame
        cellButton.tag = indexPath.row
        cellButton.addTarget(self, action: #selector(sheetMusicDisplayFromTableSelection(_:)), for: .touchUpInside)
        cell.addSubview(cellButton)
        return cell
        
    }
    
    @objc func sheetMusicDisplayFromTableSelection(_ sender: AnyObject){
        
        let chosenScoreIndex = sender.tag.unsafelyUnwrapped
        
        var selectedScore = scoreList[chosenScoreIndex]
        var score = getSheetMusicItemFromName(sheetMusicName: selectedScore)
        var selectedScoreString = score.xmlString ?? "UNKNOWN"
        
        let sheetMusicDisplay = SheetMusicDisplayController(scoreString: selectedScoreString)
        sheetMusicDisplay.modalPresentationStyle = .fullScreen
        present(sheetMusicDisplay, animated: false)
        
    }
    
    //MARK: - CoreData Functions
    
    func getAllSheetMusicNames() -> [String]{
        
        var names: [String] = []
        
        do {
            let items = try context.fetch(SheetMusicItem.fetchRequest())
            
            for sheetMusic in items {
                if sheetMusic.name != nil {
                    names.append(sheetMusic.name!)
                }
            }
        } catch {
            print("Error in getting sheet music names")
        }
        return names
    }
    
    func getSheetMusicItemFromName(sheetMusicName: String) -> SheetMusicItem {
        
        var selectedSheetMusicItem = SheetMusicItem(context: context)
        
        do {
            let items = try context.fetch(SheetMusicItem.fetchRequest())

            for sheetMusic in items {
                if(sheetMusic.name == sheetMusicName){
                    selectedSheetMusicItem = sheetMusic
                }
            }
        } catch {
            print("Error in getting sheet music from names")
        }
        
        return selectedSheetMusicItem
        
    }
    
    func addNewSheetMusicItem(sheetMusicName: String, xmlString: String, bpm: Int16){
        
        let newItem = SheetMusicItem(context: context)
        newItem.name = sheetMusicName
        newItem.xmlString = xmlString
        newItem.bpm = bpm
        
        do {
            try context.save()
        } catch {
            print("Error in adding new sheet music item")
        }
        
    }
    
}
