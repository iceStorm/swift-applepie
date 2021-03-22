//
//  ViewController.swift
//  applepie
//
//  Created by Nguyen Anh Tuan on 3/3/21.
//  Copyright © 2021 BVU. All rights reserved.
//

import UIKit
import swift_extensions

enum SegueIntent {
    case Finished;
    case Failed;
}

class ViewController: UIViewController, GameStateEventListener {
    @IBOutlet var buttonsList: [UIButton]!
    
    @IBOutlet weak var stackviewGuessedButton: UIStackView!
    @IBOutlet var guessedButtonsList: [UIButton]!
    
    @IBOutlet weak var txtScores: UILabel!
    @IBOutlet weak var txtRounds: UILabel!
    @IBOutlet weak var txtHearts: UILabel!
    @IBOutlet weak var txtHints: UILabel!
    
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnHint: UIButton!
    @IBOutlet weak var imvHint: UIImageView!
    
    var game: Game!
    var gameData: [GameData]!
    var selectedGameMode: GameMode!
    var allowRandomOrdering: Bool!
    var segueIntent: SegueIntent!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        
        
        //  remove all existing guessed buttons for future handling easier | the three existing guessed buttons (blue) is for designing
        while guessedButtonsList.count > 0 {
            let firstElem = guessedButtonsList.removeFirst()
            firstElem.removeFromSuperview()
        }
        
        
        //  print(selectedGameMode, allowRandomOrdering)
        //  the three variables is passed from the HomeViewController
        game = Game(eventListener: self, data: gameData, gameMode: selectedGameMode, randomOrdering: allowRandomOrdering)
        game.nextRound()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let finishedViewController = segue.destination as! GameFinishedViewController
        finishedViewController.gainedScores = game.getScores
        finishedViewController.isGameFinished = segueIntent == SegueIntent.Finished
    }
    
    
    
    
    //  UI functions
    func initUI() {
        btnHint.layer.cornerRadius = 10
        
        //  set letter buttons rounded radius
        for button in buttonsList {
            button.layer.cornerRadius = button.frame.size.width / 2
        }
    }
    
    func releaseAllLetterButtons() {
        for button in buttonsList {
            button.isEnabled = true
            button.backgroundColor = UIColor(red: 255/255, green: 246/255, blue: 204/255, alpha: 1)
        }
    }
    
    func releaseAllGuessedButtons() {
        for button in guessedButtonsList {
            button.setTitle(" ", for: UIControl.State.normal)
        }
    }
    
    func releaseHintButton() {
        btnHint.isEnabled = true
        btnHint.backgroundColor = UIColor(red: 255/255, green: 246/255, blue: 204/255, alpha: 1)
        btnHint.setTitleColor(.systemOrange, for: .normal)
    }
    
    func setGuessableButtons(_ currentWord: String) {   //  removing or adding guessable buttons that match the length of current word
        //  adding
        if (guessedButtonsList.count < currentWord.count) {
            for _ in 0..<currentWord.count - guessedButtonsList.count {
                let newButton = getNewButton
                guessedButtonsList.append(newButton)
                stackviewGuessedButton.addArrangedSubview(newButton)
            }
            return
        }
        
        //  removing
        if (guessedButtonsList.count > currentWord.count) {
            for _ in 0..<guessedButtonsList.count - currentWord.count {
                guessedButtonsList.removeFirst().removeFromSuperview()
            }
        }
    }
    
    
    
    
    //  get called by the "game" instance
    func onNewRound(currentItem: GameData) {
        setGuessableButtons(currentItem.word)
        guessedWord = String(repeating: " ", count: currentItem.word.count)
        imvHint.image = UIImage(named: currentItem.imageName)
        
        
        //  re-enable all letter buttons
        releaseAllLetterButtons()
        
        //  clear all guessed button's content
        releaseAllGuessedButtons()
        
        
        //  re-enabled the hint button
        releaseHintButton()
    }
    
    func onOutOfWords() {
        segueIntent = .Finished
        performSegue(withIdentifier: "GoToFinished", sender: self)
    }
    
    func onOutOfHearts() {
        segueIntent = .Failed
        performSegue(withIdentifier: "GoToFinished", sender: self)
    }
    
    func onOutOfHints() {
        btnHint.isEnabled = false
        btnHint.backgroundColor = UIColor.lightGray
        btnHint.setTitleColor(.darkGray, for: .normal)
    }
    
    func onHintConsumed(hintsCount: Int) {
        txtHints.text = "\(hintsCount)"
    }
    
    func onScoresUpdated(scores: Int) {
        txtScores.text = "\(scores)"
    }
    
    func onHeartsChanged(count: Int) {
        txtHearts.text = "\(count)"
    }
    
    func onGuessedWordUpdated(callbackString: String) {
        guessedWord = callbackString
    }
     
    func onRoundIndexUpdated(currentRound: Int, totalRounds: Int) {
        txtRounds.text = "Round: \(currentRound)\\\(totalRounds)"
    }
    
    
    
    
    //  computed properties
    public var guessedWord: String {
        get {
            var charsArr: [Character] = []
            
            for button in guessedButtonsList {
                charsArr += button.currentTitle ?? " "
            }
            
            return String(charsArr)
        }
        
        set(value) {
            let valueArr = Array(value)
            
            for i in 0..<guessedButtonsList.count {
                guessedButtonsList[i].setTitle("\(valueArr[i])", for: .normal)
            }
        }
    }
    
    private var getNewButton: UIButton {
        let button = UIButton()
        
        button.layer.cornerRadius = 10
        button.backgroundColor = .systemBlue
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 32)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 60).isActive = true
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        return button
    }
    
    
    
    
    //  event handling functions
    @IBAction func letterButtonTouched(_ sender: UIButton) {
        //  let's predict the pressed character
        if (game.predict(guessedChar: sender.currentTitle![0]!)) {
            sender.backgroundColor = UIColor.green
        }
        else {
            sender.backgroundColor = UIColor.red
        }

        
        
        //  disable the pressed button
        sender.isEnabled = false
    }
    
    @IBAction func btnShowHintClicked(_ sender: UIButton) {
        game.hint(guessedWord: guessedWord)
    }
    
    @IBAction func btnBackClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}

