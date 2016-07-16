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
            let baseUrl = "https://image.tmdb.org/t/p/original"
            let imageUrl = NSURL(string:baseUrl + posterPath)
            self.posterImage.setImageWithURL(imageUrl!)
        }
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
