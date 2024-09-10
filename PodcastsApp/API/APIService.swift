//
//  APIService.swift
//  PodcastsApp
//
//  Created by shubham sharma on 06/09/24.
//

import Foundation
import Alamofire
import FeedKit

class APIService {
    
    let baseiTunesSearchURL = "https://itunes.apple.com/search"

    static let shared = APIService()
    
    func fetchEpisodes(feedUrl: String, completionHandler: @escaping ([Episode]) -> ()) {

        let secureFeedUrl = feedUrl.contains("https") ? feedUrl : feedUrl.replacingOccurrences(of: "http", with: "https")
        
        guard let url = URL(string: secureFeedUrl) else { return  }
        
        DispatchQueue.global(qos: .background).async {
            
            let parser = FeedParser(URL: url)
            parser.parseAsync { result in
                switch result {
                case .success(let feed):
                    if let rssFeed = feed.rssFeed {
                            
                       let episodes = rssFeed.toEpisodes()
                        completionHandler(episodes)

                        print("Successfully parsed feed: \(feed)")
                    } else {
                        print("Unexpected feed type: not an RSS feed")
                    }
                  case .failure(let error):
                      print("Failed to parse feed with error: \(error.localizedDescription)")
                    
                
                  }
                
            }
        }
        
    }
    
    func fetchPodcasts(searchText: String, completionHandler: @escaping ([Podcast]) -> () ) {
        let parameters = ["term": searchText,"media":"podcast"]
        
        AF.request(baseiTunesSearchURL, method: .get, parameters: parameters, encoding: URLEncoding.default,headers: nil).response { dataresponse in
            if let error = dataresponse.error {
                print("failed to contac yahoo",error)
                return
            }
            
            guard let data = dataresponse.data else { return }
            
            let dummyString = String(data: data,encoding: .utf8)
            do {
                let searchResult = try JSONDecoder().decode(SearchResults.self, from: data)
                print(searchResult.resultCount)
                completionHandler(searchResult.results)
//                self.podcasts = searchResult.results
//                self.tableView.reloadData()
                
            }catch let decodError {
                print("failed to decode ",decodError)
            }
            
        }
    }
    
//    let url = "https://itunes.apple.com/search"
//    let parameters = ["term": searchText,"media":"podcast"]
//    
//    AF.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default,headers: nil).response { dataresponse in
//        if let error = dataresponse.error {
//            print("failed to contac yahoo",error)
//            return
//        }
//        
//        guard let data = dataresponse.data else { return }
//        
//        let dummyString = String(data: data,encoding: .utf8)
//        do {
//            let searchResult = try JSONDecoder().decode(SearchResults.self, from: data)
//            searchResult.results.forEach { podcast in
//            }
//        
//            self.podcasts = searchResult.results
//            self.tableView.reloadData()
//            
//        }catch let decodError {
//            print("failed to decode ",decodError)
//        }
//        
//    }
   
    struct SearchResults: Decodable {
        let resultCount: Int
        let results: [Podcast]
    }

    
}
