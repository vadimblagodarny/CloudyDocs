import Foundation
import UIKit

protocol NetworkProtocol {
    func dataRequest(url: String, completion: @escaping (Data?, HTTPURLResponse, Error?) -> Void)
    func loadPreviewImage(url: String, completion: @escaping (UIImage?) -> Void)
}

class Network: NetworkProtocol {
    func dataRequest(url: String , completion: @escaping (Data?, HTTPURLResponse, Error?) -> Void) { //
        guard let url = URL(string: url) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("OAuth \(Token.value)", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error { completion(nil, response as! HTTPURLResponse, error); return }
            guard let data = data else { return }
            completion(data, response as! HTTPURLResponse, nil)
        }.resume()
    }

    func loadPreviewImage(url: String, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: url) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("OAuth \(Token.value)", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else { return }
            completion(UIImage(data: data))
        }.resume()
    }
}
