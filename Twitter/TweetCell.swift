//
//  TweetCell.swift
//  Twitter
//
//  Created by Shuhui Qu on 4/27/15.
//  Copyright (c) 2015 Shuhui Qu. All rights reserved.
//

import UIKit

class TweetCell: UITableViewCell {
    @IBOutlet weak var profileThumbView: UIImageView!
    @IBOutlet weak var tweetHeadLabel: UILabel!
    @IBOutlet weak var tweetHeadIcon: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var tweetLabel: UILabel!
    @IBOutlet weak var retweetCountLabel: UILabel!
    @IBOutlet weak var favouriteCountLabel: UILabel!
    @IBOutlet weak var replyButton: UIButton!
    @IBOutlet weak var retweetButton: UIButton!
    @IBOutlet weak var favouriteButton: UIButton!
    
    
    var tweet: Tweet!
    var index = -1
//    var storyBoard = UIStoryboard(name: "Main", bundle: nil)

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        var url = tweet.user!.profileImageUrl! as String
        profileThumbView.setImageWithURL(NSURL(string: url))
        profileThumbView.layer.cornerRadius = 5;
        profileThumbView.clipsToBounds = true
        nameLabel.text = tweet.user!.name!
        usernameLabel.text = "@\(tweet.user!.screenname!)"
        timeLabel.text = tweet.countDownTime
        tweetLabel.text = tweet.text!
        if(tweet.retweetCount > 0){
            retweetCountLabel.text = "\(tweet.retweetCount!)"
        }else{
            retweetCountLabel.text = " "
        }
        if(tweet.favouriteCount > 0){
            favouriteCountLabel.text = "\(tweet.favouriteCount!)"
        }else{
            favouriteCountLabel.text = " "
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
            self.tweetHeadLabel.text = "\(retweetedBy.name!) retweeted"
//            self.tweetHeadLabel.hidden = false
            self.tweetHeadIcon.hidden = false
            
            
        } else {
            // Fix this to change the height to 0 by changing the constraint
            self.tweetHeadLabel.text = " "
//            self.tweetHeadLabel.hidden = true
            self.tweetHeadIcon.hidden = true
            
        }
        replyButton.tag = index
        retweetButton.tag = index
        favouriteButton.tag = index
    }
//    @IBAction func onReply(sender: UIButton) {
//        var vc = storyBoard.instantiateViewControllerWithIdentifier("PostController") as? PostTweetViewController
//        vc!.user = User.currentUser
//        vc!.replyTo = self.tweet;
//        println(self.tweet.text)
//        var nc = PostTweetNavigationController(rootViewController: vc!)
//        println("\(index)")
//        window?.rootViewController = nc
//    }
//    
//    @IBAction func onRetweet(sender: AnyObject) {
//    }
//    
//    @IBAction func onFavourite(sender: AnyObject) {
//    }
    
}
