//
//  MovieCell.swift
//  Flicks
//
//  Created by Ryuji Mano on 1/31/17.
//  Copyright © 2017 Ryuji Mano. All rights reserved.
//

import UIKit

class MovieCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var posterView: UIImageView!
    
    
    @IBOutlet weak var star1: UIImageView!
    @IBOutlet weak var star2: UIImageView!
    @IBOutlet weak var star3: UIImageView!
    @IBOutlet weak var star4: UIImageView!
    @IBOutlet weak var star5: UIImageView!

    var movie: Movie! {
        didSet {
            if let posterURL = movie.posterURL {
                let imageRequest = URLRequest(url: posterURL)
                posterView.setImageWith(imageRequest, placeholderImage: nil, success: { (imageRequest, response, image) in
                    if response != nil {
                        self.posterView.alpha = 0
                        self.posterView.image = image
                        UIView.animate(withDuration: 0.5, animations: {
                            self.posterView.alpha = 1
                        })
                    }
                    else {
                        self.posterView.image = image
                    }
                }) { (imageRequest, response, error) in
                }
            }

            //add title, overview, and poster image to the cell
            //add fade in animation to the poster image
            titleLabel.text = movie.title
            overviewLabel.text = movie.overview

            selectionStyle = .none

            //add rating stars to the cell
            if let rating = movie.ratings {
                Model.getStars(of: rating, with: star1, star2, star3, star4, star5)
            }
        }
    }

    func setUp(with movie: Movie) {
        self.movie = movie
    }

}
