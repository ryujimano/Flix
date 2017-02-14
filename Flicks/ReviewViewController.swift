//
//  ReviewViewController.swift
//  Flicks
//
//  Created by Ryuji Mano on 2/13/17.
//  Copyright © 2017 Ryuji Mano. All rights reserved.
//

import UIKit

class ReviewViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    var reviews: [NSDictionary]?
    var id: Int?

    override func viewDidLoad() {
        super.viewDidLoad()

        loadReviews(of: id ?? 0)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        navigationController?.title = "Reviews"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func loadReviews(of movieID:Int) {
        //API call
        let apiKey = "16e4d20620e968bb2ac7b6075dd69d43"
        let url = URL(string: "https://api.themoviedb.org/3/movie/\(movieID)/reviews?api_key=\(apiKey)")!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        
        let task: URLSessionDataTask = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            
            //if an error occurred
            if error != nil {
            }
            
            if let data = data {
                if let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                    self.reviews = dataDictionary["results"] as? [NSDictionary]
                    self.tableView.reloadData()
                }
            }
            //end loading display
        }
        task.resume()
        
    }
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = reviews?.count {
            return count == 0 ? 1 : count
        }
        else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reviewCell", for: indexPath) as! ReviewTableViewCell
        
        if reviews?.count == 0 || reviews?.count == nil {
            cell.authorLabel.text = ""
            cell.reviewLabel.text = "No reviews available for this movie."
            return cell
        }
        
        let review = reviews?[indexPath.row]
        
        if let reviewText = review?["content"] as? String {
            cell.reviewLabel.text = reviewText
        }
        if let author = review?["author"] as? String {
            cell.authorLabel.text = author
        }
        
        cell.reviewLabel.sizeToFit()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 250
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
