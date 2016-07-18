//
//  MoviesViewController.swift
//  flicks
//
//  Created by Binwei Yang on 7/15/16.
//  Copyright © 2016 Binwei Yang. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var moviesTableView: UITableView!
    
    @IBOutlet weak var networkErrorLabel: UILabel!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var movieResults: [NSDictionary]! = [NSDictionary]()
    
    var endPoint: String!
    
    var searchActive: Bool = false
    var filtered: [NSDictionary] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.moviesTableView.dataSource = self
        self.moviesTableView.delegate = self
        self.searchBar.delegate = self
        self.searchBar.showsCancelButton = true
        
        self.networkErrorLabel.hidden = true
        self.loadDataFromMoviesDatabase {
            print("Initial data load completed with \(self.movieResults!.count) movies")
        }
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), forControlEvents: UIControlEvents.ValueChanged)
        moviesTableView.insertSubview(refreshControl, atIndex: 0)
    }
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        loadDataFromMoviesDatabase {
            refreshControl.endRefreshing()
            print("Refreshing completed with \(self.movieResults!.count) movies")
        }
    }
    
    func loadDataFromMoviesDatabase(completionHandler: () -> Void) {
        let clientId = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string:"https://api.themoviedb.org/3/movie/\(endPoint)?api_key=\(clientId)")
        let request = NSURLRequest(URL: url!)
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
                                                                      completionHandler:
            { (dataOrNil, response, error) in
                MBProgressHUD.hideHUDForView(self.view, animated: true)
                
                if let data = dataOrNil {
                    self.networkErrorLabel.hidden = true
                    
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                        // NSLog("response: \(responseDictionary["results"])")
                        self.movieResults = responseDictionary["results"] as! [NSDictionary]
                        
                        self.moviesTableView.reloadData()
                    }
                }
                else {
                    NSLog("Error: \(error)")
                    self.networkErrorLabel.hidden = false
                }
                
                completionHandler()
        });
        task.resume()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (searchActive) {
            return filtered.count
        }
        else {
            return movieResults.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = moviesTableView.dequeueReusableCellWithIdentifier("Movie Cell", forIndexPath: indexPath) as! MovieViewCell
        
        let movie = movieAtRow(indexPath)
        let title = movie["original_title"] as! String
        let overview = movie["overview"] as! String
        
        cell.titleLabel.text = title
        cell.overviewLabel.text = overview
        cell.overviewLabel.sizeToFit()
        
        if let posterPath = movie["poster_path"] as? String {
            loadImageWithFadeIn(cell.posterImage, posterPath: posterPath)
        }
        
        return cell
    }
    
    func movieAtRow(indexPath: NSIndexPath) -> NSDictionary {
        if (searchActive) {
            return filtered[indexPath.row]
        }
        else {
            return movieResults[indexPath.row]
        }
    }
    
    func loadImageWithFadeIn(imageView: UIImageView, posterPath: String) {
        let imageRequest = NSURLRequest(URL: NSURL(string: "https://image.tmdb.org/t/p/w342" + posterPath)!)
        
        imageView.setImageWithURLRequest(
            imageRequest,
            placeholderImage: nil,
            success: { (imageRequest, imageResponse, image) -> Void in
                
                // imageResponse will be nil if the image is cached
                if (imageResponse != nil) {
                    // print("Image was NOT cached, fade in image for \(posterPath)")
                    imageView.alpha = 0.0
                    imageView.image = image
                    UIView.animateWithDuration(0.3, animations: { () -> Void in
                        imageView.alpha = 1.0
                    })
                } else {
                    // print("Image was cached so just update the image for \(posterPath)")
                    imageView.image = image
                }
            },
            failure: { (imageRequest, imageResponse, error) -> Void in
                // do something for the failure condition
                imageView.image = nil
        })
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.moviesTableView.deselectRowAtIndexPath(indexPath, animated:true)
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.searchActive = false
        let editing = self.view.endEditing(true)
        NSLog("searchBarCancelButtonClicked: endEditing = \(editing)")
        self.moviesTableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        filtered = movieResults.filter({ (movie) -> Bool in
            let range = movie["original_title"]!.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch)
            return range.location != NSNotFound
        })
        NSLog("Found \(filtered.count) movies that match \(searchText)")
        
        if (filtered.count == 0){
            self.searchActive = false;
        } else {
            self.searchActive = true;
        }
        self.moviesTableView.reloadData()
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        let vc = segue.destinationViewController as! MovieDetailViewController
        let cell = sender as! MovieViewCell
        let indexPath = moviesTableView.indexPathForCell(cell)
        
        vc.movie = movieAtRow(indexPath!)
    }
}
