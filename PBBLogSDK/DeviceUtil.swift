//
//  DeviceUtil.swift
//  PBBReaderForMac
//
//  Created by huoshuguang on 2016/11/26.
//  Copyright © 2016年 recomend. All rights reserved.
//

//import Cocoa
//import Foundation
//import IOKit
//import IOKit.usb
//import IOKit.serial

#if os(OSX)
    import Cocoa
    import Foundation
    import IOKit
    import IOKit.usb
    import IOKit.serial
#elseif os(iOS)
    import UIKit
#endif
class DeviceUtil: NSObject
{
    //软件进程信息
    var system = "Mac OS"
    var op_version = ""   //操作系统版本
    var processName = ""
    var threadId = ""
    var processIdentifier:Int32 = 0
    var hostName = ""
    var executionTime = ""
    //设备硬件
    var serial_number = "" //设备序列号
    var equip_host = ""   //机主信息
    var machine_model = "" //设备型号
    var device_info = ""  //设备参数
    var platform_UUID = "" //mac UUID
    
    var iterator = ""
    
    var cpu_type = ""
    var physical_memory = ""  //物理内存
    
    //用户信息
    var username = ""
    var account_name = ""
    var account_password = ""
    var network_type = ""
    var token = ""
    var login_type = LoginType.UnLogin.rawValue
    
    override init() {
        super.init()
        //分析硬件
        bySystem_profiler()
        if machine_model.contains(SystemType.iOS.rawValue) {
            system = SystemType.iOS.rawValue
        }
        //分析软件
        byProcessInfo()
    }
    
    func bySystem_profiler(){
        //判断是否已经持久化
        if UserDefaults.standard.bool(forKey: "kbySystem_profiler")
        {
            serial_number = UserDefaults.standard.object(forKey: "kserial_number") as! String
            machine_model = UserDefaults.standard.object(forKey: "kmachine_model") as! String
#if os(OSX)
            platform_UUID = UserDefaults.standard.object(forKey: "kplatform_UUID") as! String
            cpu_type = UserDefaults.standard.object(forKey: "kcpu_type") as! String
            physical_memory = UserDefaults.standard.object(forKey: "kphysical_memory") as! String
#else
            equip_host = UIDevice.current.name
            UserDefaults.standard.set(equip_host, forKey: "kequip_host")
#endif
            username = UserDefaults.standard.object(forKey: "kusername") as! String
            account_name = UserDefaults.standard.object(forKey: "kaccount_name") as! String
            account_password = UserDefaults.standard.object(forKey: "kaccount_password") as! String
            network_type = UserDefaults.standard.object(forKey: "knetwork_type") as! String
            token = UserDefaults.standard.object(forKey: "ktoken") as! String
            login_type = UserDefaults.standard.object(forKey: "klogin_type") as! String
        }
        else
        {
            #if os(OSX)
                let pipe = Pipe()
                let task = Process()
                task.launchPath = "/usr/sbin/system_profiler"
                task.arguments = ["-xml","SPHardwareDataType"]
                task.standardOutput = pipe
                task.launch()
                
                let outData = pipe.fileHandleForReading.readDataToEndOfFile()
                let outString = String.init(data: outData, encoding: .utf8)
                //开始解析
                parpserIterator((outString! as NSString).propertyList())
            #elseif os(iOS)
                machine_model = UIDevice.current.model
                UserDefaults.standard.set(machine_model, forKey: "kmachine_model")

                equip_host = UIDevice.current.name
                UserDefaults.standard.set(equip_host, forKey: "kequip_host")
                
                serial_number = (UIDevice.current.identifierForVendor?.uuidString)!
                UserDefaults.standard.set(serial_number, forKey: "kserial_number")
                
                UserDefaults.standard.set(true, forKey: "kbySystem_profiler")
            #endif
            
        }
    }
    
    func parpserIterator(_ data:Any)
    {
        if data is NSMutableArray {
            //
            let tmparr = data as! NSArray
            tmparr.enumerateObjects({ (obj, index, stop) in
                //
                if obj is NSDictionary
                {
                    let dic = obj as! NSDictionary
                    let keys:[String] = dic.allKeys as! [String]
                    for key in keys
                    {
                        if key == "_items"
                        {
                            parpserIterator(dic[key] as Any)
                            break
                        }
                        
                        if key == "machine_model"
                        {
                            machine_model = dic.object(forKey: key) as! String
                            UserDefaults.standard.set(machine_model, forKey: "kmachine_model")
                        }
                        
                        if key == "serial_number"
                        {
                            serial_number = dic.object(forKey: key) as! String
                            UserDefaults.standard.set(serial_number, forKey: "kserial_number")
                        }
                        
                        if key == "platform_UUID"
                        {
                            platform_UUID = dic.object(forKey: key) as! String
                            UserDefaults.standard.set(platform_UUID, forKey: "kplatform_UUID")
                        }
                        
                        if key == "cpu_type"
                        {
                            cpu_type = dic.object(forKey: key) as! String
                            UserDefaults.standard.set(cpu_type, forKey: "kcpu_type")
                        }
                        
                        if key == "physical_memory"
                        {
                            physical_memory = dic.object(forKey: key) as! String
                            UserDefaults.standard.set(physical_memory, forKey: "kphysical_memory")
                        }
                    }
                }
            })
            UserDefaults.standard.set(true, forKey: "kbySystem_profiler")
        }
    }
    
