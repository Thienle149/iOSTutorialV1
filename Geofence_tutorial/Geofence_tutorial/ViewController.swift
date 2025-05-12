//
//  ViewController.swift
//  Geofence_tutorial
//
//  Created by thien le on 12/5/25.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {
    
    @IBOutlet private weak var tfLat: UITextField!
    @IBOutlet private weak var tfLng: UITextField!
    @IBOutlet private weak var tfArea: UILabel!
    
    private var locationManager: CLLocationManager!;
    private var currentRegion: CLRegion?
    private var isFirstLocation: Bool = true;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configLocationManager()
    }
    
    //MARK: Action
    @IBAction func actionMonitor(_ sender: Any) {
        let lat = CLLocationDegrees(floatLiteral: Double(self.tfLat.text ?? "") ?? 0)
        let lng = CLLocationDegrees(floatLiteral: Double(self.tfLng.text ?? "") ?? 0)
        let radius = CLLocationDistance(floatLiteral: Double(tfArea.text ?? "") ?? 1)
        let monitorLocation = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        
        currentRegion = CLCircularRegion(center: monitorLocation, radius: radius, identifier: "Gacon")
        currentRegion?.notifyOnEntry = true //Nhận thông báo khi vào vùng định nghĩa.
        currentRegion?.notifyOnExit = true  //Nhận thông báo khi bước ra khỏi vùng định nghĩa.
        
        guard let currentRegion = currentRegion else { return }
        self.locationManager.startMonitoring(for: currentRegion)  //start theo dõi mới
    }

    //MARK: Private
    private func configLocationManager() {
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.startMonitoringSignificantLocationChanges()
    }
    
    private func loadCurrentLocation() {
        if(isFirstLocation) {
            guard let coordinate = self.locationManager.location?.coordinate else { return }
            self.tfLat.text = String(coordinate.latitude)
            self.tfLng.text = String(coordinate.longitude)
        }
        
        isFirstLocation = false
    }
    
    private func sendNotification(message: String) {
        let content = UNMutableNotificationContent()
        content.title = "Thông báo"
        content.body = message
        content.sound = .default

        // Kích hoạt sau 1 giây
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

        let request = UNNotificationRequest(identifier: "local_notification", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Notification error: \(error)")
            }
        }
        
        print(message)
        
    }
}

extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("didUpdateLocations");
        self.loadCurrentLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        self.sendNotification(message: "Bạn đang ở vùng bán kính cho phép")
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        self.sendNotification(message: "Bạn đang nằm ngoài vùng bán kính cho phép")
    }
}

