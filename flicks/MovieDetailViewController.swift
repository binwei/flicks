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
    
    public var movie: NSDictionary?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        let contentWidth = scrollView.bounds.width
        let contentHeight = scrollView.bounds.height * 3
        self.scrollView.contentSize = CGSizeMake(contentWidth, contentHeight)
        
        let title = movie!["original_title"] as! String
        let overview = movie!["overview"] as! String
        let posterPath = movie!["poster_path"] as! String
        
        print("movie has title = \(title) and poster = \(posterPath)")
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
