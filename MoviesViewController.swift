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
    var endpoint: String!
    
    


    
    
    override func viewDidLoad() {

        super.viewDidLoad()
        loadDataFromNetwork()
        tableView.dataSource = self
        tableView.delegate = self
        
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        
        ///
        self.searchController.hidesNavigationBarDuringPresentation = false

        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.sizeToFit()
        self.navigationItem.titleView = searchController.searchBar

        //tableView.tableHeaderView = searchController.searchBar
        self.definesPresentationContext = true

       
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refreshControlAction:", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
        
        
        

        if let navigationBar = navigationController?.navigationBar {
            navigationBar.tintColor = UIColor(red: 0.6, green: 1.0, blue: 0.5, alpha: 0.8)
            navigationBar.barStyle = UIBarStyle.Black

            let shadow = NSShadow()
            shadow.shadowColor = UIColor.grayColor().colorWithAlphaComponent(0.5)
            shadow.shadowOffset = CGSizeMake(2, 2);
            shadow.shadowBlurRadius = 4;
            navigationBar.titleTextAttributes = [
                NSFontAttributeName : UIFont.boldSystemFontOfSize(22),
                NSForegroundColorAttributeName : UIColor(red: 0.5, green: 0.15, blue: 0.15, alpha: 0.8),
                NSShadowAttributeName : shadow
            ]
        }
        
        
}
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        
         loadDataFromNetwork()
            refreshControl.endRefreshing()
    }
    
    func loadDataFromNetwork() {
        
        
        
        
        
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string:"https://api.themoviedb.org/3/movie/\(endpoint)?api_key=\(apiKey)")
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
                            
                            self.movies = (responseDictionary["results"] as! [NSDictionary])
                            self.filteredMovies = self.movies
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
    

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let filteredMovies = filteredMovies {
            return filteredMovies.count
        } else {
            return 0
        }
        
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        cell.selectionStyle = .None
        
        let movie = filteredMovies![indexPath.row]
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        
        cell.titleLable.text = title
        cell.overviewLabel.text = overview
        
        if let posterPath = movie["poster_path"] as? String {
            let baseUrl = "http://image.tmdb.org/t/p/w500/"
            let imageRequest = NSURLRequest(URL: NSURL(string: baseUrl + posterPath)!)

            cell.posterView.setImageWithURLRequest(
                imageRequest,
                placeholderImage: nil,
                success: { (imageRequest, imageResponse, image) -> Void in
                    
                    // imageResponse will be nil if the image is cached
                    if imageResponse != nil {
                        print("Image was NOT cached, fade in image")
                         cell.posterView.alpha = 0.0
                        cell.posterView.image = image
                        UIView.animateWithDuration(0.3, animations: { () -> Void in
                             cell.posterView.alpha = 1.0
                        })
                    } else {
                        print("Image was cached so just update the image")
                        cell.posterView.image = image
                    }
                },
                failure: { (imageRequest, imageResponse, error) -> Void in
                    // do something for the failure condition
            })
        
        
        
        
        
        
        

            }
        print(title)
        print(overview)
        return cell

}
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {

            if let searchText = searchController.searchBar.text {
                filteredMovies = searchText.isEmpty ? movies : movies!.filter({(movie: NSDictionary) -> Bool in
                return (movie["title"] as! String).rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil
            })
            tableView.reloadData()
        }
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPathForCell(cell)
        let movie = filteredMovies![indexPath!.row]
        let detailViewController = segue.destinationViewController as! DetailViewController
        detailViewController.movie = movie
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    



}