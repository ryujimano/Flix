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
    
    var movie: NSDictionary!
    var posterURL:URL?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = movie["title"] as? String
        overViewLabel.text = movie["overview"] as? String
        
        overViewLabel.sizeToFit()
        detailView.frame.size.height = overViewLabel.frame.origin.y + overViewLabel.frame.height + 10
        
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: detailView.frame.origin.y + detailView.frame.size.height + (tabBarController?.tabBar.frame.height)!)
        
        
        let baseURL = "https://image.tmdb.org/t/p/"
        
        if let posterPath = movie["poster_path"] as? String {
            setImage(with: baseURL, and: posterPath)
        }
        
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
