//
//  ViewController.swift
//  CombineTutorial
//
//  Created by Lê Minh Thiện on 20/05/2025.
//

import UIKit
import Combine

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        var cancellables = Set<AnyCancellable>()
        
        ///Just: Chỉ dùng để phát dữ liệu đúng 1 lần
        let publisher = Just("gacon")
        
        _ = publisher.sink { value in
            print("### value: \(value)")
        }
        
        ///PassThroughSubject: Dùng để phát dữ liệu nhiều lần thông qua hàm send. Đặc biết là ko lưu giá trị
        let subject = PassthroughSubject<String, Never>()
        
        subject.sink { value in
            print("### On value from PassthroughtSubject: \(value)")
        }.store(in: &cancellables)
        
        subject.send("test 1")
        subject.send("test 2")
    }


}

