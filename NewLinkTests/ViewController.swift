//
//  ViewController.swift
//  NewLinkTests
//
//  Created by Ted on 4/27/16.
//  Copyright © 2016 Ted.Company. All rights reserved.
//

import UIKit
import CocoaAsyncSocket


class ViewController: UIViewController, GCDAsyncUdpSocketDelegate {

    
    // 192.168.29.1
    let udpIP = "192.168.29.1"
    let udpPort:UInt16 = 5002
    var upSocket: GCDAsyncUdpSocket!
    var savedIP = ""
    
    
    @IBOutlet weak var idHere: UITextField!
    @IBOutlet weak var pwHere: UITextField!
    
    @IBAction func showIP_But(sender: AnyObject) {
        let str: NSString = "AT+2=;\r\n"
        print("sending: \(str)")
        upSocket.sendData(str.dataUsingEncoding(NSUTF8StringEncoding), withTimeout: -1.0, tag: 0)
        
        do {
            try upSocket.beginReceiving()
        } catch {
            print ("receive exception after query")
        }
        
    }
    
    @IBAction func linkTo_But(sender: AnyObject) {
        if let ssid = idHere?.text, pw = pwHere?.text {
            let str = "AT+1=\(ssid);\(pw);\r\n"
            print("sending: \(str)")
            upSocket.sendData(str.dataUsingEncoding(NSUTF8StringEncoding), withTimeout: -1.0, tag: 0)
           
            do {
                try upSocket.beginReceiving()
            } catch {
                print ("receive exception after linkup")
            }
        }
    }
    
    @IBAction func reboot_But(sender: AnyObject) {
        let str: NSString = "AT+9=;\r\n"
        print("sending: \(str)")
        upSocket.sendData(str.dataUsingEncoding(NSUTF8StringEncoding), withTimeout: -1.0, tag: 0)
       
        do {
            try upSocket.beginReceiving()
        } catch {
            print ("receive exception after reboot")
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        upSocket = GCDAsyncUdpSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
        
        do {
            try upSocket.connectToHost(udpIP, onPort: udpPort)
            try upSocket.enableBroadcast(true)
            try upSocket.bindToPort(udpPort)
            try upSocket.beginReceiving()
        } catch {
            print("initing exception")
        }
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func udpSocket(sock: GCDAsyncUdpSocket!, didReceiveData data: NSData!, fromAddress address: NSData!, withFilterContext filterContext: AnyObject!) {
        print("receiving data: ...")
        print(NSString(data: data, encoding: NSUTF8StringEncoding))
        if let str = NSString(data: data, encoding: NSUTF8StringEncoding) {
            let stringStr = String(str)
            let initIndexRef = str.rangeOfString("IP").length
            let endIndexRef = str.rangeOfString("\r").location
            let startingIndex = stringStr.startIndex.advancedBy(initIndexRef)
            let endIndex = stringStr.startIndex.advancedBy(endIndexRef)
            let fetchedIP = stringStr.substringFromIndex(startingIndex).substringToIndex(endIndex)
            if fetchedIP != "0.0.0.0" {
                savedIP = fetchedIP
                print(fetchedIP)
            } else {
                print("it's 0.0.0.0")
            }
        }
    }
    
    func udpSocket(sock: GCDAsyncUdpSocket!, didConnectToAddress address: NSData!) {

        do {
            try upSocket.beginReceiving()
        } catch {
            print ("begin receiving exception")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toTCP" {
            let destinationController = segue.destinationViewController as! TCPViewController
            destinationController.tcpIP = savedIP
        }

        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

}

