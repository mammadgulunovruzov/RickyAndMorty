//
//  NetworkManager.swift
//  RickAndMorty
//
//  Created by Mammadgulu Novruzov on 18.04.25.
//

import Foundation


class NetworkManager {
    
    static let shared = NetworkManager()
    
    private init() {}
    
    func fetchRandomCharacters(completion: @escaping ([Character]) -> Void) {
        // Generate random IDs between 1 and 826 (total number of characters in the API)
        let randomIds = (1...826).shuffled().prefix(10)
        let idString = randomIds.map { String($0) }.joined(separator: ",")
        let urlString = "https://rickandmortyapi.com/api/character/\(idString)"
        
        guard let url = URL(string: urlString) else {
            completion([])
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching characters: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion([])
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion([])
                }
                return
            }
            
            do {
                if let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                    
                    var newCharacters: [Character] = []
                    let dispatchGroup = DispatchGroup()
                    
                    for item in jsonArray {
                        if let id = item["id"] as? Int,
                           let name = item["name"] as? String,
                           let image = item["image"] as? String,
                           let species = item["species"] as? String,
                           let status = item["status"] as? String,
                           let locationDict = item["location"] as? [String: Any],
                           let location = locationDict["name"] as? String,
                           let episodeArray = item["episode"] as? [String],
                           let firstEpisodeUrl = episodeArray.first,
                           let episodeUrl = URL(string: firstEpisodeUrl) {
                            
                            dispatchGroup.enter()
                            
                            self.fetchEpisodeName(url: episodeUrl) { episodeName in
                                let character = Character(
                                    id: id,
                                    name: name,
                                    status: status,
                                    species: species,
                                    image: image,
                                    location: location,
                                    firstSeenEpisode: episodeName
                                )
                                
                                DispatchQueue.main.async {
                                    newCharacters.append(character)
                                    dispatchGroup.leave()
                                }
                            }
                        }
                    }
                    
                    dispatchGroup.notify(queue: .main) {
                        completion(newCharacters)
                    }
                } else {
                    DispatchQueue.main.async {
                        completion([])
                    }
                }
                
            } catch {
                print("JSON parsing error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion([])
                }
            }
        }
        
        task.resume()
    }
    
    private func fetchEpisodeName(url: URL, completion: @escaping (String) -> Void) {
        URLSession.shared.dataTask(with: url) { episodeData, _, error in
            var episodeName = "Unknown"
            
            if let error = error {
                print("Error fetching episode: \(error.localizedDescription)")
                completion(episodeName)
                return
            }
            
            if let episodeData = episodeData {
                do {
                    if let episodeJSON = try JSONSerialization.jsonObject(with: episodeData, options: []) as? [String: Any],
                       let fetchedEpisodeName = episodeJSON["name"] as? String {
                        episodeName = fetchedEpisodeName
                    }
                } catch {
                    print("Episode JSON parsing error: \(error.localizedDescription)")
                }
            }
            
            completion(episodeName)
        }.resume()
    }
    
    func fetchImage(from urlString: String, completion: @escaping (Data?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching image: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            completion(data)
        }.resume()
    }
}
