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
    @IBOutlet var pinchGestureRecognizer: UIPinchGestureRecognizer!
    
    
    var movies:[NSDictionary]?
    var endpoint:String!
    
    //variable of the page number used for API calls
    var page = 0
    
    //boolean value to check if the collection view is in front of the tableview
    var onFront: Bool = true
    
    //array of dictionaries filtered from movies (used for search)
    var filteredMovies:[NSDictionary] = []
    
    //custom components for refreshControl
    let refreshContents = Bundle.main.loadNibNamed("RefreshView", owner: self, options: nil)
    var customView: UIView!
    var icon: UIImageView!
    
    let refreshControl = UIRefreshControl()
    
    
    
    //
    // MARK - View Configuration
    //
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        //hide network error button
        networkErrorButton.isHidden = true
        
        //initial configuration of the tableview and the collectionview
        if onFront {
            tableView.alpha = 0
            collectionView.alpha = 1
            
            collectionView.isUserInteractionEnabled = true
            tableView.isUserInteractionEnabled = false
        }
        else {
            collectionView.alpha = 0
            tableView.alpha = 1
            
            tableView.isUserInteractionEnabled = true
            collectionView.isUserInteractionEnabled = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //configure tableview
        tableView.dataSource = self
        tableView.delegate = self
        
        //configure search bar
        movieSearchBar.delegate = self
        
        //configure collectionview
        collectionView.dataSource = self
        collectionView.delegate = self
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        //set page to 1 initially
        page += 1
        
        //load movies from the API and assign the resulting JSON to the movies array
        loadMovies(at: page)
        
        //configure custom refreshControl
        customView = refreshContents?[0] as! UIView
        icon = customView.viewWithTag(1) as! UIImageView
        icon.tintColor = .lightGray
        refreshControl.tintColor = .clear
        refreshControl.backgroundColor = .clear
        setUpRefreshControl()
        refreshControl.addTarget(self, action: #selector(loadMovies(_:)), for: .valueChanged)
        collectionView.insertSubview(refreshControl, at: 0)
        
        
        if let navigationBar = navigationController?.navigationBar {
            navigationBar.tintColor = .yellow
            navigationBar.barTintColor = .black
            navigationBar.subviews.first?.alpha = 0.7
        }
        movieSearchBar.sizeToFit()
        navigationItem.titleView = movieSearchBar
        
        if let tabBar = tabBarController?.tabBar {
            tabBar.tintColor = .yellow
            tabBar.barTintColor = .black
            tabBar.alpha = 0.7
        }
        
    }
    
    
    
    //
    // MARK - Refresh Control Setup
    //
    func setUpRefreshControl() {
        //set custom view bounds equal to refreshControl bounds
        customView.frame = refreshControl.bounds
        
        customView.backgroundColor = .black
        
        //add custom view to refreshControl
        refreshControl.addSubview(customView)
    }
    
    func animateRefreshControl() {
        //animate color of refreshControl background (repeated color change from black to yellow)
        UIView.animate(withDuration: 0.5, delay: 0, options: [.autoreverse, .curveLinear, .repeat], animations: {
            self.customView.backgroundColor = .black
            self.customView.backgroundColor = .yellow
        }, completion: nil)
    }
    
    
    
    //
    // MARK - ScrollView
    //
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //if 1 < height of the refreshControl <= 60, rotate the icon
        if refreshControl.bounds.height > 1  && refreshControl.bounds.height <= 60 {
            icon.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi) + CGFloat(Double.pi) * (refreshControl.bounds.height / CGFloat(60)))
        }
        //if height of the refreshControl > 60, keep icon upright
        else if refreshControl.bounds.height > 60 {
            icon.transform = CGAffineTransform(rotationAngle: CGFloat(0))
        }
    }
    
    
    
    //
    // MARK - API Calls
    //
    func loadMovies(at page:Int) {
        //when loading movies, disable pinch gesture
        pinchGestureRecognizer.isEnabled = false
        
        //API call
        let apiKey = "16e4d20620e968bb2ac7b6075dd69d43"
        let url = URL(string: "https://api.themoviedb.org/3/movie/\(endpoint!)?api_key=\(apiKey)&page=\(page)")!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        
        //start loading display
        MBProgressHUD.showAdded(to: self.view, animated: true)
        let task: URLSessionDataTask = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            
            //if an error occurred, show network error button
            if error != nil {
                self.animateNetworkErrorButton()
            }
            
            if let data = data {
                if let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                    //if the movies array is empty, assign the resulting dictionary array to movies
                    if self.movies == nil || self.movies?.count == 0 || page == 1 {
                        self.movies = dataDictionary["results"] as? [NSDictionary]
                    }
                    //if the movies array is not empty, append the results to movies
                    else {
                        self.movies! += (dataDictionary["results"] as! [NSDictionary])
                    }
                    
                    //assign movies to filteredMovies
                    self.filteredMovies = self.movies!
                    
                    //reload data
                    self.tableView.reloadData()
                    self.collectionView.reloadData()
                }
            }
            //end loading display
            MBProgressHUD.hide(for: self.view, animated: true)
        }
        task.resume()
        
        //enable pinch gesture
        pinchGestureRecognizer.isEnabled = true
    }
    
    //function for API call used when the user refreshes the contents
    @objc func loadMovies(_ refreshControl:UIRefreshControl) {
        animateRefreshControl()
        
        //if network error button is hidden, retract the button and end refreshing
        if !networkErrorButton.isHidden {
            animateRetractingNetworkErrorButton()
            refreshControl.endRefreshing()
            return
        }
        
        //API call
        let apiKey = "16e4d20620e968bb2ac7b6075dd69d43"
        let url = URL(string: "https://api.themoviedb.org/3/movie/\(endpoint!)?api_key=\(apiKey)")!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task: URLSessionDataTask = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            
            //if an error occurred, end refreshing and show network error button
            if error != nil {
                self.animateNetworkErrorButton()
                refreshControl.endRefreshing()
            }
            
            //assign the resulting dictionary array to movies and filteredMovies, reload data, and end refreshing
            if let data = data {
                if let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                    self.movies = dataDictionary["results"] as? [NSDictionary]
                    self.filteredMovies = self.movies!
                    self.tableView.reloadData()
                    self.collectionView.reloadData()
                    
                    refreshControl.endRefreshing()
                    
                    self.customView.backgroundColor = .black
                }
            }
        }
        task.resume()
    }
    
    
    
    //
    // MARK - TableView
    //
    
    //set number of rows to the amount of elements in filteredMovies
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredMovies.count
    }
    
    //configure the cells of the tableview
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "movieCell", for: indexPath) as! MovieCell
        
        let movie = filteredMovies[indexPath.row]
        
        //if title, overview, and poster image is nil, then return the cell
        guard let title = movie["title"] as? String, let overview = movie["overview"] as? String, let posterPath = movie["poster_path"] as? String else {
            return cell
        }
        
        let baseURL = "https://image.tmdb.org/t/p/w500"
        let imageRequest = URLRequest(url: URL(string: baseURL + posterPath)!)
        
        //add title, overview, and poster image to the cell
        //add fade in animation to the poster image
        cell.titleLabel.text = title
        cell.overviewLabel.text = overview
        cell.posterView.setImageWith(imageRequest, placeholderImage: nil, success: { (imageRequest, response, image) in
            if response != nil {
                cell.posterView.alpha = 0
                cell.posterView.image = image
                UIView.animate(withDuration: 0.5, animations: {
                    cell.posterView.alpha = 1
                })
            }
            else {
                cell.posterView.image = image
            }
        }) { (imageRequest, response, error) in
        }
        
        cell.selectionStyle = .none
        
        //add rating stars to the cell
        if let rating = movie["vote_average"] as? Double {
            Model.getStars(of: rating, with: cell.star1, cell.star2, cell.star3, cell.star4, cell.star5)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        //when the user is using the search bar, exit function
        if movieSearchBar.isFirstResponder {
            return
        }
        //when the tableview reaches the last cell, load the next page of movies and increment pages
        if indexPath.row >= tableView.numberOfRows(inSection: 0) - 1 {
            page += 1
            loadMovies(at: page)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    
    
    //
    // MARK - CollectionView
    //
    //set number of items in the collectionview to the amount of elements in filteredMovies
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredMovies.count
    }
    
    //configure cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "movieCollectionCell", for: indexPath) as! MovieCollectionViewCell
        
        let movie = filteredMovies[indexPath.row]
        
        //if poster image is nil, return cell
        guard let posterPath = movie["poster_path"] as? String else {
            return cell
        }
        
        let baseURL = "https://image.tmdb.org/t/p/w500"
        let imageRequest = URLRequest(url: URL(string: baseURL + posterPath)!)
        
        //add fade in animation to the poster image
        cell.posterView.setImageWith(imageRequest, placeholderImage: nil, success: { (imageRequest, response, image) in
            if response != nil {
                cell.posterView.alpha = 0
                cell.posterView.image = image
                UIView.animate(withDuration: 0.5, animations: {
                    cell.posterView.alpha = 1
                })
            }
            else {
                cell.posterView.image = image
            }
        }) { (imageRequest, response, error) in
        }
        
        
        //add rating stars to each item
        if let rating = movie["vote_average"] as? Double {
            Model.getStars(of: rating, with: cell.star1, cell.star2, cell.star3, cell.star4, cell.star5)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        //if the user is using the search bar, exit the function
        if movieSearchBar.isFirstResponder {
            return
        }
        //if the collectionview hits the last item, load the next page of movies and increment pages
        if indexPath.row >= collectionView.numberOfItems(inSection: 0) - 1 {
            page += 1
            loadMovies(at: page)
        }
    }
    
    
    
    
    //
    // MARK - Search Bar
    //
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //filter the movies array based on the user's search
        let filtered = searchText.isEmpty ? movies : movies?.filter({ (dataDictionary: NSDictionary) -> Bool in
            let dataString = dataDictionary["title"] as! String
            return dataString.lowercased().range(of: searchText.lowercased()) != nil
        })
        
        //assign the filtered array to filteredMovies
        filteredMovies = filtered ?? []
        
        //reload data
        tableView.reloadData()
        collectionView.reloadData()
    }
    
    //function that shows the cancel button when the user is using the search bar
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        movieSearchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        //remove the text and cancel button when the user clicks on the cancel button
        movieSearchBar.showsCancelButton = false
        movieSearchBar.text = ""
        
        //retract keyboard when the cancel button is clicked
        movieSearchBar.resignFirstResponder()
        
        //reload data with all of the movies array content
        filteredMovies = movies ?? []
        tableView.reloadData()
        collectionView.reloadData()
    }
    
    
    
    
    //
    // MARK - Network Error Button
    //
    
    //retract the network error button when tapped
    @IBAction func networkErrorButtonTapped(_ sender: Any) {
        animateRetractingNetworkErrorButton()
    }
    
    func animateNetworkErrorButton() {
        
        //add animation to network error button
        //translate the network error button from behind the search bar
        UIView.animate(withDuration: 0.3, animations: {
            self.networkErrorButton.isHidden = false
            let yValue = UIApplication.shared.statusBarFrame.height + self.movieSearchBar.frame.height - 1
            self.networkErrorButton.frame = CGRect(x: 0, y: yValue, width: self.networkErrorButton.frame.width, height: self.networkErrorButton.frame.height)
        })
        
    }
    
    func animateRetractingNetworkErrorButton() {
        
        //add retracting animation to the network error button
        //translate the network error button from the view to behind the search bar
        UIView.animate(withDuration: 0.3, animations: {
            let yValue = UIApplication.shared.statusBarFrame.height + self.movieSearchBar.frame.height
            self.networkErrorButton.frame = CGRect(x: 0, y: 0 - self.networkErrorButton.frame.height + yValue, width: self.networkErrorButton.frame.width, height: self.networkErrorButton.frame.height)
        }, completion: { (isComplete) in
            
            //when animation is completed, hide the network error button and load movies
            self.networkErrorButton.isHidden = true
            self.loadMovies(at: self.page)
        })
        
    }
    
    
    
    
    //
    // MARK - Pinch Gesture
    //
    @IBAction func onPinchGesture(_ sender: UIPinchGestureRecognizer) {
        
        var pinchScale  = sender.scale
        
        //if user is pinching inwards, translate from tableview to collectionview
        if sender.scale < 1 && !onFront {
            if tableView.indexPathsForVisibleRows?.count != 0, let indexPath = tableView.indexPathsForVisibleRows?[0] {
                collectionView.scrollToItem(at: indexPath, at: .top, animated: false)
            }
            if sender.scale < 0.2 {
                pinchScale = 0.2
            }
            tableView.alpha = pinchScale
            collectionView.alpha = 1 - pinchScale
            if pinchScale <= 0.8 && sender.state == UIGestureRecognizerState.ended {
                onFront = true
                UIView.animate(withDuration: 0.3, animations: {
                    self.collectionView.alpha = 1
                }, completion: { (complete) in
                    self.tableView.alpha = 0
                    self.collectionView.isUserInteractionEnabled = true
                    self.tableView.isUserInteractionEnabled = false
                    self.collectionView.insertSubview(self.refreshControl, at: 0)
                })
            }
        }
        //if user is pinching outwards, translate from collectionview to tableview
        else if sender.scale > 1 && onFront {
            if collectionView.indexPathsForVisibleItems.count != 0 {
                tableView.scrollToRow(at: collectionView.indexPathsForVisibleItems[0], at: .top, animated: false)
            }
            if sender.scale > 5 {
                pinchScale = 5
            }
            tableView.alpha = pinchScale / 6.25
            collectionView.alpha = 1 - (pinchScale / 6.25)
            if pinchScale >= 1.2 && sender.state == UIGestureRecognizerState.ended {
                onFront = false
                UIView.animate(withDuration: 0.3, animations: {
                    self.tableView.alpha = 1
                    self.collectionView.alpha = 0
                }, completion: { (complete) in
                    self.tableView.isUserInteractionEnabled = true
                    self.collectionView.isUserInteractionEnabled = false
                    self.tableView.insertSubview(self.refreshControl, at: 0)
                })
            }
        }
        
        //if the pinch gesture was not adequate enough, return to collectionview or tableview
        if 0.8 < pinchScale && pinchScale < 1.2 && sender.state == UIGestureRecognizerState.ended {
            if onFront {
                if collectionView.indexPathsForVisibleItems.count != 0 {
                    tableView.scrollToRow(at: collectionView.indexPathsForVisibleItems[0], at: .top, animated: false)
                }
                collectionView.alpha = 1
                tableView.alpha = 0
                self.tableView.isUserInteractionEnabled = false
                self.collectionView.isUserInteractionEnabled = true
            }
            else {
                if tableView.indexPathsForVisibleRows?.count != 0, let indexPath = tableView.indexPathsForVisibleRows?[0] {
                    collectionView.scrollToItem(at: indexPath, at: .top, animated: false)
                }
                collectionView.alpha = 0
                tableView.alpha = 1
                self.tableView.isUserInteractionEnabled = true
                self.collectionView.isUserInteractionEnabled = false
            }
        }
    }
    
    
    
    
    //
    // MARK: Navigation
    //
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? UITableViewCell {
            let indexPath = tableView.indexPath(for: cell)
            let movie = movies?[(indexPath?.row)!]
            
            let destination = segue.destination as! DetailViewController
            destination.movie = movie
        }
        else if let item = sender as? UICollectionViewCell {
            let indexPath = collectionView.indexPath(for: item)
            let movie = movies?[(indexPath?.item)!]
            
            let destination = segue.destination as! DetailViewController
            destination.movie = movie
        }
    }
}
