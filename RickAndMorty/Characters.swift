//
//  Characters.swift
//  RickyAndMorty
//
//  Created by Mammadgulu Novruzov on 15.04.25.
//

import Foundation

class Character {
    let id: Int
    let name: String
    let status: String
    let species: String
    let image: String
    let location: String
    let firstSeenEpisode: String
    
    init(id: Int, name: String, status: String, species: String, image: String, location: String, firstSeenEpisode: String) {
        self.id = id
        self.name = name
        self.status = status
        self.species = species
        self.image = image
        self.location = location
        self.firstSeenEpisode = firstSeenEpisode
        
    }
    
    
}
