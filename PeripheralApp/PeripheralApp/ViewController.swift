import UIKit
import CoreBluetooth

class ViewController: UIViewController {
    
    @IBOutlet private weak var tfText: UITextField!
    @IBOutlet private weak var lblState: UILabel!
    
    private var peripheralManager: CBPeripheralManager? // Service
    private var transferCharacteristic: CBMutableCharacteristic? // Chuyển dữ liệu
    private var transferCharacteristicLED: CBMutableCharacteristic? // Điều khiển LED
    private let serviceUUID = CBUUID(string: "1234")
    private let characteristicUUID = CBUUID(string: "ABCD")
    private let characteristicUUIDLed = CBUUID(string: "CDEF")// Nhớ mã này gồm 4kí tự or là chuôix theo format giống này VD: 0000abcd-0000-1000-8000-00805f9b34fb
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configService()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        collapse()
    }
    
    @IBAction func actionSend(_ sender: Any) {
        let msg = tfText.text ?? ""
        send(msg)
        collapse()
    }
    
    @IBAction func actionRedLed(_ sender: Any) {
        // Điều khiển LED đỏ
        signal(.red)
    }
    
    @IBAction func actionBlueLed(_ sender: Any) {
        // Điều khiển LED xanh
        signal(.blue)
    }
    
    @IBAction func actionOrangeLed(_ sender: Any) {
        // Điều khiển LED cam
        signal(.orange)
    }
    
    private func configService() {
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }
    
    private func signal(_ led: LedType) {
        guard let characteristic = transferCharacteristicLED,
              let peripheralManager = peripheralManager,
              peripheralManager.isAdvertising else {
            alert(message: "Peripheral not ready or not advertising")
            return
        }
        
        let data = led.rawValue.data(using: .utf8)!
        
        // Gửi dữ liệu qua characteristic
        let success = peripheralManager.updateValue(
            data,
            for: characteristic,
            onSubscribedCentrals: nil
        )
        
        if success {
            print("Success")
        } else {
            alert(message: "Send failed")
        }
    }
    
    private func send(_ message: String) {
        guard let characteristic = transferCharacteristic,
              let peripheralManager = peripheralManager,
              peripheralManager.isAdvertising else {
            alert(message: "Peripheral not ready or not advertising")
            return
        }
        
        let data = message.data(using: .utf8)!
        
        // Gửi dữ liệu qua characteristic
        let success = peripheralManager.updateValue(
            data,
            for: characteristic,
            onSubscribedCentrals: nil
        )
        
        if success {
            alert(title: "Success", message: "Sent: \(message)")
        } else {
            alert(message: "Send failed")
        }
    }
    
    private func alert(title: String = "Error", message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        
        if let viewController = UIApplication.shared.keyWindow?.rootViewController {
            viewController.present(alertController, animated: true, completion: nil)
        }
    }
    
    private func collapse() {
        view.endEditing(true)
    }
}

extension ViewController: CBPeripheralManagerDelegate {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        //Kiểm tra xem đang có mở thiết bị ngoại vi
        if peripheral.state == .poweredOn {
            
            // Tạo Characteristic cho dữ liệu
            transferCharacteristic = CBMutableCharacteristic(
                type: characteristicUUID,
                properties: [.read, .notify],
                value: nil,
                permissions: [.readable]
            )
            
            // Tạo Characteristic cho điều khiển LED
            transferCharacteristicLED = CBMutableCharacteristic(
                type: characteristicUUIDLed,
                properties: [.read, .notify],
                value: nil,
                permissions: [.readable]
            )
            
            // Tạo Service và thêm tất cả characteristics vào service
            let service = CBMutableService(type: serviceUUID, primary: true)
            service.characteristics = [transferCharacteristic!, transferCharacteristicLED!]
            
            peripheralManager?.add(service)
            peripheralManager?.startAdvertising([
                CBAdvertisementDataServiceUUIDsKey: [serviceUUID],
                CBAdvertisementDataLocalNameKey: "GaCon"
            ])
            
            print("Peripheral ready and advertising")
        } else {
            print("Peripheral state: \(peripheral.state.rawValue)")
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        lblState.text = "Connected to: \(central.identifier)"
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic) {
        lblState.text = "Disconnected from: \(central.identifier)"
    }
}

enum LedType: String {
    case red = "RED_LED"
    case blue = "BLUE_LED"
    case orange = "ORANGE_LED"
}
