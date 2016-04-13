//
//  AuthViewController.swift
//  TweetTrending
//
//  Created by Pranav Kotecha on 4/12/16.
//  Copyright © 2016 Pranav Kotecha. All rights reserved.
//

import UIKit
import Accounts
import Social
import SwifteriOS

class AuthViewController: UIViewController {
    
    var swifter: Swifter
    
    // Default to using the iOS account framework for handling twitter auth
    let useACAccount = false
    
    required init?(coder aDecoder: NSCoder) {
        self.swifter = Swifter(consumerKey: "RErEmzj7ijDkJr60ayE2gjSHT", consumerSecret: "SbS0CHk11oJdALARa7NDik0nty4pXvAxdt7aj0R5y1gNzWaNEx")
        super.init(coder: aDecoder)!
    }

    @IBAction func doTwitterLogin(sender: AnyObject) {
        let failureHandler: ((NSError) -> Void) = { error in
            
            self.alertWithTitle("Error", message: error.localizedDescription)
        }
        
        if useACAccount {
            let accountStore = ACAccountStore()
            let accountType = accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
            
            // Prompt the user for permission to their twitter account stored in the phone's settings
            accountStore.requestAccessToAccountsWithType(accountType, options: nil) { granted, error in
                
                if granted {
                    let twitterAccounts = accountStore.accountsWithAccountType(accountType)
                    if twitterAccounts?.count == 0 {
                        self.alertWithTitle("Error", message: "There are no Twitter accounts configured. You can add or create a Twitter account in Settings.")
                    } else {
                        let twitterAccount = twitterAccounts[0] as! ACAccount
                        self.swifter = Swifter(account: twitterAccount)
                        self.fetchTwitterHomeStream()
                    }
                } else {
                    self.alertWithTitle("Error", message: error.localizedDescription)
                }
            }
        } else {
            let url = NSURL(string: "swifter://success")!
            swifter.authorizeWithCallbackURL(url, presentFromViewController: self, success: { accessToken, response in
                print(accessToken)
                print(response)
                self.fetchTwitterHomeStream()
                }, failure: failureHandler)
        }
    }
    
    func fetchTwitterHomeStream() {
        let failureHandler: ((NSError) -> Void) = { error in
            self.alertWithTitle("Error", message: error.localizedDescription)
        }
        
        self.swifter.getStatusesHomeTimelineWithCount(20, success: { statuses in
            
            // Successfully fetched timeline, so lets create and push the table view
            let tweetsViewController = self.storyboard!.instantiateViewControllerWithIdentifier("RecentTweetsController") as! RecentTweetsController
            guard let tweets = statuses else { return }
            tweetsViewController.tweets = tweets
            self.navigationController?.pushViewController(tweetsViewController, animated: true)
            //                self.presentViewController(tweetsViewController, animated: true, completion: nil)
            
            }, failure: failureHandler)
        
    }
    
    func alertWithTitle(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
//    
//    @available(iOS 9.0, *)
//    func safariViewControllerDidFinish(controller: SFSafariViewController) {
//        controller.dismissViewControllerAnimated(true, completion: nil)
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

