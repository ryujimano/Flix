//
//  DetailViewController.swift
//  Flicks
//
//  Created by Ryuji Mano on 2/7/17.
//  Copyright © 2017 Ryuji Mano. All rights reserved.
//

import UIKit
import AFNetworking

class DetailViewController: UIViewController, UIScrollViewDelegate {
    @IBOutlet weak var posterView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overViewLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var detailView: UIView!
    
    @IBOutlet weak var ratingsView: UIView!
    @IBOutlet weak var star1: UIImageView!
    @IBOutlet weak var star2: UIImageView!
    @IBOutlet weak var star3: UIImageView!
    @IBOutlet weak var star4: UIImageView!
    @IBOutlet weak var star5: UIImageView!
    @IBOutlet weak var ratingLabel: UILabel!
    
    
    var movie: NSDictionary!
    var posterURL:URL?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = movie["title"] as? String
        overViewLabel.text = movie["overview"] as? String
        
        titleLabel.sizeToFit()
        
        ratingsView.frame.origin.y = titleLabel.frame.origin.y + titleLabel.frame.height + 10
        
        overViewLabel.frame.origin.y = ratingsView.frame.origin.y + ratingsView.frame.height + 10
        overViewLabel.sizeToFit()
        
        detailView.frame.size.height = overViewLabel.frame.origin.y + overViewLabel.frame.height + 10
        detailView.layer.cornerRadius = 10
        detailView.frame.origin.y = view.frame.height - (tabBarController?.tabBar.frame.height)! - titleLabel.frame.height - 20
        
        
        let baseURL = "https://image.tmdb.org/t/p/"
        
        if let posterPath = movie["poster_path"] as? String {
            setImage(with: baseURL, and: posterPath)
        }
        
        view.insertSubview(scrollView, at: 1)
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: detailView.frame.origin.y + detailView.frame.size.height + (tabBarController?.tabBar.frame.height)! + 5)
        
        scrollView.delegate = self
        scrollView.showsVerticalScrollIndicator = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setImage(with baseURL: String, and posterPath: String) {
        let smallImageRequest = URLRequest(url: URL(string: baseURL + "w45" + posterPath)!)
        let largeImageRequest = URLRequest(url: URL(string: baseURL + "original" + posterPath)!)
        
        posterView.setImageWith(smallImageRequest, placeholderImage: nil, success: { (req, res, smallImage) in
            self.posterView.alpha = 0
            self.posterView.image = smallImage
            
            UIView.animate(withDuration: 0.3, animations: {
                self.posterView.alpha = 1
            }, completion: { (isComplete) in
                    self.posterView.setImageWith(largeImageRequest, placeholderImage: nil, success: { (req, res, largeImage) in
                        self.posterView.image = largeImage
                    }, failure: { (req, res, error) in
                        self.posterView.setImageWith(URL(string: baseURL + "original" + posterPath)!)
                })
            })
        }) { (req, res, error) in
            self.posterView.setImageWith(URL(string: baseURL + "original" + posterPath)!)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
