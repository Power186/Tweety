//
//  HomeTableViewController.swift
//  Twitter
//
//  Created by Scott on 10/10/20.
//  Copyright © 2020 Dan. All rights reserved.
//

import UIKit

final class HomeTableViewController: UITableViewController {
    
    // MARK: - Properties
    
    var tweetArray = [NSDictionary]()
    var numberOfTweets: Int!
    
    let tweetRefreshControl = UIRefreshControl()

    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // refresh control
        tweetRefreshControl.addTarget(self, action: #selector(loadTweets), for: .valueChanged)
        tableView.refreshControl = tweetRefreshControl
        
        self.tableView.rowHeight = UITableView.automaticDimension
        self .tableView.estimatedRowHeight = 150
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // fetch tweets and load them to array
        self.loadTweets()
    }
    
    // MARK: - Functions
    @objc func loadTweets() {
        // API url and params for tweets from user timeline
        let myURL = "https://api.twitter.com/1.1/statuses/home_timeline.json"
        numberOfTweets = 10
        let myParams = ["count": numberOfTweets]
        
        // Get tweets
        TwitterAPICaller.client?.getDictionariesRequest(url: myURL, parameters: myParams as [String : Any], success:
            { (tweets: [NSDictionary]) in
                
                // remove tweets from array before adding for a fresh list of tweets each time
                self.tweetArray.removeAll()
                    
                // add tweets to the array
                for tweet in tweets {
                    self.tweetArray.append(tweet)
                }
                
                // reload tableView with data
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
                // disable refresh control after refreshing
                self.tweetRefreshControl.endRefreshing()
                
            }, failure: { (Error) in
                //fatalError("Could not retrieve tweets")
                print(Error.localizedDescription)
            })
    }
    
    // MARK: - Helper Functions
    
    // infinite scrolling
    func loadMoreTweets() {
        // API url to fetch timelines
        let myURL = "https://api.twitter.com/1.1/statuses/home_timeline.json"
        // number of tests to fetch
        numberOfTweets = numberOfTweets + 10
        let myParams = ["count": numberOfTweets]
    
        TwitterAPICaller.client?.getDictionariesRequest(url: myURL, parameters: myParams as [String : Any], success:
            { (tweets: [NSDictionary]) in
                
                // remove tweets from array before adding for a fresh list of tweets each time
                self.tweetArray.removeAll()
                    
                // add tweets to the array
                for tweet in tweets {
                    self.tweetArray.append(tweet)
                }
                
                // reload tableView with data
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
                // disable refresh control after refreshing
                self.tweetRefreshControl.endRefreshing()
                
            }, failure: { (Error) in
                fatalError("Could not retrieve tweets")
            })
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        // refresh when scroll to bottom of view
        if indexPath.row + 1 == tweetArray.count {
            DispatchQueue.main.async {
                self.loadMoreTweets()
            }
        }
        
    }
    
    // MARK: - Actions
    
    @IBAction func onLogout(_ sender: UIBarButtonItem) {
        // user logout
        TwitterAPICaller.client?.logout()
        
        // dismiss the view after logout
        self.dismiss(animated: true, completion: nil)
    }
    

    // MARK: - Table View Data Source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tweetArray.count
    }

    // MARK: - Cell
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tweetCell", for: indexPath) as! TweetCell
        
        let user = tweetArray[indexPath.row]["user"] as! NSDictionary
        let tweet = tweetArray[indexPath.row]["text"] as? String
        
        cell.userNameLabel.text = user["name"] as? String
        cell.tweetContentLabel.text = tweet
        
        let imageURL = URL(string: (user["profile_image_url_https"] as? String)!)
        let data = try? Data(contentsOf: imageURL!)
        
        if let imageData = data {
            cell.profileImage.image = UIImage(data: imageData)
        }
        
        cell.setFavorite(tweetArray[indexPath.row]["favorited"] as! Bool)
        cell.tweetId = tweetArray[indexPath.row]["id"] as! Int
        cell.setRetweeted(tweetArray[indexPath.row]["retweeted"] as! Bool)
        
        
        return cell
    }

}
