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

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var moviesTableView: UITableView!
    
    var movieResults: [NSDictionary]! = [NSDictionary]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.moviesTableView.dataSource = self
        self.moviesTableView.delegate = self
        
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
        let url = NSURL(string:"https://api.themoviedb.org/3/movie/now_playing?api_key=\(clientId)")
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
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                        // NSLog("response: \(responseDictionary["results"])")
                        self.movieResults = responseDictionary["results"] as! [NSDictionary]
                        
                        self.moviesTableView.reloadData()
                        
                        completionHandler()
                    }
                }
                else {
                    
                }
        });
        task.resume()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movieResults.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = moviesTableView.dequeueReusableCellWithIdentifier("Movie Cell", forIndexPath: indexPath) as! MovieViewCell
        
        let movie = movieResults![indexPath.row]
        let title = movie["original_title"] as! String
        let overview = movie["overview"] as! String
        
        cell.titleLabel.text = title
        cell.overviewLabel.text = overview
        cell.addSubview(cell.overviewLabel)
        cell.overviewLabel.sizeToFit()
        
        if let posterPath = movie["poster_path"] as? String {
            let baseUrl = "https://image.tmdb.org/t/p/w342"
            let imageUrl = NSURL(string:baseUrl + posterPath)
            cell.posterImage.setImageWithURL(imageUrl!)
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        moviesTableView.deselectRowAtIndexPath(indexPath, animated:true)
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        let vc = segue.destinationViewController as! MovieDetailViewController
        let cell = sender as! MovieViewCell
        let indexPath = moviesTableView.indexPathForCell(cell)
        
        vc.movie = movieResults[indexPath!.row]
    }
}
