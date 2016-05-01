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
    
    let MIN_TEMPERATURE = -50
    let MAX_TEMPERATURE = 350
    let MAX_INDEX = 400
    let R_ADC = 13000
    let MAX_ADC = 4095
    
    var tcSocket : GCDAsyncSocket?
    var tcpIP = ""
    //port = 5001
    let tcpPort:UInt16 = 5001
    
    @IBAction func startButton(sender: AnyObject) {
        let str: NSString = "AT+0=0x06,+CMD 0x05 0x00\r\n"
//        tcSocket!.readDataWithTimeout(-1.0, tag: 0)
        tcSocket!.writeData(str.dataUsingEncoding(NSUTF8StringEncoding), withTimeout: -1.0, tag: 0)
    }
    
    @IBAction func stopButton(sender: AnyObject) {
        let str: NSString = "AT+0=0x06,+CMD 0x06 0x00\r\n"
        //        tcSocket!.readDataWithTimeout(-1.0, tag: 0)
        tcSocket!.writeData(str.dataUsingEncoding(NSUTF8StringEncoding), withTimeout: -1.0, tag: 0)
    }
    @IBAction func setRuleButton(sender: AnyObject) {
        let str: NSString = "AT+0=0x06,+CMD 0x04 0x13 data\r\n"
        //        tcSocket!.readDataWithTimeout(-1.0, tag: 0)
        tcSocket!.writeData(str.dataUsingEncoding(NSUTF8StringEncoding), withTimeout: -1.0, tag: 0)
    }
    @IBAction func beatSignalButton(sender: AnyObject) {
        let str: NSString = "AT+5\n"
        //        tcSocket!.readDataWithTimeout(-1.0, tag: 0)
        tcSocket!.writeData(str.dataUsingEncoding(NSUTF8StringEncoding), withTimeout: -1.0, tag: 0)
    }
    
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
        
        let str: NSString = "AT+2=;\r\n"
        sock.readDataWithTimeout(-1.0, tag: 0)
        sock.writeData(str.dataUsingEncoding(NSUTF8StringEncoding), withTimeout: -1.0, tag: 0)
    }

    func socket(sock: GCDAsyncSocket!, didReadData data: NSData!, withTag tag: Int) {
        print("didReadData")
        print(NSString(data: data, encoding: NSUTF8StringEncoding))
        
        sock.readDataWithTimeout(-1.0, tag: 0)
    }
    
    
    
//     >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    

    func getADCFromTemperature (temperature: Double) -> Int {
        let intTemperature1 = Int(floor(temperature))
        let intTemperature2 = Int(floor(temperature))
        var r: Double = getRIntegerFromTemperature(intTemperature1)
        let r2: Double = getRIntegerFromTemperature(intTemperature2)
        r += ((temperature - Double(floor(temperature))) * (r2 - r))
        let adc = Double(r) / (r+Double(R_ADC)) * Double(MAX_ADC)
        return Int(round(adc))
    }
    
    func getRIntegerFromTemperature(temperature: Int) -> Double {
        var queTemperature = temperature
        queTemperature += -MIN_TEMPERATURE
        if queTemperature < 0 {
            queTemperature = 0
        }
        if queTemperature > MAX_INDEX {
            queTemperature > MAX_INDEX
        }
        return Double(R_VALUE_TABLE[queTemperature])
    }
    
