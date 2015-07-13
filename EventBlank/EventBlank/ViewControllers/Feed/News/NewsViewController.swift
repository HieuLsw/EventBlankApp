//
//  ViewController.swift
//  Twitter_test
//
//  Created by Marin Todorov on 6/18/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

import UIKit
import Social
import Accounts
import SQLite
import XLPagerTabStrip

class NewsViewController: TweetListViewController {
    
    let newsCtr = NewsController()
    let userCtr = UserController()
    
    // MARK: table view methods
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCellWithIdentifier("TweetCell") as! TweetCell
        let row = indexPath.row

        let tweet = self.tweets[indexPath.row]
        
        let usersTable = database[UserConfig.tableName]
        let user = usersTable.filter(User.idColumn == tweet[Chat.idUser]).first

        cell.message.text = tweet[News.news]
        cell.timeLabel.text = NSDate(timeIntervalSince1970: Double(tweet[News.created])).relativeTimeToString()
        cell.message.selectedRange = NSRange(location: 0, length: 0)

        if let attachmentUrlString = tweet[News.imageUrl], let attachmentUrl = NSURL(string: attachmentUrlString) {
            cell.attachmentImage.hnk_setImageFromURL(attachmentUrl)
            cell.didTapAttachment = {
                let webVC = self.storyboard?.instantiateViewControllerWithIdentifier("WebViewController") as! WebViewController
                webVC.initialURL = attachmentUrl
                self.navigationController!.pushViewController(webVC, animated: true)
            }
            cell.attachmentHeight.constant = 148.0
        }

        if let user = user {
            cell.nameLabel.text = user[User.name]
            if let imageUrlString = user[User.photoUrl], let imageUrl = NSURL(string: imageUrlString) {
                cell.userImage.hnk_setImageFromURL(imageUrl, placeholder: UIImage(named: "feed-item"))
            }
        }

        return cell
    }
    
    // MARK: load/fetch data
    
    override func loadTweets() {
        //fetch latest tweets from db
        tweets = self.newsCtr.allNews()
        
        //reload table
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.reloadData()
            
            if self.tweets.count == 0 {
                self.tableView.addSubview(MessageView(text: "No tweets found at this time, try again later"))
            } else {
                MessageView.removeViewFrom(self.tableView)
            }
        })
    }

    override func fetchTweets() {
        twitter.authorize({success in
            MessageView.removeViewFrom(self.tableView)
            
            if success {
                self.twitter.getTimeLineForUsername(Event.event[Event.twitterAdmin]!, completion: {tweetList, user in
                    if let user = user where tweetList.count > 0 {
                        self.userCtr.persistUsers([user])
                        self.newsCtr.persistNews(tweetList)
                        self.loadTweets()
                    }
                })
            } else {
                delay(seconds: 0.5, {
                    self.tableView.addSubview(MessageView(text: "You don't have Twitter accounts set up. Open Preferences app, select Twitter and connect an account. \n\nThen pull this view down to refresh the feed."))
                })
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                //hide the spinner
                self.refreshView.endRefreshing()
            })
        })
    }
}
