//
//  MoviesViewController.swift
//  Flicks
//
//  Created by Anurag Nanda on 1/18/16.
//  Copyright © 2016 Anurag Nanda. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD
class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate , UISearchResultsUpdating{

    @IBOutlet weak var tableView: UITableView!
    
    var movies: [NSDictionary]?
    var filteredMovies: [NSDictionary]!
    var searchController: UISearchController!


    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        filteredMovies = movies
        ///////////////
        loadDataFromNetwork()
        tableView.delegate = self
        self.tableView.reloadData()
        ///////////
        
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.sizeToFit()
        tableView.tableHeaderView = searchController.searchBar
        definesPresentationContext = true


        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refreshControlAction:", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)

    }
    func refreshControlAction(refreshControl: UIRefreshControl) {
        
         loadDataFromNetwork()
            refreshControl.endRefreshing()
    }
    
    func loadDataFromNetwork() {
        
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string:"https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
        let request = NSURLRequest(URL: url!)
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            NSLog("response: \(responseDictionary)")
                            
                            self.movies = responseDictionary["results"] as! [NSDictionary]
                            self.tableView.reloadData()
                    }
                }
                MBProgressHUD.hideHUDForView(self.view, animated: true)

        });
        
        task.resume()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @available(iOS 2.0, *)
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let filteredMovies = filteredMovies {
            return filteredMovies.count
        } else {
            return 0
        }
        
    }
    
    
    
    @available(iOS 2.0, *)
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        
        let movie = filteredMovies![indexPath.row]
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        
        cell.titleLable.text = title
        cell.overviewLabel.text = overview
        
        
        if let posterPath = movie["poster_path"] as? String {
            let baseUrl = "http://image.tmdb.org/t/p/w500/"
            let imageUrl = NSURL(string: baseUrl + posterPath)
            cell.posterView.setImageWithURL(imageUrl!)
        }
        

        print(title)
        print(overview)
        return cell
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
       
            if let searchText = searchController.searchBar.text {
                print("insideUpdateSearchResult")
            filteredMovies = searchText.isEmpty ? movies : movies!.filter({(movie: NSDictionary) -> Bool in
                print (movie["title"] as! String)
                return (movie["title"] as! String).rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil
            })
            
            tableView.reloadData()
        }
}
    



}