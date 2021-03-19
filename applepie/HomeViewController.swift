//
//  HomeViewController.swift
//  applepie
//
//  Created by Nguyen Anh Tuan on 3/18/21.
//  Copyright © 2021 BVU. All rights reserved.
//

import UIKit
import BEMCheckBox

class HomeViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var btnStart: UIButton!
    @IBOutlet weak var chbRandomOrdering: BEMCheckBox!
    @IBOutlet weak var pvGameMode: UIPickerView!
    @IBOutlet weak var pvGameCategory: UIPickerView!
    
    let modesList = [ "Easy", "Hard" ]
    let gameData = [
        GameCategory(categoryName: "Fruites", data: [
            GameData(word: "Orange", imageName: "orange"),
            GameData(word: "Banana", imageName: "banana"),
            GameData(word: "Kiwi", imageName: "kiwi"),
        ]),
        GameCategory(categoryName: "Cars", data: [
            GameData(word: "Ferrari", imageName: "ferrari"),
            GameData(word: "Tesla", imageName: "tesla"),
            GameData(word: "Vinfast", imageName: "vinfast"),
        ]),
        GameCategory(categoryName: "Gadgets", data: [
            GameData(word: "AirPod", imageName: "airpod"),
            GameData(word: "Mouse", imageName: "mouse"),
            GameData(word: "MacPro", imageName: "macpro"),
        ]),
    ]
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pvGameMode.delegate = self
        pvGameCategory.delegate = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let gameViewController = segue.destination as! ViewController
        gameViewController.selectedGameMode = selectedGameMode
        gameViewController.allowRandomOrdering = chbRandomOrdering.on
        gameViewController.gameData = selectedCategory.data
    }
    
    
    
    
    //  computed properties
    var selectedGameMode: GameMode {
        let pickerViewValue = modesList[pvGameMode.selectedRow(inComponent: 0)]
        return GameMode(rawValue: pickerViewValue) ?? GameMode.Easy
    }
    
    var selectedCategory: GameCategory {
        return gameData[pvGameCategory.selectedRow(inComponent: 0)]
    }
    
    
    
    
    //  overrided methods
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerView == pvGameMode ? modesList.count : gameData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerView == pvGameMode ? modesList[row] : gameData[row].categoryName
    }
    

    
    
    //  event handling
    @IBAction func btnStartTouched(_ sender: Any) {
        performSegue(withIdentifier: "GoToGame", sender: self)
    }
    
}
