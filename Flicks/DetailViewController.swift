//
//  DetailViewController.swift
//  Flicks
//
//  Created by Ryuji Mano on 2/7/17.
//  Copyright © 2017 Ryuji Mano. All rights reserved.
//

import UIKit
import AFNetworking

class DetailViewController: UIViewController, UIScrollViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
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
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var reviewButton: UIButton!
    @IBOutlet weak var similarLabel: UILabel!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    
    var movie: NSDictionary!
    var posterURL:URL?
    var similarMovies: [NSDictionary]?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = movie["title"] as? String
        overViewLabel.text = movie["overview"] as? String
        
        titleLabel.sizeToFit()
        
        ratingsView.frame.origin.y = titleLabel.frame.origin.y + titleLabel.frame.height + 10
        
        overViewLabel.frame.origin.y = ratingsView.frame.origin.y + ratingsView.frame.height + 10
        overViewLabel.sizeToFit()
        
        bottomView.frame.origin.y = overViewLabel.frame.origin.y + overViewLabel.frame.height + 10
        
        detailView.frame.size.height = bottomView.frame.origin.y + bottomView.frame.height + 10
        detailView.layer.cornerRadius = 10
        detailView.frame.origin.y = view.frame.height - (tabBarController?.tabBar.frame.size.height ?? 0) - titleLabel.frame.size.height - titleLabel.frame.origin.y
        
        if let rating = movie["vote_average"] as? Double {
            Model.getStars(of: rating, with: star1, star2, star3, star4, star5)
            ratingLabel.text = String(format: "%.1f/10", rating)
        }
        
        let baseURL = "https://image.tmdb.org/t/p/"
        
        if let posterPath = movie["poster_path"] as? String {
            setImage(with: baseURL, and: posterPath)
        }
        
        view.insertSubview(scrollView, at: 1)
        scrollView.contentSize = CGSize(width: self.view.frame.size.width, height: detailView.frame.origin.y + detailView.frame.height)
        
        scrollView.delegate = self
        scrollView.showsVerticalScrollIndicator = false
        
        if let id = movie["id"] as? Int {
            loadSimilarMovies(of: id)
        }
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        //configure collectionview
        collectionView.dataSource = self
        collectionView.delegate = self
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
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
    
    
    func loadSimilarMovies(of movieID:Int) {
        //API call
        let apiKey = "16e4d20620e968bb2ac7b6075dd69d43"
        let url = URL(string: "https://api.themoviedb.org/3/movie/\(movieID)/similar?api_key=\(apiKey)")!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        
        let task: URLSessionDataTask = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            
            //if an error occurred
            if error != nil {
            }
            
            if let data = data {
                if let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                    self.similarMovies = dataDictionary["results"] as? [NSDictionary]
                    
                    //reload data
                    self.collectionView.reloadData()
                }
            }
            //end loading display
        }
        task.resume()

    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return similarMovies?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "similarCell", for: indexPath) as! SimilarMovieCollectionViewCell
        
        let similarMovie = similarMovies?[indexPath.row]
        
        guard let posterPath = similarMovie?["poster_path"] as? String else {
            return cell
        }
        
        cell.posterView.setImageWith(URL(string: "https://image.tmdb.org/t/p/original" + posterPath)!)
        
        return cell
    }
    
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! ReviewViewController
        
        if let id = movie["id"] as? Int {
            destination.id = id
        }
        
    }
    

}
