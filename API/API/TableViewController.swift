//
//  ViewController.swift
//  API
//
//  Created by Joaquin Luis Bala on 3/22/23.
//
import UIKit

class TableViewController: UITableViewController {

    var searchResponse: SearchResponse?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(NSLocalizedString("tableview_title", comment: ""))
        makeAPICall { searchResponse in
            self.searchResponse = searchResponse
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = searchResponse?.Search[indexPath.row].name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResponse?.Search.count ?? 0
    }
    
    func makeAPICall(completion: @escaping (SearchResponse?) -> Void) {
        print("start API call")
        
        let domain = "https://pokeapi.co/api/v2/type"
        
        guard let url = URL(string:"\(domain)") else {
            completion(nil)
            return
        }
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            var searchResponse: SearchResponse?
            defer {completion(searchResponse)}
            if let error = error {
                print("Error with API call: \(error)")
                return
            }
//            200 means that it's connected
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode)
            else {
                print("Error with the response (\(String(describing: response))")
                return
            }
//            this code returns a long unstructured string
//            if let data = data,
//            let dataString = String(data: data, encoding: String.Encoding.utf8){
//            print(dataString)
            if let data = data,
               let response = try? JSONDecoder().decode(SearchResponse.self, from: data)
            {
                print("success")
                searchResponse = response
            } else {
                print("Something is wrong with decoding, probably.")
            }
        }
        task.resume()
    }
}

struct SearchResponse: Codable {
    let count: Int
    let Search: [Pokemon]
    enum CodingKeys: String, CodingKey {
        case count
        case Search = "results"
    }
}

struct Pokemon: Codable {
    let name: String
    let url: String
    
//      just type "CodingKey" for this to show
    enum CodingKeys: String, CodingKey {
        case name = "name"
        case url = "url"
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.url = try container.decode(String.self, forKey: .url)
      
    }

}
