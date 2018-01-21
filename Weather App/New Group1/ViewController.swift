//
//  ViewController.swift
//  Weather App
//
//  Created by Sahil Kapal on 2018-01-20.
//  Copyright © 2018 Sahil Kapal. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class ViewController: UIViewController, CLLocationManagerDelegate {

    // IBOutlets:
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet var viewBG: UIView!
    
    let locationManager = CLLocationManager()
    let weatherDataModel = WeatherDataModel()
    
    
    // Consts:
    let WEATHER_URL = "http:/api.openweathermap.org/data/2.5/weather"
    let APP_ID = "8694f514d713d8dc4d77bd2f8e1d4de7"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        // Do any additional setup after loading the view, typically from a nib.
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count-1] //gives most upto date location
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            let lat = String(location.coordinate.latitude)
            let lon = String(location.coordinate.longitude)
            let params:[String:String] = ["lat":lat, "lon":lon, "appid":APP_ID]
            getWeatherData(url: WEATHER_URL, parameters: params)
        }
    }
    func getWeatherData(url: String, parameters: [String:String] ){
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON { response in
            if response.result.isSuccess {
                let weatherJSON:JSON = JSON(response.result.value!)
                //print(weatherJSON)
                self.updateWeatherData(json: weatherJSON)
                self.updateUI()

            }else {
                print("error \(String(describing: response.result.error))")
                self.cityLabel.text = "Connection issues"
            }
            
        }
    }
    
    func updateWeatherData(json: JSON) {
        weatherDataModel.temp = Int(json["main"]["temp"].double! - 273.15)
        weatherDataModel.city = json["name"].stringValue
        weatherDataModel.cond = json["weather"][0]["id"].intValue
        weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.cond)
    }
    
    func updateUI() {
        cityLabel.text = weatherDataModel.city
        tempLabel.text = String(weatherDataModel.temp)
        if weatherDataModel.weatherIconName != "" {
            weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

