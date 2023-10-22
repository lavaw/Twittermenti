//
//  ViewController.swift
//  Twittermenti
//
//  Created by Angela Yu on 17/07/2019.
//  Copyright © 2019 London App Brewery. All rights reserved.
//

import UIKit
import Swifter
import CoreML
import SwiftyJSON

class ViewController: UIViewController {
    
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var sentimentLabel: UILabel!
    
    let tweetCount = 100
    
    let sentimetClassifier = Santiment_Classificator()
    
    let swifter = Swifter(consumerKey: "your API key", consumerSecret: "your secret key")
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
    }
    
    @IBAction func predictPressed(_ sender: Any) {
       fetchTweets()
        
    }
    
    func fetchTweets() {
        if let searchText = textField.text {
            swifter.searchTweet(using: searchText, lang: "en", count: tweetCount, tweetMode: .extended, success:  { (results, metadata) in
                
                var tweets = [Santiment_ClassificatorInput]()
                
                for i in 0..<self.tweetCount {
                    if let tweet = results[i]["full_text"].string {
                        let tweetForClassification = Santiment_ClassificatorInput(text: tweet)
                        tweets.append(tweetForClassification)
                    }
                }
                self.makePrediction(with: tweets)
            }) { (error) in
                print("There was an error with Twitter API request, \(error)")
            }
        }
    }
    
    func makePrediction(with tweets: [Santiment_ClassificatorInput]) {
        do {
            
            let predcitions = try self.sentimetClassifier.predictions(inputs: tweets)
            
            var sentimentScore = 0
            
            for pred in predcitions {
                let sentiment = pred.label
                
                if sentiment == "Pos" {
                    sentimentScore += 1
                } else if sentiment == "Neg" {
                    sentimentScore -= 1
                }
            }
            updateUI(with: sentimentScore)
      
        } catch {
            print(error)
        }
    }
    
    func updateUI(with sentimentScore: Int) {
        
        if sentimentScore > 20 {
                    self.sentimentLabel.text = "😍"
                } else if sentimentScore > 10 {
                    self.sentimentLabel.text = "😀"
                } else if sentimentScore > 0 {
                    self.sentimentLabel.text = "🙂"
                } else if sentimentScore == 0 {
                    self.sentimentLabel.text = "😐"
                } else if sentimentScore > -10 {
                    self.sentimentLabel.text = "😕"
                } else if sentimentScore > -20 {
                    self.sentimentLabel.text = "😡"
                } else {
                    self.sentimentLabel.text = "🤮"
                }
    }
    
}
