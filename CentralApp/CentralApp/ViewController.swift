//
//  ViewController.swift
//  CentralApp
//
//  Created by Lê Minh Thiện on 03/06/2025.
//

import Cocoa
import CoreBluetooth

class ViewController: NSViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    @IBOutlet weak var lblState: NSTextField!
    @IBOutlet weak var lblMessage: NSTextField!
    @IBOutlet weak var imvLed: NSImageView!
    
    var centralManager: CBCentralManager!
    var discoveredPeripheral: CBPeripheral?
    let serviceUUID = CBUUID(string: "1234")
    let characteristicUUID = CBUUID(string: "ABCD")
    let characteristicUUIDLed = CBUUID(string: "CDEF")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            centralManager.scanForPeripherals(withServices: [serviceUUID], options: nil)
            print("Scanning for peripherals")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("Discovered \(peripheral.name ?? "unknown")")
        discoveredPeripheral = peripheral
        centralManager.stopScan()
        peripheral.delegate = self
        centralManager.connect(peripheral, options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        lblState.stringValue = "connected";
        peripheral.discoverServices([serviceUUID])// Chỉ connect đúng service
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        for service in services {
            peripheral.discoverCharacteristics([characteristicUUID, characteristicUUIDLed], for: service)//Chỉ lấy đúng gói tin cần nhận
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        for characteristic in characteristics {
            if characteristic.uuid == characteristicUUID || characteristic.uuid == characteristicUUIDLed {
                peripheral.readValue(for: characteristic)
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        print("Central subscribed to characteristic: \(characteristic.uuid)")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if(characteristic.uuid == characteristicUUID) {
            if let value = characteristic.value, let message = String(data: value, encoding: .utf8) {
                print("Received: \(message)")
                lblMessage.stringValue = message;
            }
        } else if(characteristic.uuid == characteristicUUIDLed) {
            if let value = characteristic.value, let message = String(data: value, encoding: .utf8) {
                if message == "RED_LED" {
                    imvLed.image = NSImage(named: "red_led")
                } else if message == "BLUE_LED" {
                    imvLed.image = NSImage(named: "blue_led")
                } else if message == "ORANGE_LED" {
                    imvLed.image = NSImage(named: "orange_led")
                }
            }
        }
    }
}
