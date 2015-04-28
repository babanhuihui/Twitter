//
//  PostTweetViewController.swift
//  Twitter
//
//  Created by Shuhui Qu on 4/28/15.
//  Copyright (c) 2015 Shuhui Qu. All rights reserved.
//

import UIKit

class PostTweetViewController: UIViewController,UITextViewDelegate {
    
    var user: User!
    var replyTo: Tweet?
    @IBOutlet weak var profileThumbView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var textField: UITextView!
    
    @IBOutlet weak var charLeftLabel: UILabel!
    
    @IBOutlet weak var tweetButton: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.delegate = self
//        var tweetId:String? = nil
//        if let replyTweet = replyTo{
//            tweetId = replyTweet.id
//        }
//        println(tweetId)
        // Do any additional setup after loading the view.
        var initialText = ""
        if let tweet = replyTo{
            self.navigationItem.title = "Reply"
            initialText += "@\(tweet.user!.screenname!) "
            var mentions: [NSDictionary] = tweet.entities!["user_mentions"] as! [NSDictionary]
            for mention in mentions {
                var screenName = mention["screen_name"] as! String
                initialText += "@\(screenName) "
            }
            textField.text = initialText
        }
        
        var length = count(textField.text)
        charLeftLabel.text = "\(140 - length)"
        tweetButton.enabled = true
        
        if (length == 0) {
            tweetButton.enabled = false
        } else {
            tweetButton.enabled = true
        }
        
        if (length > 140) {
            charLeftLabel.text = "Too Long!"
            tweetButton.enabled = false
            charLeftLabel.textColor = UIColor.redColor()
            charLeftLabel.font.fontWithSize(30)
        } else {
            charLeftLabel.text = "\(140 - length)"
            tweetButton.enabled = true
            charLeftLabel.textColor = UIColor(white: 0.5, alpha: 1.0)
            charLeftLabel.font.fontWithSize(12)
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func postTweet(sender: AnyObject) {
        var text = textField.text
        var tweetId:String? = nil
        if let replyTweet = replyTo{
            tweetId = replyTweet.id
        }
        println(tweetId)
        TwitterClient.sharedInstance.postTweet(text, replyTo: tweetId, completion: { (tweet, error) -> () in
            if (error != nil){
                println("Error tweeting\(error)")
            }else{
                NSNotificationCenter.defaultCenter().postNotificationName("newTweetNotification", object: tweet)
            }
        })

        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func cancelPost(sender: AnyObject) {
         self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLayoutSubviews(){
        var url = user!.profileImageUrl! as String
        profileThumbView.setImageWithURL(NSURL(string: url))
        profileThumbView.layer.cornerRadius = 5;
        profileThumbView.clipsToBounds = true
        nameLabel.text = user!.name!
        usernameLabel.text = "@\(user!.screenname!)"
        
        
    }
    
    
    func textViewDidChange(textView: UITextView) {
        var text = textView.text!
        var length = count(text)
        
        if (length == 0) {
            tweetButton.enabled = false
        } else {
            tweetButton.enabled = true
        }
        
        if (length > 140) {
            charLeftLabel.text = "Too Long!"
            tweetButton.enabled = false
            charLeftLabel.textColor = UIColor.redColor()
            charLeftLabel.font.fontWithSize(30)
        } else {
            charLeftLabel.text = "\(140 - length)"
            tweetButton.enabled = true
            charLeftLabel.textColor = UIColor(white: 0.5, alpha: 1.0)
            charLeftLabel.font.fontWithSize(12)
        }
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
