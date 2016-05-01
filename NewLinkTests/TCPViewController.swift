//
//  TCPViewController.swift
//  NewLinkTests
//
//  Created by Ted on 5/1/16.
//  Copyright © 2016 Ted.Company. All rights reserved.
//

import UIKit
import CocoaAsyncSocket

class TCPViewController: UIViewController, GCDAsyncSocketDelegate {
    
    var tcSocket : GCDAsyncSocket?
    var tcpIP = ""
    //port = 5001
    let tcpPort:UInt16 = 5001
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tcSocket = GCDAsyncSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
        print("tcpIP: \(tcpIP)")
        
        do {
            try tcSocket!.connectToHost(tcpIP, onPort: tcpPort)
            print ("connecting")
        } catch {
            print ("exception")
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func socket(sock: GCDAsyncSocket!, didConnectToHost host: String!, port: UInt16) {
       
        print("didConnectToHost")
        
        let str: NSString = "AT+9=;\r\n"
      
        sock.readDataWithTimeout(-1.0, tag: 0)
        sock.writeData(str.dataUsingEncoding(NSUTF8StringEncoding), withTimeout: -1.0, tag: 0)
    }

    func socket(sock: GCDAsyncSocket!, didReadData data: NSData!, withTag tag: Int) {
        print("didReadData")
        print(NSString(data: data, encoding: NSUTF8StringEncoding))
        
        sock.readDataWithTimeout(-1.0, tag: 0)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
