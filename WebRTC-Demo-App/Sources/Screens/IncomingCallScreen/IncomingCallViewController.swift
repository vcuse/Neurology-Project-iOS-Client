import UIKit

@available(iOS 13.0, *)
class IncomingCallViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    private func setupUI() {
        // Set background color
        view.backgroundColor = UIColor.gray.withAlphaComponent(0.8)
        
        // Create and configure the label
        let incomingCallLabel = UILabel()
        incomingCallLabel.text = "Incoming Call..."
        incomingCallLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        incomingCallLabel.textColor = .white
        incomingCallLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(incomingCallLabel)
        
        // Create and configure the answer button
        let answerButton = UIButton(type: .system)
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 50, weight: .regular, scale: .large)
        answerButton.setImage(UIImage(systemName: "phone.circle", withConfiguration: largeConfig), for: .normal)
        answerButton.tintColor = .green
        answerButton.translatesAutoresizingMaskIntoConstraints = false
        answerButton.addTarget(self, action: #selector(answerButtonTapped), for: .touchUpInside)
        view.addSubview(answerButton)
        
        // Create and configure the decline button
        let declineButton = UIButton(type: .system)
        declineButton.setImage(UIImage(systemName: "phone.down.circle.fill", withConfiguration: largeConfig), for: .normal)
        declineButton.tintColor = .red
        declineButton.translatesAutoresizingMaskIntoConstraints = false
        declineButton.addTarget(self, action: #selector(declineButtonTapped), for: .touchUpInside)
        view.addSubview(declineButton)
        
        // Set up constraints
        NSLayoutConstraint.activate([
            // Incoming Call Label
            incomingCallLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            incomingCallLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Answer Button
            answerButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            answerButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            answerButton.widthAnchor.constraint(equalToConstant: 100),
            answerButton.heightAnchor.constraint(equalToConstant: 100),
            
            // Decline Button
            declineButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            declineButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            declineButton.widthAnchor.constraint(equalToConstant: 100),
            declineButton.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    @objc private func answerButtonTapped() {
        // Handle answer button tap
        print("Answer button tapped")
    }
    
    @objc private func declineButtonTapped() {
        // Handle decline button tap
        print("Decline button tapped")
    }
}