    //进程信息
    func byProcessInfo()
    {
        let process = ProcessInfo.processInfo
        processName = process.processName
        threadId = "?"
        processIdentifier = process.processIdentifier
        
        //可选的
        //Version 10.12.1 (Build 16B2555)
        op_version = "\(process.operatingSystemVersionString)"
        hostName = "\(process.hostName)"
        equip_host = ""//":\(process.userName)" 暂时支持10.12以上系统
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy HH:mm:ss:SSS"
        executionTime = dateFormatter.string(from: Date())
    }
    
    
#if os(OSX)
    var driver:io_object_t = 0
    var matchDictionary:CFDictionary! = IOServiceMatching("AppleAHCIDiskDriver")
    var kr:kern_return_t = 0
    func getIO()
    {
        //
        var iterator:UInt32 = 0
        kr = IOServiceGetMatchingServices(kIOMasterPortDefault, matchDictionary, &iterator)
        //(kIOMasterPortDefault, matchDictionary, &iterator)
        if kr  != kIOReturnSuccess
        {
            return
        }
        driver = IOIteratorNext(iterator)
        while (driver != 0)
        {
            //UnsafeMutablePointer<Unmanaged<CFMutableDictionary>?>:
            //http://stackoverflow.com/questions/31814292/swift2-correct-way-to-initialise-unsafemutablepointerunmanagedcfmutabledictio
            var properties:Unmanaged<CFMutableDictionary>?
            kr = IORegistryEntryCreateCFProperties(driver, &properties, kCFAllocatorDefault, 0)
            if kr == KERN_SUCCESS
            {
                if let properties = properties
                {
                    let dict = properties.takeRetainedValue() as NSDictionary
                    print(dict)
                }
            }
        }
    }
#endif
    
}

#if os(OSX)
extension DeviceUtil
{

    /*
     OC:http://stackoverflow.com/questions/20070333/obtain-model-identifier-string-on-os-x/30448607#30448607
     swift
     */
    func modelIdentifier()->String
    {
        var service:io_service_t
        service = IOServiceGetMatchingService(kIOMasterPortDefault,
                                              IOServiceMatching("IOPlatformExpertDevice"));
        
        let model:Unmanaged<CFTypeRef>! = IORegistryEntryCreateCFProperty(service,
                                                                          "model" as CFString!,
                                                                          kCFAllocatorDefault,
                                                                          0)
        /*
         
         */
        //    let modelIdentifier = model?.takeUnretainedValue() as! String
        let modelIdentifier = convertCfTypeToString(cfValue: model)
        IOObjectRelease(service)
        return modelIdentifier!
    }
    
    /*
     https://vandadnp.wordpress.com/2014/07/07/swift-convert-unmanaged-to-string/
     Unmanaged<CFTypeRef>? : 非托管对象
     * 在Swift和C语言进行混编的过程中,产生的一个临时对象,真正使用的时候需要将非托管对象,转成真正的对象才能进行使用
     * takeUnretainedValue : 表示在转化的过程中,不会对对象进行一次retain操作
     * takeRetainedValue : 表示在转化的过程中,有对对象进行一次retain操作
     注意:一旦使用takeRetainedValue,那么必须对之前的非托管对象进行一次release(),否则就会产生内存泄漏
     let UnManageObjc = ABRecordCopyValue(person, kABPersonLastNameProperty)
     let lastname = UnManageObjc?.takeRetainedValue() as? String
     UnManageObjc?.release()
     */
    func convertCfTypeToString(cfValue: Unmanaged<AnyObject>!) -> String?{
        
        /* Coded by Vandad Nahavandipoor */
        
        let value = Unmanaged.fromOpaque(cfValue.toOpaque()).takeUnretainedValue() as CFString
        if CFGetTypeID(value) == CFStringGetTypeID(){
            return value as String
        } else {
            return nil
        }
    }
    
    //OC:https://github.com/armadsen/ORSSerialPort/wiki/Getting-Vendor-ID-and-Product-ID
   
    func getIODeviceAttributes()->NSDictionary?
    {
//        var ioDeviceAttributes:NSDictionary!
//        var vendorID:NSNumber!
//        var productID:NSNumber!
        //
        var resultDict:NSDictionary!
        
        var iterator:io_iterator_t = 0
        //        io_registry_entry_t
        let IOKitDevice:io_object_t = 0
        //        kIORegistryIterateRecursively + kIORegistryIterateParents,
        var kr:kern_return_t = 0
        kr = IORegistryEntryCreateIterator(IOKitDevice,
                                           kIOServicePlane,
                                           IOOptionBits(kIORegistryIterateRecursively) ,
                                           &iterator)
        if ( kr != KERN_SUCCESS)
        {
            return nil
        }
        
        /*
         io_object_t():http://stackoverflow.com/questions/25351842/convert-cfstring-to-nsstring-swift/25352739#25352739
         */
        while io_object_t() == IOIteratorNext(iterator) {
            
            let serialport = IORegistryEntryCreateCFProperty(io_object_t(), kIOCalloutDeviceKey as CFString!, kCFAllocatorDefault, 0)
            NSLog("serialport----:\(serialport)")
            var usbProperties:Unmanaged<CFMutableDictionary>?
            //
            kr = IORegistryEntryCreateCFProperties(io_object_t(), &usbProperties, kCFAllocatorDefault, 0)
            if kr == KERN_SUCCESS
            {
                if let usbProperties = usbProperties
                {
                    resultDict = usbProperties.takeRetainedValue() as NSDictionary
                    print(resultDict)
                    if let vendorID = resultDict [kUSBVendorID],let productID = resultDict[kUSBProductID]
                    {
                        NSLog("kUSBVendorID:\(vendorID),kUSBProductID:\(productID)")
                    }
                }
            }
            //            IOObjectRelease(device);
        }
        
        IOObjectRelease(iterator)
        return resultDict
    }
}
#endif
