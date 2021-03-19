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
    
    func onNewGame(currentItem: GameData, totalRounds: Int, hintsCount: Int, heartsCount: Int, scores: Int)
    func onScoresUpdated(scores: Int)
    func onNextRound(currentItem: GameData, currentRound: Int, totalRounds: Int, hintsCount: Int, scores: Int)
    
    func onHintConsumed(hintsCount: Int)
    func onOutOfHints()
    
    func onHeartsChanged(count: Int)
    func onGuessedWordUpdated(callbackString: String)
}


class Game {
    private var eventListener: GameStateEventListener
    private var randomOrdering: Bool
    private var mode: GameMode
    private var scores: Int
    private var heartsCount: Int
    private lazy var currentItem: GameData = GameData(word: "", imageName: "")
    private var currentItemIndex: Int
    private var typedCharacters: [Character]
    private var continuousSuccessCount: Int
    private var continousFailureCount: Int
    private var hintedCount: Int
    private var data: [GameData]
    
    
    init(eventListener: GameStateEventListener, data: [GameData], gameMode: GameMode = GameMode.Easy, randomOrdering: Bool = false) {
        self.randomOrdering = randomOrdering
        self.eventListener = eventListener
        self.data = data
        
        mode = gameMode
        typedCharacters = []
        currentItemIndex = -1
        heartsCount = mode == GameMode.Easy ? 10 : 5
        continuousSuccessCount = -1
        continousFailureCount = -1
        hintedCount = 0
        scores = 0
        currentItem = nextItem
        
        
        eventListener.onNewGame(currentItem: currentItem, totalRounds: data.count + currentItemIndex, hintsCount: hintLimit, heartsCount: heartsCount, scores: scores)
    }
    
    
    
    
    // whether the wordsList contains any word.
    var getScores: Int {
        return scores
    }
    
    var isOutOfWords: Bool {
        get {
            return currentItem.word == ""
        }
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
            heartsCount -= 1
            eventListener.onHeartsChanged(count: heartsCount)
            
            
            // if after the predicting above was wrong & no more hearts
            if (heartsCount == 0) {
                eventListener.onOutOfHearts()
            }
            else {
                continuousSuccessCount = -1
                continousFailureCount += 1
                
                if (mode == GameMode.Hard) {
                    scores -= continousFailureCount * 10
                    scores -= 10
                }
            }
        }
        else
        {  //  predicted success
            returnValue = true
            typedCharacters.append(guessedChar)
            scores += 10    //  bonus
            
            continuousSuccessCount += 1
            continousFailureCount = -1
            scores += continuousSuccessCount * 10
        }
        
        
        eventListener.onScoresUpdated(scores: scores)
        eventListener.onGuessedWordUpdated(callbackString: currentHiddenWord)

        
        print(currentItem, currentHiddenWord)
        if (isEndOfRound) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: nextRound)
        }
        
        
        return returnValue
    }
    
    func nextRound() {
        //  get the next item
        currentItem = nextItem
        
        
        if (isOutOfWords) {  //  there is no more words in the list
            eventListener.onOutOfWords()
            return;
        }

        
        scores += mode == GameMode.Easy ? 50 : 100
        typedCharacters = []
        continuousSuccessCount = -1
        continousFailureCount = -1
        hintedCount = 0
        
        eventListener.onNextRound(currentItem: currentItem, currentRound: currentItemIndex + 1, totalRounds: data.count + currentItemIndex + 1, hintsCount: hintLimit, scores: scores)
    }
    
    func hint(guessedWord: String) {
        while true {
            let randomNumber = Int.random(in: 0..<guessedWord.count)
            let guessedCharacter = Array(guessedWord)[randomNumber]
            
            // if at the index guessedWord[randomNumber] is a hypen (not yet guessed)
            if (guessedCharacter == " ") {
                hintedCount += 1
                typedCharacters += "\(Array(currentItem.word)[randomNumber])"
                
                
                //  minusing the score if hinted in the Hard mode
                if (mode == GameMode.Hard) {
                    scores -= 20
                    eventListener.onScoresUpdated(scores: scores)
                }
                
                
                //  hinting limitation reached
                if (hintedCount == hintLimit) {
                    eventListener.onOutOfHints()
                }
                
                
                //  update the UI
                eventListener.onHintConsumed(hintsCount: hintLimit - hintedCount)
                eventListener.onGuessedWordUpdated(callbackString: currentHiddenWord)
                
                
                //  check if the user has just filled all the characters correctly
                if (isEndOfRound) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: nextRound)
                }
                
                return   //  return when catched a character
            }
        }
    }
    
    
}
