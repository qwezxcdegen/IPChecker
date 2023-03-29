//
//  ViewController.swift
//  IPChecker
//
//  Created by Степан Фоминцев on 27.03.2023.
//

import UIKit
import MapKit

final class ViewController: UIViewController {
    
    // MARK: - Private IBOutlets
    @IBOutlet weak private var addressTextField: UITextField!
    @IBOutlet weak private var resultTextView: UITextView!
    @IBOutlet weak private var selfAddressLabel: UILabel!
    @IBOutlet weak private var mapView: MKMapView!
    
    // MARK: - Private properties
    private var selfAddress = ""
    private var isAddressHidden = true
    
    private var selfAddressHidden: String {
        var hiddenAddress = ""
        for char in selfAddress {
            if char == "." {
                hiddenAddress += "."
            } else {
                hiddenAddress += "*"
            }
        }
        return hiddenAddress
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchSelfAddress()
    }

    // MARK: - Private IBActions
    @IBAction private func checkButtonPressed(_ sender: UIButton) {
        guard let address = addressTextField.text else { return }
        view.endEditing(true)
        resultTextView.text = "Loading..."
        fetchAddressData(ipAddress: address)
    }
    
    @IBAction private func copyButtonPressed(_ sender: UIButton) {
        UIPasteboard.general.string = selfAddress
        present(UIAlertController(title: "Copied", message: nil, preferredStyle: .alert), animated: true)
        dismiss(animated: true)
    }
    
    @IBAction private func showIPPressed(_ sender: UIButton) {
        selfAddressLabel.text = isAddressHidden ? selfAddress : selfAddressHidden
        isAddressHidden.toggle()
    }
    
    // MARK: - Private Methods
    private func fetchAddressData(ipAddress: String) {
        guard let url = URL(string: "http://ip-api.com/json/\(ipAddress)?fields=country,countryCode,regionName,city,zip,timezone,org,query,lat,lon") else {  self.resultTextView.text = "Error"; return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data, error == nil else { self.resultTextView.text = "Error"; return }
            guard let addressData = try? JSONDecoder().decode(Address.self, from: data) else { self.resultTextView.text = "Error"; return }
            DispatchQueue.main.async {
                self.mapView.removeAnnotations(self.mapView.annotations)
                self.resultTextView.text = "Country: \(addressData.country)\nRegion: \(addressData.regionName)\nCity: \(addressData.city)\nPostal code: \(addressData.zip)\nTimezone: \(addressData.timezone)\nOrganization: \(addressData.org)"
                let annotation = MKPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2D(latitude: addressData.lat, longitude: addressData.lon)
                self.mapView.setCamera(MKMapCamera(lookingAtCenter: CLLocationCoordinate2D(latitude: addressData.lat, longitude: addressData.lon), fromDistance: 100000, pitch: 0, heading: 0), animated: true)
                self.mapView.addAnnotation(annotation)
            }
        }.resume()
    }
    
    private func fetchSelfAddress() {
        guard let url = URL(string: "http://ip-api.com/json/?fields=country,countryCode,regionName,city,zip,timezone,org,query,lat,lon") else { self.selfAddressLabel.text = "Error"; return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data, error == nil else { self.selfAddressLabel.text = "Error"; return }
            guard let addressData = try? JSONDecoder().decode(Address.self, from: data) else { self.selfAddressLabel.text = "Error"; return }
            DispatchQueue.main.async {
                self.selfAddress = addressData.query
                self.selfAddressLabel.text = self.selfAddressHidden
            }
        }.resume()
    }
}

