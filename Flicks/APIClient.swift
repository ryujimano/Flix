//
//  APIClient.swift
//  Flicks
//
//  Created by Ryuji Mano on 12/15/17.
//  Copyright © 2017 Ryuji Mano. All rights reserved.
//

import Foundation

class APIClient {
    static var shared: APIClient = APIClient()

    var baseURL = "https://api.themoviedb.org/3/movie/"
    var apiKey = "16e4d20620e968bb2ac7b6075dd69d43"

    var session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)

    func nowPlayingMovies(at page: Int?, movies: [Movie], completion: @escaping ([Movie]?, Error?) -> ()) {
        let url = URL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)&page=\(page ?? 1)")!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let task = session.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completion(nil, error)
            } else if let data = data {
                if let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                    let dicts = dataDictionary["results"] as! [[String : Any]]
                    let movies = Movie.movies(movies: movies, dicts: dicts)
                    completion(movies, nil)
                }
            }
        }
        task.resume()
    }

    func superHeroMovies(at page: Int?, movies: [Movie], completion: @escaping([Movie]?, Error?) -> ()) {
        let url = URL(string: "https://api.themoviedb.org/3/movie/297762/similar?api_key=\(apiKey)&page=\(page ?? 1)")!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let task = session.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completion(nil, error)
            } else if let data = data {
                if let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                    let dicts = dataDictionary["results"] as! [[String : Any]]
                    let movies = Movie.movies(movies: movies, dicts: dicts)
                    completion(movies, nil)
                }
            }
        }
        task.resume()
    }

    func popularMovies(movies: [Movie], completion: @escaping([Movie]?, Error?) -> ()) {
        let url = URL(string: "https://api.themoviedb.org/3/movie/popular?api_key=\(apiKey)")!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let task = session.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completion(nil, error)
            } else if let data = data {
                if let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                    let dicts = dataDictionary["results"] as! [[String : Any]]
                    let movies = Movie.movies(movies: movies, dicts: dicts)
                    completion(movies, nil)
                }
            }
        }
        task.resume()
    }
}
