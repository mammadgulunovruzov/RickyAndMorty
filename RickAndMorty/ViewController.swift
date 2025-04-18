import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    
    var characters: [Character] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        getData()
        
        // Create a button
        let iconButton = UIButton(type: .custom)
        let image = UIImage(named: "rickandmortyIcon")?.withRenderingMode(.alwaysOriginal)
        iconButton.setImage(image, for: .normal)
        
        // Resize and style it
        iconButton.frame = CGRect(x: 0, y: 0, width: 32, height: 32)
        iconButton.imageView?.contentMode = .scaleAspectFit
        iconButton.addTarget(self, action: #selector(didTapLeftBarButton), for: .touchUpInside)
        
        // Wrap it in a UIBarButtonItem
        let barButton = UIBarButtonItem(customView: iconButton)
        navigationItem.leftBarButtonItem = barButton
    }
    
    @objc func didTapLeftBarButton() {
        getData()
    }
    
    func getData() {
        let randomIds = (1...826).shuffled().prefix(10)
        let idString = randomIds.map { String($0) }.joined(separator: ",")
        let urlString = "https://rickandmortyapi.com/api/character/\(idString)"
        
        guard let url = URL(string: urlString) else { return }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Error!", message: error.localizedDescription, preferredStyle: .alert)
                    let okButton = UIAlertAction(title: "OK", style: .default)
                    alert.addAction(okButton)
                    self.present(alert, animated: true)
                }
                return
            }
            
            if let data = data {
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
                                
                                URLSession.shared.dataTask(with: episodeUrl) { episodeData, _, _ in
                                    var episodeName = "Unknown"
                                    
                                    if let episodeData = episodeData {
                                        if let episodeJSON = try? JSONSerialization.jsonObject(with: episodeData, options: []) as? [String: Any],
                                           let fetchedEpisodeName = episodeJSON["name"] as? String {
                                            episodeName = fetchedEpisodeName
                                        }
                                    }
                                    
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
                                    
                                }.resume()
                            }
                        }
                        
                        dispatchGroup.notify(queue: .main) {
                            self.characters = newCharacters
                            self.tableView.reloadData()
                        }
                    }
                    
                } catch {
                    print("JSON parsing error: \(error.localizedDescription)")
                }
            }
        }
        
        task.resume()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return characters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CharacterCell
        let character = characters[indexPath.row]
        
        cell.nameLabel.text = character.name
        cell.lastLocationLabel.text = character.location
        cell.firstSeenLocationLabel.text = character.firstSeenEpisode
        
        cell.contentView.layer.cornerRadius = 16
        cell.contentView.layer.masksToBounds = true
        
        // Set a placeholder image
        if let imageUrl = URL(string: character.image) {
            cell.charachterImageView.sd_cancelCurrentImageLoad()
            cell.charachterImageView.sd_setImage(with: imageUrl, placeholderImage: UIImage(systemName: "person.fill"))
        }
        
        let status = character.status.lowercased()
        let color: UIColor = status == "dead" ? .red : status == "alive" ? .green : .gray

        let config = UIImage.SymbolConfiguration(pointSize: 10) 
        let image = UIImage(systemName: "circle.fill", withConfiguration: config)?
            .withTintColor(color, renderingMode: .alwaysOriginal)

        let attachment = NSTextAttachment()
        attachment.image = image

        let dot = NSAttributedString(attachment: attachment)
        let text = NSMutableAttributedString(attributedString: dot)
        text.append(NSAttributedString(string: " \(character.status) - \(character.species)"))

        cell.statusSpeciesLabel.attributedText = text

        
        //        // Load image asynchronously
        //        if let imageUrl = URL(string: character.image) {
        //            URLSession.shared.dataTask(with: imageUrl) { data, response, error in
        //                if let data = data, let image = UIImage(data: data) {
        //                    DispatchQueue.main.async {
        //                        if let currentIndexPath = tableView.indexPath(for: cell),
        //                           currentIndexPath == indexPath {
        //                            cell.charachterImageView.image = image
        //                        }
        //                    }
        //                }
        //            }.resume()
        //        }
        
        
        
        return cell
    }
    
    
}
