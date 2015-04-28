//
//  TwitterClient.swift
//  Twitter
//
//  Created by Shuhui Qu on 4/25/15.
//  Copyright (c) 2015 Shuhui Qu. All rights reserved.
//

import UIKit


let twitterConsumerKey = "VB8dO5xn2C3sfbiAdyJIFnXRD"
let twitterConsumerSecret = "NmwO4xLZBo8C3kOF7eiV3SxylJmGmQapnQjUHcA6P8nEcwKTke"
let twitterBaseURL = NSURL(string: "https://api.twitter.com")


class TwitterClient: BDBOAuth1RequestOperationManager {
   
    var loginCompletion: ((user: User?, error: NSError?) -> ())?
    
    class var sharedInstance: TwitterClient {
        struct Static{
            static let instance = TwitterClient(baseURL: twitterBaseURL, consumerKey: twitterConsumerKey, consumerSecret:twitterConsumerSecret)

        }
        
        return Static.instance
    }
    
    func postTweet(text: String, replyTo: String?, completion: (tweet: Tweet?, error: NSError?) -> ()){
        let params = ["status":text] as NSMutableDictionary
        if let tweetId = replyTo{
            println(tweetId)
            params["in_reply_to_status_id"] = tweetId
        }
        TwitterClient.sharedInstance.POST("1.1/statuses/update.json", parameters: params, success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
//                println("Success while tweeting: \(response)")
                var tweet = Tweet(dictionary: response as! NSDictionary)
                completion(tweet: tweet, error: nil)
            }) { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                println("post tweet error")
                completion(tweet: nil, error: error)
        }
    }
    
    func retweet(id: String, params: NSDictionary?, completion: (tweet: Tweet?, error: NSError?) ->()){
        TwitterClient.sharedInstance.POST("1.1/statuses/retweet/\(id).json", parameters: params, success: { (operation:AFHTTPRequestOperation!, response: AnyObject!) -> Void in
                var tweet = Tweet(dictionary: response as! NSDictionary)
                completion(tweet: tweet, error: nil)
            }) { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                println("retweet error\(error)")
                completion(tweet: nil, error: error)

        }
    }
    
    func favourite(id: String, params: NSDictionary?, completion: (tweet: Tweet?, error: NSError?) -> ()){
        TwitterClient.sharedInstance.POST("1.1/favorites/create.json?id=\(id)", parameters: nil,
            success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
                println("fav:\(response)")
                var tweet = Tweet(dictionary: response as! NSDictionary)
                completion(tweet: tweet, error: nil)
            }, failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                println("favorite error")
                completion(tweet: nil, error: error)
            }
        )
    }
    
    func unfavourite(id: String, params: NSDictionary?, completion: (tweet: Tweet?, error: NSError?) -> ()){
        TwitterClient.sharedInstance.POST("1.1/favorites/destroy.json?id=\(id)", parameters: nil,
            success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
                println("unfav:\(response)")
                var tweet = Tweet(dictionary: response as! NSDictionary)
                completion(tweet: tweet, error: nil)
            }, failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                println("unfavorite error")
                completion(tweet: nil, error: error)
            }
        )
    }
    
    func homeTimelineWithParams(params: NSDictionary?, completion:(tweets: [Tweet]?, error: NSError?) -> ()){
        TwitterClient.sharedInstance.GET("1.1/statuses/home_timeline.json", parameters: params, success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
//            println("home_timeline:\(response)")
            var tweets = Tweet.tweetsWithArray(response as! [NSDictionary])
//            for tweet in tweets{
//              println("text:\(tweet.text), created: \(tweet.createAt)")
//            }
            completion(tweets: tweets, error: nil)
        }, failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
            println("error getting hometimeline")
            completion(tweets: nil, error: error)
        })
    }
    
    // is () means void in?
    func loginWithCompletion(completion:(user: User?, error: NSError?) -> ()){
        loginCompletion = completion
        
        // Fetch request token & redirect to authorization page
        TwitterClient.sharedInstance.requestSerializer.removeAccessToken()
        TwitterClient.sharedInstance.fetchRequestTokenWithPath("oauth/request_token", method: "GET", callbackURL: NSURL(string: "cptwitterdemo://oauth"), scope: nil, success: { (requestToken: BDBOAuth1Credential!) -> Void in
            println("got the request token")
            var authURL = NSURL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(requestToken.token)")
            UIApplication.sharedApplication().openURL(authURL!)
            
            
            }){ (error:NSError!) -> Void in
                println("Failed to get request token")
                self.loginCompletion?(user: nil, error: error)
        }
    }
    
    func openURL(url: NSURL){
        fetchAccessTokenWithPath("oauth/access_token", method: "POST", requestToken: BDBOAuth1Credential(queryString: url.query), success: { (accessToken: BDBOAuth1Credential!) -> Void in
            println("Got the access token")
            TwitterClient.sharedInstance.requestSerializer.saveAccessToken(accessToken)
            
            TwitterClient.sharedInstance.GET("1.1/account/verify_credentials.json", parameters: nil, success: { (operation:AFHTTPRequestOperation!, response:AnyObject!) -> Void in
                //                    println("user:\(response)")
                var user = User(dictionary: response as! NSDictionary)
                
                // don't understand here, there is no instance call currentUser
                // Got it now
                User.currentUser = user
                
                println("user: \(user.name)")
                self.loginCompletion?(user: user, error: nil)
            }, failure: { (operation:AFHTTPRequestOperation!, error: NSError!) -> Void in
                println("error getting current user")
                self.loginCompletion?(user: nil, error: error)
            })
        }) { (error:NSError!) -> Void in
            println("failed tot receice the access token")
            self.loginCompletion?(user: nil, error: error)
        }
    }
}
