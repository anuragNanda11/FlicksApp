//
//  DetailViewController.swift
//  Flicks
//
//  Created by Nate nanda on 1/26/16.
//  Copyright © 2016 Anurag Nanda. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overViewLabel: UILabel!
    var movie: NSDictionary!
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.contentSize =
            CGSize(width: scrollView.frame.size.width, height: infoView.frame.origin.y + infoView.frame.height)
        titleLabel.text = (movie["title"] as! String)
        overViewLabel.text = (movie["overview"] as! String)
        overViewLabel.sizeToFit()
        
        let baseUrlLowRes = "http://image.tmdb.org/t/p/w92/"
        let baseUrlHighRes = "http://image.tmdb.org/t/p/w500/"
        if let posterPath = movie["poster_path"] as? String {
            let posterUrlLowRes = NSURL(string: baseUrlLowRes + posterPath)!
            posterImageView.setImageWithURL(posterUrlLowRes)
            let seconds = 0.5
            let delay = seconds * Double(NSEC_PER_SEC)  // nanoseconds per seconds
            let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
            
            dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                
                let posterUrlHighRes = NSURL(string: baseUrlHighRes + posterPath)!
                self.posterImageView.setImageWithURL(posterUrlHighRes)
    
            })
            
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
