//
//  TweetsViewController.swift
//  Twitter
//
//  Created by Shuhui Qu on 4/26/15.
//  Copyright (c) 2015 Shuhui Qu. All rights reserved.
//

import UIKit

class TweetsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var tweets: [Tweet] = [Tweet]()
    @IBOutlet weak var tweetTableView: UITableView!
    @IBOutlet weak var loadStatus: UIActivityIndicatorView!
    var offset = 1
    
    var storyBoard = UIStoryboard(name: "Main", bundle: nil)
    var window: UIWindow?
    var isRefreshing = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
//        self.automaticallyAdjustsScrollViewInsets = false;
        tweetTableView.rowHeight = UITableViewAutomaticDimension
        tweetTableView.estimatedRowHeight = 90.0;
        // Do any additional setup after loading the view.
        TwitterClient.sharedInstance.homeTimelineWithParams(nil, completion: { (tweets, error) -> () in
            self.tweets = tweets!
            self.tweetTableView.reloadData()
        })
        tweetTableView.delegate = self
        tweetTableView.dataSource = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "newTweet:", name: "newTweetNotification", object: nil)
    }
    func newTweet(notification: NSNotification){
        var tweet = notification.object as? Tweet
        tweets.insert(tweet!, atIndex: 0)
        self.tweetTableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func OnSignOut(sender: UIBarButtonItem) {
        User.currentUser?.logout()
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("TCell") as! TweetCell
        cell.tweet = tweets[indexPath.row]
        cell.index = indexPath.row
        
        if (tweets.count - indexPath.row == 1) {
            loadStatus.hidden = false
            dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), {
                self.loadMoreTweets()
            })
        }
        
        return cell
    }
    
    func loadMoreTweets(){
        self.isRefreshing = true
        TwitterClient.sharedInstance.homeTimelineWithParams(nil, completion: { (newTweets, error) -> () in
            self.tweets += newTweets!
            self.tweetTableView.reloadData()
            self.loadStatus.hidden = true
            self.isRefreshing = false
//            for tw in newTweets!{
//                println("text:\(tw.text), created: \(tw.createAt)")
//            }
        })
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "newTweet"{
            let filtersNC = segue.destinationViewController as! UINavigationController
            let filtersVC = filtersNC.viewControllers[0] as! PostTweetViewController
            filtersVC.user = User.currentUser
        }else{
            var tweetDetailViewController = segue.destinationViewController as! DetailTweetViewController
            //sender is cell
            var cell = sender as! TweetCell
            var indexPath = tweetTableView.indexPathForCell(cell)!
            tweetDetailViewController.tweet = tweets[indexPath.row]
        }
    }
    /*
    // MARK: - Navigation

  
    */

    
    @IBAction func onReply(sender: UIButton) {
        var index = sender.tag
        var vc = storyBoard.instantiateViewControllerWithIdentifier("PostController") as? PostTweetViewController
        vc!.user = User.currentUser
        vc!.replyTo = self.tweets[index];
        var nc = PostTweetNavigationController(rootViewController: vc!)
        println("\(index)")
        self.presentViewController(nc, animated: true, completion: nil)
    }
    
    @IBAction func onRetweet(sender: UIButton) {
        var index = sender.tag
        var tweet = self.tweets[index]
        TwitterClient.sharedInstance.retweet(tweet.id!, params: nil) { (getTweet, error) -> () in
            if( error == nil){
                // retweet
                tweet.retweeted = 1
                tweet.retweetCount! += 1
                tweet.retweetedBy = User.currentUser
                var cell = self.tweetTableView.cellForRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0)) as! TweetCell
                cell.tweet = tweet
                self.tweets[index] = tweet
                self.tweetTableView.reloadData()
            }else{
                //unretweet
                tweet.retweeted = 0
                tweet.retweetCount! -= 1
                tweet.retweetedBy = nil
                var cell = self.tweetTableView.cellForRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0)) as! TweetCell
                cell.tweet = tweet
                self.tweets[index] = tweet
                self.tweetTableView.reloadData()
            }
        }
        
    }

    @IBAction func onFavourite(sender: UIButton) {
        var index = sender.tag
        var tweet = self.tweets[index]
        if (tweet.favourited == 0){
        // not favourited
            TwitterClient.sharedInstance.favourite(tweet.id!, params: nil, completion: { (getTweet, error) -> () in
                if (error == nil){
                    tweet.favourited = 1
                    tweet.favouriteCount! += 1
                }
            })
        }else{
            TwitterClient.sharedInstance.unfavourite(tweet.id!, params: nil, completion: { (getTweet, error) -> () in
                if (error == nil){
                    tweet.favourited = 0
                    tweet.favouriteCount! -= 1
                }
            })
        }
        var cell = self.tweetTableView.cellForRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0)) as! TweetCell
        cell.tweet = tweet
        self.tweets[index] = tweet
        self.tweetTableView.reloadData()
    }

}
