import Foundation
import UIKit

protocol NetworkProtocol {
    var observation: NSKeyValueObservation? { get }
    var networkProgressSignal: Box<Double> { get }

    func dataRequest(url: String, completion: @escaping (Data?, HTTPURLResponse, Error?) -> Void)
    func loadPreviewImage(url: String) -> Data
}

class Network: NetworkProtocol {
    var observation: NSKeyValueObservation?
    var networkProgressSignal: Box<Double> = Box(0.0)
    
    deinit {
        observation?.invalidate()
    }

    func dataRequest(url: String , completion: @escaping (Data?, HTTPURLResponse, Error?) -> Void) { //
        guard let url = URL(string: url) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("OAuth \(Token.value)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error { completion(nil, response as? HTTPURLResponse ?? HTTPURLResponse(), error); return }
            guard let data = data else { return }
            completion(data, response as! HTTPURLResponse, nil)
        }
        
        observation = task.progress.observe(\.fractionCompleted) { progress, _ in
            DispatchQueue.main.async {
                self.networkProgressSignal.value = progress.fractionCompleted
            }
        }
        
        task.resume()

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
            loadedImage = data
            semaphore.signal()
        }.resume()
        semaphore.wait()
        return loadedImage
    }
}

