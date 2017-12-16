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
//    @IBOutlet var pinchGestureRecognizer: UIPinchGestureRecognizer!

    
    var movies: [Movie] = []
    var endpoint: String!
    
    //variable of the page number used for API calls
    var page = 0
    
    //boolean value to check if the collection view is in front of the tableview
    var onFront: Bool = true
    
    //array of dictionaries filtered from movies (used for search)
    var filteredMovies: [Movie] = []
    
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
        if endpoint == "similar" {
            tableView.alpha = 0
            collectionView.alpha = 1
            
            collectionView.isUserInteractionEnabled = true
            tableView.isUserInteractionEnabled = false
        } else {
            collectionView.alpha = 0
            tableView.alpha = 1
            
            tableView.isUserInteractionEnabled = true
            collectionView.isUserInteractionEnabled = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //configure search bar
        movieSearchBar.delegate = self
        
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
        if endpoint == "similar" {
            //configure collectionview
            collectionView.dataSource = self
            collectionView.delegate = self
            flowLayout.scrollDirection = .vertical
            flowLayout.minimumLineSpacing = 0
            flowLayout.minimumInteritemSpacing = 0
            flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            collectionView.insertSubview(refreshControl, at: 0)
        } else {
            //configure tableview
            tableView.dataSource = self
            tableView.delegate = self
            tableView.rowHeight = UITableViewAutomaticDimension
            tableView.estimatedRowHeight = 190.0
            tableView.insertSubview(self.refreshControl, at: 0)
        }
        
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
        MBProgressHUD.showAdded(to: self.view, animated: true)

        if endpoint == "similar" {
            APIClient.shared.superHeroMovies(at: page, movies: self.movies, completion: { (movies, error) in
                //end loading display
                MBProgressHUD.hide(for: self.view, animated: true)
                if let movies = movies {
                    self.movies = movies

                    //assign movies to filteredMovies
                    self.filteredMovies = self.movies

                    //reload data
                    self.tableView.reloadData()
                    self.collectionView.reloadData()
                } else {
                    self.animateNetworkErrorButton()
                }
            })
        } else {
            APIClient.shared.nowPlayingMovies(at: page, movies: self.movies, completion: { (movies, error) in
                //end loading display
                MBProgressHUD.hide(for: self.view, animated: true)
                if let movies = movies {
                    self.movies = movies

                    //assign movies to filteredMovies
                    self.filteredMovies = self.movies

                    //reload data
                    self.tableView.reloadData()
                    self.collectionView.reloadData()
                } else {
                    self.animateNetworkErrorButton()
                }
            })
        }
    }
    
    //function for API call used when the user refreshes the contents
    @objc func loadMovies(_ refreshControl:UIRefreshControl) {
        animateRefreshControl()

        if endpoint == "similar" {
            APIClient.shared.superHeroMovies(at: nil, movies: [], completion: { (movies, error) in
                //end loading display
                MBProgressHUD.hide(for: self.view, animated: true)
                if let movies = movies {
                    self.movies = movies

                    //assign movies to filteredMovies
                    self.filteredMovies = self.movies

                    //reload data
                    self.tableView.reloadData()
                    self.collectionView.reloadData()


                    refreshControl.endRefreshing()

                    self.customView.backgroundColor = .black
                } else {
                    self.animateNetworkErrorButton()
                    refreshControl.endRefreshing()
                }
            })
        } else {
            APIClient.shared.nowPlayingMovies(at: nil, movies: [], completion: { (movies, error) in
                //end loading display
                MBProgressHUD.hide(for: self.view, animated: true)
                if let movies = movies {
                    self.movies = movies

                    //assign movies to filteredMovies
                    self.filteredMovies = self.movies

                    //reload data
                    self.tableView.reloadData()
                    self.collectionView.reloadData()


                    refreshControl.endRefreshing()

                    self.customView.backgroundColor = .black
                } else {
                    self.animateNetworkErrorButton()
                    refreshControl.endRefreshing()
                }
            })
        }
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
        
        cell.setUp(with: movie)
        
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
        
        cell.setUp(with: movie)
        
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
        let filtered = searchText.isEmpty ? movies : movies.filter({ movie -> Bool in
            let dataString = movie.title
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
        }, completion: { isComplete in
            self.networkErrorButton.isHidden = false
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
    // MARK: Navigation
    //
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? UITableViewCell {
            let indexPath = tableView.indexPath(for: cell)
            let movie = movies[(indexPath?.row)!]
            
            let destination = segue.destination as! DetailViewController
            destination.movie = movie
        }
        else if let item = sender as? UICollectionViewCell {
            let indexPath = collectionView.indexPath(for: item)
            let movie = movies[(indexPath?.item)!]
            
            let destination = segue.destination as! DetailViewController
            destination.movie = movie
        }
    }
}
