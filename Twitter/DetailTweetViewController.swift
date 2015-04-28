//
//  DetailTweetViewController.swift
//  Twitter
//
//  Created by Shuhui Qu on 4/28/15.
//  Copyright (c) 2015 Shuhui Qu. All rights reserved.
//

import UIKit

class DetailTweetViewController: UIViewController {

    @IBOutlet weak var retweetIcon: UIImageView!
    @IBOutlet weak var retweetLabel: UILabel!
    
    @IBOutlet weak var profileThumbView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var tweetLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var retweetCount: UILabel!
    @IBOutlet weak var favouriteCount: UILabel!
    
    @IBOutlet weak var replyButton: UIButton!
    @IBOutlet weak var retweetButton: UIButton!
    @IBOutlet weak var favouriteButton: UIButton!
    
    
    var tweet:Tweet!
    var storyBoard = UIStoryboard(name: "Main", bundle: nil)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews(){
        var url = tweet.user!.profileImageUrl! as String
        profileThumbView.setImageWithURL(NSURL(string: url))
        profileThumbView.layer.cornerRadius = 5;
        profileThumbView.clipsToBounds = true
        nameLabel.text = tweet.user!.name!
        usernameLabel.text = "@\(tweet.user!.screenname!)"
        timeLabel.text = tweet.createdAtString
        tweetLabel.text = tweet.text!
        
        
        if(tweet.retweetCount > 0){
            retweetCount.text = "\(tweet.retweetCount!)"
        }else{
            retweetCount.text = "0"
        }
        if(tweet.favouriteCount > 0){
            favouriteCount.text = "\(tweet.favouriteCount!)"
        }else{
            favouriteCount.text = "0"
        }
        if(tweet.retweeted != 0){
            let image = UIImage(named: "retweet_on.png")! as UIImage
            retweetButton.setImage(image, forState: UIControlState.Normal)
        }else{
            let image = UIImage(named: "retweet.png")! as UIImage
            retweetButton.setImage(image, forState: UIControlState.Normal)
        }
        if(tweet.favourited != 0){
            let image = UIImage(named: "favorite_on.png")! as UIImage
            favouriteButton.setImage(image, forState: UIControlState.Normal)
        }else{
            let image = UIImage(named: "favorite.png")! as UIImage
            favouriteButton.setImage(image, forState: UIControlState.Normal)
        }
        
        if let retweetedBy = tweet.retweetedBy {
            self.retweetLabel.text = "\(retweetedBy.name!) retweeted"
            //            self.tweetHeadLabel.hidden = false
            self.retweetIcon.hidden = false
            
            
        } else {
            // Fix this to change the height to 0 by changing the constraint
            self.retweetLabel.text = " "
            //            self.tweetHeadLabel.hidden = true
            self.retweetIcon.hidden = true
            
        }

    }
    
    
    @IBAction func onReply(sender: UIButton) {
        var vc = storyBoard.instantiateViewControllerWithIdentifier("PostController") as? PostTweetViewController
        vc!.user = User.currentUser
        vc!.replyTo = self.tweet;
        var nc = PostTweetNavigationController(rootViewController: vc!)
        self.presentViewController(nc, animated: true, completion: nil)
    }
    
    
    @IBAction func onRetweet(sender: AnyObject) {
        TwitterClient.sharedInstance.retweet(tweet.id!, params: nil) { (getTweet, error) -> () in
            if( error == nil){
                // retweet
                self.tweet.retweeted = 1
                self.tweet.retweetCount! += 1
                self.tweet.retweetedBy = User.currentUser
                
                let image = UIImage(named: "retweet_on.png")! as UIImage
                self.retweetButton.setImage(image, forState: UIControlState.Normal)
//                self.setNeedsDisplay()
            }else{
                //unretweet
                self.tweet.retweeted = 0
                self.tweet.retweetCount! -= 1
                self.tweet.retweetedBy = nil

                let image = UIImage(named: "retweet.png")! as UIImage
                self.retweetButton.setImage(image, forState: UIControlState.Normal)
                
            }
        }
        self.reloadInputViews()
    }
    
    @IBAction func onFavourite(sender: UIButton) {
        if (tweet.favourited == 0){
            // not favourited
            TwitterClient.sharedInstance.favourite(tweet.id!, params: nil, completion: { (getTweet, error) -> () in
                if (error == nil){
                    self.tweet.favourited = 1
                    self.tweet.favouriteCount! += 1
                    let image = UIImage(named: "favorite_on.png")! as UIImage
                    self.favouriteButton.setImage(image, forState: UIControlState.Normal)
                }
            })
        }else{
            TwitterClient.sharedInstance.unfavourite(tweet.id!, params: nil, completion: { (getTweet, error) -> () in
                if (error == nil){
                    self.tweet.favourited = 0
                    self.tweet.favouriteCount! -= 1
                    let image = UIImage(named: "favorite.png")! as UIImage
                    self.favouriteButton.setImage(image, forState: UIControlState.Normal)
                }
            })
        }
        self.reloadInputViews()
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "replyTweet"{
            let filtersNC = segue.destinationViewController as! UINavigationController
            let filtersVC = filtersNC.viewControllers[0] as! PostTweetViewController
            filtersVC.user = User.currentUser
            filtersVC.replyTo = tweet
        }
    }
    

}