//    private static double getRIntegerFromTemerpature(int temperature) {
//    
//    temperature+= -MIN_TEMPERATURE;
//    if(temperature<0) {
//    temperature =0;
//    }
//    if(temperature>MAX_INDEX) {
//    temperature = MAX_INDEX;
//    }
//    return R_VALUE_TABLE[temperature];
//    }
 
    
    
    func getTemperatureFromADC(adc: Int) -> Double {
        return getTemperature(getRFromADC(adc))
    }

    func getTemperature(R: Double) -> Double {
        var targetTemperature = -100;
        if R >= Double(R_VALUE_TABLE[0]) {
            return Double(MIN_TEMPERATURE)
        }
        if R <= Double(R_VALUE_TABLE[MAX_INDEX]) {
            return Double(MAX_TEMPERATURE)
        }
        
        var i = 1
        for (i = 1; i<MAX_INDEX; i++) {
            if (R > Double(R_VALUE_TABLE[i]) || compareThis(R, second: Double(R_VALUE_TABLE[i])) == 0) {
                targetTemperature = i + MIN_TEMPERATURE
                break
            }
        }
        print("i = \(i)")
        
        if i == (MAX_INDEX-1) {
            return 350;
        }
        //
        let minusTargetTemperatureAnswer = ((R - Double(R_VALUE_TABLE[i])) / (Double(R_VALUE_TABLE[i-1]) - Double(R_VALUE_TABLE[i])))
        
        
        
        return (Double(targetTemperature) - minusTargetTemperatureAnswer)
    }
    
    func compareThis (first : Double, second : Double) -> Int {
        var compareAnswer = 1
        if first == second {
            compareAnswer = 0
        }
        return compareAnswer
    }

    
    
    
    func getRFromADC(adc: Int) -> Double {
        if adc == 0  {
            return 0.00001;
        }
        return ( Double(adc * R_ADC) / Double(MAX_ADC - adc))
    }
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    let R_VALUE_TABLE: [Float] = [7002352, 6524898, 6082785, 5673204, 5293581, 4941561, 4614987, 4311880, 4030426, 3768962, 3525958, 3300013, 3089836, 2894243, 2712144, 2542534, 2384492, 2237167, 2099774, 1971592, 1851955, 1740247, 1635902, 1538396, 1447244, 1361999, 1282249, 1207609, 1137726, 1072272, 1010944, 953459.7, 899559.1, 849000.3, 801558.9, 757026.7, 715210.6, 675931, 639021.2, 604326.3, 571702.2, 541014.7, 512139.2, 484959.6, 459367.8, 435263.1, 412551.7, 391146.1, 370964.7, 351931.5, 333975.5, 317102.9, 301179.3, 286146.4, 271949.5, 258537.8, 245863.7, 233882.6, 222553.1, 211836.4, 201696, 192098, 183010.5, 174403.7, 166249.7, 158522.3, 151197.1, 144250.9, 137662.3, 131411, 125478, 119845.5, 114496.7, 109415.9, 104588.3, 100000, 95637.96, 91489.86, 87544.14, 83789.91, 80216.92, 76815.52, 73576.61, 70491.61, 67552.47, 64751.55, 62081.68, 59536.08, 57108.35, 54792.47, 52582.73, 50473.74, 48460.43, 46538, 44701.89, 42947.81, 41271.71, 39669.74, 38138.27, 36673.86, 35273.24, 33945.08, 32672.55, 31453.11, 30284.32, 29163.89, 28089.62, 27059.43, 26071.35, 25123.49, 24214.04, 23341.32, 22503.69, 21699.6, 20927.59, 20186.24, 19474.23, 18790.28, 18133.18, 17501.76, 16894.93, 16311.64, 15750.88, 15211.7, 14693.19, 14194.46, 13714.71, 13253.12, 12808.95, 12381.47, 11969.99, 11573.86, 11192.44, 10825.13, 10471.35, 10130.57, 9802.245, 9485.883, 9181.001, 8887.14, 8603.861, 8330.743, 8067.386, 7813.404, 7568.429, 7332.108, 7104.105, 6884.095, 6671.77, 6466.833, 6269, 6083.614, 5904.497, 5731.413, 5564.134, 5402.443, 5246.133, 5095.003, 4948.862, 4807.526, 4670.818, 4538.57, 4410.618, 4286.806, 4166.986, 4051.013, 3938.748, 3830.06, 3724.821, 3622.907, 3524.203, 3428.594, 3335.971, 3246.231, 3159.273, 3075, 2993.319, 2914.141, 2837.38, 2762.952, 2690.78, 2620.785, 2552.894, 2487.036, 2423.142, 2361.148, 2300.989, 2242.604, 2185.935, 2130.924, 2077.518, 2025.664, 1975.31, 1926.409, 1878.912, 1832.775, 1787.953, 1744.405, 1702.089, 1660.967, 1621, 1581.707, 1543.519, 1506.4, 1470.318, 1435.239, 1401.133, 1367.968, 1335.716, 1304.348, 1273.837, 1244.157, 1215.281, 1187.186, 1159.847, 1133.242, 1107.349, 1082.145, 1057.611, 1033.725, 1010.469, 987.8244, 965.7722, 944.2954, 923.3768, 903, 883.1492, 863.8091, 844.9647, 826.6016, 808.7061, 791.2645, 774.2638, 757.6914, 741.5351, 725.783, 710.4237, 695.446, 680.8392, 666.5929, 652.6971, 639.1418, 625.9176, 613.0154, 600.4262, 588.1415, 576.1528, 564.452, 553.0314, 541.8831, 531, 520.6407, 510.5233, 500.6415, 490.9888, 481.5592, 472.3468, 463.3459, 454.5507, 445.956, 437.5564, 429.3469, 421.3225, 413.4784, 405.8099, 398.3126, 390.982, 383.8138, 376.8039, 369.9483, 363.243, 356.6842, 350.2683, 343.9917, 337.8508, 331.8424, 325.963, 320.2094, 314.5787, 309.0677, 303.6735, 298.3932, 293.2241, 288.1634, 283.2086, 278.357, 273.6062, 268.9537, 264.3972, 259.9344, 255.5631, 251.2811, 247.0862, 242.9765, 238.9499, 235.0044, 231.1382, 227.3495, 223.6364, 219.9972, 216.4301, 212.9335, 209.5059, 206.1455, 202.8509, 199.6206, 196.4532, 193.3471, 190.3011, 187.3137, 184.3837, 181.5097, 178.6906, 175.9251, 173.2121, 170.5502, 167.9386, 165.3759, 162.8613, 160.3935, 157.9717, 155.5947, 153.2617, 150.9717, 148.7238, 146.517, 144.3504, 142.2234, 140.1349, 138.0841, 136.0704, 134.0928, 132.1506, 130.2432, 128.3697, 126.5295, 124.7218, 122.9461, 121.2016, 119.4876, 117.8037, 116.1491, 114.5232, 112.9255, 111.3554, 109.8124, 108.2958, 106.8052, 105.3401, 103.8998, 102.484, 101.0922, 99.7238, 98.3784, 97.0556, 95.7549, 94.4759, 93.2181, 91.9812, 90.7646, 89.5682, 88.3913, 87.2338, 86.0951, 84.975, 83.873, 82.7889, 81.7223, 80.6728, 79.6402, 78.6241, 77.6242, 76.6402, 75.6718, 74.7187, 73.7807, 72.8574, 71.9485, 71.0539, 70.1732, 69.3062, 68.4527, 67.6123, 66.7849, 65.9702, 65.168, 64.3781, 63.6002, 62.8341, 62.0796, 61.3365, 60.6047, 59.8838, 59.1737, 58.4743, 57.7852, 57.1064, 56.4377, 55.7788, 55.1297, 54.4901]

}
