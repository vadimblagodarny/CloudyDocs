import Foundation
import UIKit

protocol NetworkProtocol {
    func dataRequest(url: String, completion: @escaping (Data?, HTTPURLResponse, Error?) -> Void)
    func loadPreviewImage(url: String) -> Data
}

class Network: NetworkProtocol {
    func dataRequest(url: String , completion: @escaping (Data?, HTTPURLResponse, Error?) -> Void) { //
        guard let url = URL(string: url) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("OAuth \(Token.value)", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error { completion(nil, response as? HTTPURLResponse ?? HTTPURLResponse(), error); return }
            guard let data = data else { return }
            completion(data, response as! HTTPURLResponse, nil)
        }.resume()
    }
    
    func loadPreviewImage(url: String) -> Data {
        let semaphore = DispatchSemaphore(value: 0)
        var loadedImage: Data = UIImage(systemName: "photo")!.pngData()!
        guard let url = URL(string: url) else { return Data() }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("OAuth \(Token.value)", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else { return }
//            loadedImage = UIImage(data: data) ?? UIImage(systemName: "photo")!
            loadedImage = data
            semaphore.signal()
        }.resume()
        semaphore.wait()
        return loadedImage
    }
}
