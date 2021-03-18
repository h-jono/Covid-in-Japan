//
//  API.swift
//  CovidInJapan
//
//  Created by 城野 on 2021/03/13.
//

import Foundation

struct CovidAPI {
    
    static func getTotal(completion: @escaping (CovidInfo.Total) -> Void) {
        
        guard let url = URL(string: "https://covid19-japan-web-api.now.sh/api/v1/total") else { return }
        let request = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            // クライアントエラー
            if let error = error {
                print("Client error: \(error.localizedDescription)")
                return
            }
            // レスポンスとデータのエラー
            guard let data = data, let response = response as? HTTPURLResponse else {
                print("no data or no response")
                return
            }
            // status codeが200以外はサーバーサイドのエラー
            if response.statusCode == 200 {
                print(data)
            } else {
                print("Server error! Status code: \(response.statusCode)")
            }
            
            let result = try! JSONDecoder().decode(CovidInfo.Total.self, from: data)
            completion(result)
            
        }.resume()
    }
    
    static func getPrefecture(completion: @escaping ([CovidInfo.Prefecture]) -> Void){
        
        guard let url = URL(string: "https://covid19-japan-web-api.now.sh/api/v1/prefectures") else { return }
        let request = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            // クライアントエラー
            if let error = error {
                print("Client error: \(error.localizedDescription)")
                return
            }
            // レスポンスとデータのエラー
            guard let data = data, let response = response as? HTTPURLResponse else {
                print("no data or no response")
                return
            }
            // status codeが200以外はサーバーサイドのエラー
            if response.statusCode == 200 {
                print(data)
            } else {
                print("Server error! Status code: \(response.statusCode)")
            }
            
            let result = try! JSONDecoder().decode([CovidInfo.Prefecture].self, from: data)
            completion(result)
            
        }.resume()
        
        
    }
}
