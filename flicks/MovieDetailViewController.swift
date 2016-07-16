//
//  MovieDetailViewController.swift
//  flicks
//
//  Created by Binwei Yang on 7/15/16.
//  Copyright © 2016 Binwei Yang. All rights reserved.
//

import UIKit

class MovieDetailViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var posterImage: UIImageView!
    
    var movie: NSDictionary!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        let contentWidth = scrollView.bounds.width
        let contentHeight = scrollView.bounds.height * 3
        self.scrollView.contentSize = CGSizeMake(contentWidth, contentHeight)
        
        let title = movie["original_title"] as! String
        self.titleLabel.text = title
        
        let overview = movie["overview"] as! String
        self.overviewLabel.text = overview
        self.overviewLabel.sizeToFit()
        self.scrollView.addSubview(self.overviewLabel)
        
        if let posterPath = movie["poster_path"] as? String {
            loadImageLowResThenFadeInHighRes(posterPath)
        }
    }
    
    func loadImageLowResThenFadeInHighRes(posterPath: String) {
        let smallImageRequest = NSURLRequest(URL: NSURL(string: "https://image.tmdb.org/t/p/w45" + posterPath)!)
        let largeImageRequest = NSURLRequest(URL: NSURL(string: "https://image.tmdb.org/t/p/original" + posterPath)!)
        
        self.posterImage.setImageWithURLRequest(
            smallImageRequest,
            placeholderImage: nil,
            success: { (smallImageRequest, smallImageResponse, smallImage) -> Void in
                
                self.posterImage.image = smallImage
                
                if (smallImageResponse != nil) {
                    // NSLog("Loaded small image from network for \(posterPath)")
                    
                    self.posterImage.alpha = 0.0
                    UIView.animateWithDuration(0.5, animations: { () -> Void in
                        self.posterImage.alpha = 1.0
                        }, completion: { (success) -> Void in
                            // The AFNetworking ImageView Category only allows one request to be sent at a time
                            // per ImageView. This code must be in the completion block.
                            self.posterImage.setImageWithURLRequest(
                                largeImageRequest,
                                placeholderImage: smallImage,
                                success: { (largeImageRequest, largeImageResponse, largeImage) -> Void in
                                    
                                    self.posterImage.image = largeImage
                                    
                                    if (largeImageResponse != nil) {
                                        // NSLog("Loaded large image from network for \(posterPath)")
                                    }
                                    else {
                                        //NSLog("Loaded large image from cache for \(posterPath)")
                                    }
                                },
                                failure: { (request, response, error) -> Void in
                                    // do something for the failure condition of the large image request
                                    // possibly setting the ImageView's image to a default image
                            })
                    })
                }
                else {
                    // NSLog("Loaded small image from cache for \(posterPath)")
                    self.posterImage.setImageWithURL(largeImageRequest.URL!)
                    // NSLog("Loaded large image from cache for \(posterPath)")
                }
                
            },
            failure: { (request, response, error) -> Void in
                self.posterImage.image = nil
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        dismissViewControllerAnimated(false, completion: nil)
    }
}
