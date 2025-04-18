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
        NetworkManager.shared.fetchRandomCharacters { [weak self] newCharacters in
                    guard let self = self else { return }
                    
                    self.characters = newCharacters
                    self.tableView.reloadData()
                    
                    // If there was an error and no characters were fetched, show an alert
                    if newCharacters.isEmpty {
                        let alert = UIAlertController(title: "Error!", message: "Failed to load characters", preferredStyle: .alert)
                        let okButton = UIAlertAction(title: "OK", style: .default)
                        alert.addAction(okButton)
                        self.present(alert, animated: true)
                    }
                }
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
        
        cell.charachterImageView.loadImageFromURL(urlString: character.image)

        
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

        
                // Load image asynchronously
                if let imageUrl = URL(string: character.image) {
                    URLSession.shared.dataTask(with: imageUrl) { data, response, error in
                        if let data = data, let image = UIImage(data: data) {
                            DispatchQueue.main.async {
                                if let currentIndexPath = tableView.indexPath(for: cell),
                                   currentIndexPath == indexPath {
                                    cell.charachterImageView.image = image
                                }
                            }
                        }
                    }.resume()
                }
        
        
        
        return cell
    }
    
    
}
