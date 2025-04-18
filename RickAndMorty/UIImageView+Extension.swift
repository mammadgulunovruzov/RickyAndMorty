import UIKit

extension UIImageView {
    // MARK: - Image Loading with Shimmer
    
    func loadImageFromURL(urlString: String?, defaultImage: UIImage? = nil) {
        self.image = nil
        self.subviews.forEach { $0.removeFromSuperview() }
        
        // Add shimmer effect view
        let shimmerView = createShimmerView()
        self.addSubview(shimmerView)
        shimmerView.frame = self.bounds
        
        // Check for valid URL string
        guard let urlString = urlString, let url = URL(string: urlString) else {
            shimmerView.removeFromSuperview()
            showDefaultView(defaultImage: defaultImage)
            return
        }
        
        // Create URLSession task
        let task = URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                // Remove shimmer
                shimmerView.removeFromSuperview()
                
                // Handle errors
                if error != nil || data == nil {
                    self.showDefaultView(defaultImage: defaultImage)
                    return
                }
                
                // Create image from data
                if let data = data, let image = UIImage(data: data) {
                    self.image = image
                } else {
                    self.showDefaultView(defaultImage: defaultImage)
                }
            }
        }
        
        // Start the task
        task.resume()
    }
    
    // MARK: - Private Methods
    
    private func createShimmerView() -> UIView {
        let shimmerContainer = UIView(frame: self.bounds)
        shimmerContainer.tag = 100 // Tag for identification
        shimmerContainer.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
        
        // Create animation layer
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = shimmerContainer.bounds
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        
        // Light gray to white to light gray gradient
        let lightColor = UIColor.lightGray.withAlphaComponent(0.2).cgColor
        let darkColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        
        gradientLayer.colors = [lightColor, darkColor, lightColor]
        gradientLayer.locations = [0.0, 0.5, 1.0]
        
        // Configure animation
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [-1.0, -0.5, 0.0]
        animation.toValue = [1.0, 1.5, 2.0]
        animation.duration = 1.5
        animation.repeatCount = .infinity
        
        // Apply animation
        gradientLayer.add(animation, forKey: "shimmerAnimation")
        shimmerContainer.layer.addSublayer(gradientLayer)
        
        return shimmerContainer
    }
    
    private func showDefaultView(defaultImage: UIImage?) {
        // Remove any existing subviews
        self.subviews.forEach { $0.removeFromSuperview() }
        
        // If default image provided, use it
        if let defaultImage = defaultImage {
            self.image = defaultImage
            return
        }
        
        // Otherwise, create a placeholder view
        let placeholderView = UIView(frame: self.bounds)
        placeholderView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
        
        // Add an icon in the center
        let iconView = UIImageView(image: UIImage(systemName: "photo"))
        iconView.tintColor = .gray
        iconView.translatesAutoresizingMaskIntoConstraints = false
        
        placeholderView.addSubview(iconView)
        self.addSubview(placeholderView)
        
        NSLayoutConstraint.activate([
            iconView.centerXAnchor.constraint(equalTo: placeholderView.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: placeholderView.centerYAnchor),
            iconView.widthAnchor.constraint(equalTo: placeholderView.widthAnchor, multiplier: 0.3),
            iconView.heightAnchor.constraint(equalTo: iconView.widthAnchor)
        ])
    }
}
