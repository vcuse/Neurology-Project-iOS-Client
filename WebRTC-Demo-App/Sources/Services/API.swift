import Foundation


class API {
    private let options: PeerJSOption

    init(options: PeerJSOption) {
        self.options = options
    }

    private func buildRequest(method: String) -> URLRequest? {
        let protocolScheme = options.secure ? "https" : "http"
        let urlString = "\(protocolScheme)://\(options.host):\(options.port)\(options.path)\(options.key)/\(method)"
        guard let url = URL(string: urlString) else {
            return nil
        }
        
        return URLRequest(url: url)
    }

    func retrieveId(completion: @escaping (Result<String, Error>) -> Void) {
        guard let request = buildRequest(method: "id") else {
            completion(.failure(NSError(domain: "com.yourapp.APIError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "com.yourapp.APIError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])))
                return
            }

            if httpResponse.statusCode != 200 {
                completion(.failure(NSError(domain: "com.yourapp.APIError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Error. Status: \(httpResponse.statusCode)"])))
                return
            }

            if let data = data, let id = String(data: data, encoding: .utf8) {
                completion(.success(id))
            } else {
                completion(.failure(NSError(domain: "com.yourapp.APIError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid data"])))
            }
        }

        task.resume()
    }

    // Add your listAllPeers() method here following a similar pattern
}
