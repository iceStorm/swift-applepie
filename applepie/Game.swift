//
//  Game.swift
//  applepie
//
//  Created by Nguyen Anh Tuan on 3/3/21.
//  Copyright © 2021 BVU. All rights reserved.
//

import Foundation


enum GameMode: String {
    case Easy = "Easy";
    case Hard = "Hard";
}

struct GameCategory {
    var categoryName: String
    var data: [GameData]
}

struct GameData {
    var word: String
    var imageName: String
}

protocol GameStateEventListener {
    func onOutOfWords()
    func onOutOfHearts()
    
    func onNewRound(currentItem: GameData)
    func onScoresUpdated(scores: Int)
    
    func onHintSuccess(character: Character)
    func onHintConsumed(hintsCount: Int)
    func onOutOfHints()
    
    func onRoundIndexUpdated(currentRound: Int, totalRounds: Int)
    func onHeartsChanged(count: Int)
    func onGuessedWordUpdated(callbackString: String)
    func onGameModeChanged(mode: GameMode)
    
}


class Game {
    private var mode: GameMode
    private var data: [GameData]
    private var randomOrdering: Bool
    private var eventListener: GameStateEventListener
    
    
    private var scores: Int {
        didSet {
            eventListener.onScoresUpdated(scores: scores)
        }
    }
    
    private var heartsCount: Int! {
        didSet {
            eventListener.onHeartsChanged(count: heartsCount)
            if heartsCount == 0 {
                eventListener.onOutOfHearts()
            }
        }
    }
    
    private var currentItem: GameData! {
        willSet {
            if currentItem != nil && newValue.word == "" {
                eventListener.onOutOfWords()
            }
        }
        didSet {
            eventListener.onNewRound(currentItem: currentItem)
        }
    }
    
    private var currentItemIndex: Int! {
        didSet {
            eventListener.onRoundIndexUpdated(currentRound: currentItemIndex + 1, totalRounds: data.count + currentItemIndex)
        }
    }
    
    private var typedCharacters: [Character]! {
        didSet {
            eventListener.onGuessedWordUpdated(callbackString: currentHiddenWord)
        }
    }
    
    private var continuousSuccessCount: Int! {
        didSet {
            if continuousSuccessCount > 0 {
                scores += 10 * continuousSuccessCount
            }
        }
    }
    
    private var continousFailureCount: Int! {
        didSet {
            if continousFailureCount > 0 && mode == GameMode.Hard {
                scores -= 10 * continousFailureCount
            }
       }
    }
    
    private var hintedCount: Int! {
        didSet {
            eventListener.onHintConsumed(hintsCount: hintLimit - hintedCount)
            
            if (hintLimit == hintedCount) {
                eventListener.onOutOfHints()
            }
        }
    }
    
    
    
    //  constructor
    init(eventListener: GameStateEventListener, data: [GameData], gameMode: GameMode = GameMode.Easy, randomOrdering: Bool = false) {
        self.randomOrdering = randomOrdering
        self.eventListener = eventListener
        self.data = data
        self.mode = gameMode
        
        currentItemIndex = -1
        scores = 0
        
        eventListener.onGameModeChanged(mode: mode)
        nextRound()
    }
    
    func nextRound() {
        if (currentItemIndex != -1) {   //  not the new game    (only the next games)
            scores += mode == GameMode.Easy ? 50 : 100     //  bonus when finished a whole word
        }
        else {
            heartsCount = mode == GameMode.Easy ? 10 : 5    //  this line is called only once to set the total hearts for the whole game
        }
        
        currentItem = nextItem  //  must be called first to trigger the onNewRound() event to the ViewController
        typedCharacters = []
        continuousSuccessCount = -1
        continousFailureCount = -1
        hintedCount = 0
    }
    
    
    
    
    // whether the wordsList contains any word.
    var getScores: Int {
        return scores
    }
    
    var isOutOfHearts: Bool {
        return heartsCount == 0
    }
    
    var isEndOfRound: Bool {
        return currentItem.word == (eventListener as! ViewController).guessedWord
    }
    
    var hintLimit: Int {
        return mode == GameMode.Easy ? 3 : 2
    }
    
    var nextItem: GameData {
        currentItemIndex += 1
        
        if (data.count == 0) {
            return GameData(word: "", imageName: "")
        }
        
        let theNextItem = randomOrdering ? data.remove(at: Int.random(in: 0..<data.count)) : data.removeFirst()
        return theNextItem
    }
    
    var currentHiddenWord: String {
        var chars = ""
        let lowercasedTypedLetters = String(typedCharacters).lowercased()
        
        for letter in currentItem.word {
            if (lowercasedTypedLetters.contains(letter.lowercased())) {
                chars += "\(letter)"
            }
            else {
                chars += " "
            }
        }
        
        return chars
    }
    
    
    
    
    func predict(guessedChar: Character) -> Bool {
        var returnValue = false
        
        
        if (!currentItem.word.lowercased().contains(guessedChar.lowercased())) { //  wrong predicted
            if (mode == GameMode.Hard) {
                continousFailureCount += 1
                scores -= 10
            }

            continuousSuccessCount = -1
            heartsCount -= 1
        }
        else
        {  //  predicted success
            returnValue = true
            typedCharacters.append(guessedChar)
            scores += 10    //  bonus
            
            continuousSuccessCount += 1
            continousFailureCount = -1
        }

        
        print(currentItem!, currentHiddenWord)
        if (isEndOfRound) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: nextRound)
        }
        
        
        return returnValue
    }
    
    func hint(guessedWord: String) {
        while true {
            let randomNumber = Int.random(in: 0..<guessedWord.count)
            let guessedCharacter = Array(guessedWord)[randomNumber]
            
            // if at the index guessedWord[randomNumber] is a hypen (not yet guessed)
            if (guessedCharacter == " ") {
                hintedCount += 1
                typedCharacters += "\(Array(currentItem.word)[randomNumber])"
                eventListener.onHintSuccess(character: typedCharacters.last!)
                
                
                //  minusing the score if hinted in the Hard mode
                if (mode == GameMode.Hard) {
                    scores -= 20
                }
                
                
                //  check if the user has just filled all the characters correctly
                if (isEndOfRound) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: nextRound)
                }
                
                return   //  return when catched a character
            }
        }
    }
    
    
}
