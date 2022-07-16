//
//  CoinManager.swift
//  ByteCoin

import Foundation

protocol CoinManagerDelegate {
    func didUpdatePrice(price:String,currency:String)
    func didFaillWithError(error:Error)
}

struct CoinManager {
    
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC"
    let apiKey = "YOURCoinApiKey"
    
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]
    
    var delegate : CoinManagerDelegate?

    func getCoinPrice(for currency:String){
        let urlString = "\(baseURL)/\(currency)?apikey=\(apiKey)"
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            
            let task = session.dataTask(with: url) { data, response, error in
                if error != nil {
                    self.delegate?.didFaillWithError(error: error!)
                    return
                }
//                let dataString = String(data: data!, encoding:  .utf8)
                if let  safeprice = data {
                    if let bitcoinPrice = self.parseJson(safeprice) {
                        let priceString = String(format: "%.2f", bitcoinPrice)
                        
                        self.delegate?.didUpdatePrice(price: priceString, currency: currency)
                    }
                }
                
            }
            task.resume()
        }

    }
    
    func parseJson(_ data: Data) -> Double? {
        let decoder = JSONDecoder()
        do{
            let decodedData = try decoder.decode(CoinData.self, from: data)
            let price = decodedData.rate
            return price
        }
        catch {
            delegate?.didFaillWithError(error: error)
            return nil
        }
    }
}
