//
//  Movie.swift
//  Flicks
//
//  Created by Ryuji Mano on 12/15/17.
//  Copyright © 2017 Ryuji Mano. All rights reserved.
//

import Foundation

class Movie {
    var title: String
    var posterURL: URL?
    var overview: String?
    var ratings: Double?
    var id: Int?
    var posterPath: String?

    init(dict: [String :  Any]) {
        title = dict["title"] as? String ?? "No Title"
        if let posterPath = dict["poster_path"] as? String {
            self.posterPath = posterPath
            let baseURL = "https://image.tmdb.org/t/p/w500"
            posterURL = URL(string: baseURL + posterPath)
        }
        if let over = dict["overview"] as? String {
            overview = over
        }
        if let rating = dict["vote_average"] as? Double {
            ratings = rating
        }
        if let id = dict["id"] as? Int {
            self.id = id
        }
    }

    class func movies(movies: [Movie], dicts: [[String : Any]]) -> [Movie] {
        var mov = movies
        for dict in dicts {
            mov.append(Movie(dict: dict))
        }
        return mov
    }
}
