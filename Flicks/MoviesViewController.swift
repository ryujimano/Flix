//
//  MoviesViewController.swift
//  Flicks
//
//  Created by Ryuji Mano on 1/31/17.
//  Copyright © 2017 Ryuji Mano. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var networkErrorButton: UIButton!
    @IBOutlet weak var movieSearchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    var movies:[NSDictionary]?
    var page = 0
    
    var filteredMovies:[NSDictionary] = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        networkErrorButton.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        tableView.alpha = 0
        
        movieSearchBar.delegate = self
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.alpha = 1
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        page += 1
        
        loadMovies(at: page)
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(loadMovies(_:)), for: .valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
    }
    
    func loadMovies(at page:Int) {
        let apiKey = "16e4d20620e968bb2ac7b6075dd69d43"
        let url = URL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)&page=\(page)")!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        MBProgressHUD.showAdded(to: self.view, animated: true)
        let task: URLSessionDataTask = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            
            if error != nil {
                self.animateNetworkErrorButton()
            }
            
            if let data = data {
                if let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                    if self.movies == nil || self.movies?.count == 0 {
                        self.movies = dataDictionary["results"] as? [NSDictionary]
                    }
                    else {
                        self.movies! += (dataDictionary["results"] as! [NSDictionary])
                    }
                    self.filteredMovies = self.movies!
                    self.tableView.reloadData()
                    self.collectionView.reloadData()
                }
            }
            MBProgressHUD.hide(for: self.view, animated: true)
        }
        task.resume()
        
    }
    
    func loadMovies(_ refreshControl:UIRefreshControl) {
        
        if !networkErrorButton.isHidden {
            animateRetractingNetworkErrorButton()
        }
        
        let apiKey = "16e4d20620e968bb2ac7b6075dd69d43"
        let url = URL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task: URLSessionDataTask = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            
            if error != nil {
                self.animateNetworkErrorButton()
                refreshControl.endRefreshing()
            }
            
            if let data = data {
                if let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                    self.movies = dataDictionary["results"] as? [NSDictionary]
                    self.filteredMovies = self.movies!
                    self.tableView.reloadData()
                    self.collectionView.reloadData()
                    
                    refreshControl.endRefreshing()
                }
            }
        }
        task.resume()
        

    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredMovies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "movieCell", for: indexPath) as! MovieCell
        
        let movie = filteredMovies[indexPath.row]
        
        guard let title = movie["title"] as? String, let overview = movie["overview"] as? String, let posterPath = movie["poster_path"] as? String else {
            return cell
        }
        
        let baseURL = "https://image.tmdb.org/t/p/w500"
        let imageRequest = URLRequest(url: URL(string: baseURL + posterPath)!)
        
        cell.titleLabel.text = title
        cell.overviewLabel.text = overview
        cell.posterView.setImageWith(imageRequest, placeholderImage: nil, success: { (imageRequest, response, image) in
            if response != nil {
                cell.posterView.alpha = 0
                cell.posterView.image = image
                UIView.animate(withDuration: 0.3, animations: { 
                    cell.posterView.alpha = 1
                })
            }
            else {
                cell.posterView.image = image
            }
        }) { (imageRequest, response, error) in
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if movieSearchBar.isFirstResponder {
            return
        }
        if indexPath.row >= tableView.numberOfRows(inSection: 0) - 1 {
            page += 1
            loadMovies(at: page)
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredMovies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "movieCollectionCell", for: indexPath) as! MovieCollectionViewCell
        
        let movie = filteredMovies[indexPath.row]
        
        guard let posterPath = movie["poster_path"] as? String else {
            return cell
        }
        
        let baseURL = "https://image.tmdb.org/t/p/w500"
        let imageRequest = URLRequest(url: URL(string: baseURL + posterPath)!)
        
        cell.posterView.setImageWith(imageRequest, placeholderImage: nil, success: { (imageRequest, response, image) in
            if response != nil {
                cell.posterView.alpha = 0
                cell.posterView.image = image
                UIView.animate(withDuration: 0.3, animations: {
                    cell.posterView.alpha = 1
                })
            }
            else {
                cell.posterView.image = image
            }
        }) { (imageRequest, response, error) in
        }
        
        
        return cell
    }
    
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let filtered = searchText.isEmpty ? movies : movies?.filter({ (dataDictionary: NSDictionary) -> Bool in
            let dataString = dataDictionary["title"] as! String
            return dataString.lowercased().range(of: searchText.lowercased()) != nil
        })
        filteredMovies = filtered ?? []
        tableView.reloadData()
        collectionView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        movieSearchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        movieSearchBar.showsCancelButton = false
        movieSearchBar.text = ""
        movieSearchBar.resignFirstResponder()
        
        filteredMovies = movies ?? []
        tableView.reloadData()
        collectionView.reloadData()
    }
    
    @IBAction func networkErrorButtonTapped(_ sender: Any) {
        animateRetractingNetworkErrorButton()
        loadMovies(at: page)
    }
    
    func animateNetworkErrorButton() {
        UIView.animate(withDuration: 0.3, animations: {
            self.networkErrorButton.isHidden = false
            let yValue = UIApplication.shared.statusBarFrame.height + self.movieSearchBar.frame.height - 1
            self.networkErrorButton.frame = CGRect(x: 0, y: yValue, width: self.networkErrorButton.frame.width, height: self.networkErrorButton.frame.height)
        })
    }
    
    func animateRetractingNetworkErrorButton() {
        UIView.animate(withDuration: 0.3, animations: {
            let yValue = UIApplication.shared.statusBarFrame.height + self.movieSearchBar.frame.height
            self.networkErrorButton.frame = CGRect(x: 0, y: 0 - self.networkErrorButton.frame.height + yValue, width: self.networkErrorButton.frame.width, height: self.networkErrorButton.frame.height)
        }, completion: { (isComplete) in
            self.networkErrorButton.isHidden = true
        })
    }

    @IBAction func onPinchGesture(_ sender: UIPinchGestureRecognizer) {
        print(sender.scale)
        var pinchScale  = sender.scale
        if sender.scale < 1 {
            if sender.scale < 0.2 {
                pinchScale = 0.2
            }
            tableView.alpha = pinchScale
            collectionView.alpha = 1 - pinchScale
            if sender.state == UIGestureRecognizerState.ended {
                UIView.animate(withDuration: 0.2, animations: { 
                    self.collectionView.alpha = 1
                }, completion: { (complete) in
                    self.tableView.alpha = 0
                })
            }
        }
        else {
            if sender.scale > 5 {
                pinchScale = 5
            }
            tableView.alpha = pinchScale / 6.25
            collectionView.alpha = 1 - (pinchScale / 6.25)
            if sender.state == UIGestureRecognizerState.ended {
                UIView.animate(withDuration: 0.2, animations: { 
                    self.tableView.alpha = 1
                }, completion: { (complete) in
                    self.collectionView.alpha = 0
                })
            }
        }
    }
}
