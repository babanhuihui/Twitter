 //
//  Tweet.swift
//  Twitter
//
//  Created by Shuhui Qu on 4/26/15.
//  Copyright (c) 2015 Shuhui Qu. All rights reserved.
//

import UIKit

class Tweet: NSObject {
    var user: User?
    var text: String?
    var createdAtString: String?
    var createAt: NSDate?
    
    var favouriteCount: Int?
    var retweetCount: Int?
    var countDownTime: String?
    
    var id: String?
    var retweeted: Int?
    var favourited: Int?
    var entities: NSDictionary?
    
    var retweetedBy: User?
    
    init(dictionary: NSDictionary){
            user = User(dictionary: dictionary["user"] as! NSDictionary)
            text = dictionary["text"] as? String
            createdAtString = dictionary["created_at"] as? String
        
            var formatter = NSDateFormatter()
            formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
            createAt = formatter.dateFromString(createdAtString!)
            countDownTime = Tweet.toCountDownTime(createAt!)
        
            favouriteCount = dictionary["favorite_count"] as? Int
            retweetCount = dictionary["retweet_count"] as? Int
            id = dictionary["id_str"] as? String
            retweeted = dictionary["retweeted"] as? Int
            favourited = dictionary["favorited"] as? Int
            entities = dictionary["entities"] as? NSDictionary
    }
    
    class func tweetsWithArray(array: [NSDictionary]) -> [Tweet]{
        var tweets = [Tweet]()
        for dictionary in array{
            var tweet = Tweet(dictionary: dictionary)
            tweets.append(tweet)
            if (dictionary["retweeted_status"] != nil){
                tweet.retweetedBy = User(dictionary: dictionary["user"] as! NSDictionary)
            }
        }
        return tweets
    }
    
    class func toCountDownTime(createdAt: NSDate) -> String{
        var time = createdAt.timeIntervalSinceNow
        var timeInt =  Int(time) * -1
        var timeMins = timeInt/60 as Int
        
        if (timeMins == 0) {
            return "now"
        } else if (timeMins >= 1 && timeMins < 60) {
            return "\(timeMins)m"
        } else if (timeMins < 1440) {
            return "\(timeMins/60)h"
        } else if (timeMins >= 1440) {
            return "\(timeMins/1440)d"
        }
        return "now"
    }
 }