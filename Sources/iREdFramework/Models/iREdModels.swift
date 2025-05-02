import Foundation
import CoreBluetooth

public typealias iRedPeripheral = CBPeripheral

// MARK: Models
public struct iRedDevice: Equatable {
    public var deviceType: iREdBluetoothDeviceType
    public var name: String
    public var peripheral: iRedPeripheral
    public var rssi: NSNumber?
    public var isConnected: Bool
    public var macAddress: String?
}

extension Array where Element == iRedDevice {
    mutating func appendUnique(_ device: iRedDevice) {
        if !self.contains(where: { $0.peripheral.identifier.uuidString == device.peripheral.identifier.uuidString }) {
            self.append(device)
        }
    }
    
    mutating func updateDevice(with uuidString: String, update: (inout iRedDevice) -> Void) {
        if let index = self.firstIndex(where: { $0.peripheral.identifier.uuidString == uuidString }) {
            var device = self[index]
            update(&device)
            self[index] = device
        }
    }
}


public enum BlueToothState: String {
    case unknown = "Unknown state"
    case resetting = "Resetting"
    case unsupported = "Unsupported"
    case unauthorized = "Unauthorized"
    case poweredOff = "Powered off"
    case poweredOn = "Powered on"
}



public struct Config {
    public var isScannedAutoConnect: Bool = false
    public var isConnectedAutoStopScan: Bool = false
    public var isScannedShowAlert: Bool = false
    public var isConnectedShowAlert: Bool = false
    public var isAutoShowResultAlert: Bool = false
    public var isScannedAutoStopScan: Bool = false
    public var isShowScanningAlert: Bool = false
    
    public init(isScannedAutoConnect: Bool = false, isConnectedAutoStopScan: Bool = false, isScannedShowAlert: Bool = false, isConnectedShowAlert: Bool = false, isAutoShowResultAlert: Bool = false, isScannedAutoStopScan: Bool = false, isShowScanningAlert: Bool = false) {
        self.isScannedAutoConnect = isScannedAutoConnect
        self.isConnectedAutoStopScan = isConnectedAutoStopScan
        self.isScannedShowAlert = isScannedShowAlert
        self.isConnectedShowAlert = isConnectedShowAlert
        self.isAutoShowResultAlert = isAutoShowResultAlert
        self.isScannedAutoStopScan = isScannedAutoStopScan
        self.isShowScanningAlert = isShowScanningAlert
    }
}

public enum BLEDeviceCallback {
    case discovered(deviceType: iREdBluetoothDeviceType, device: iRedDevice)
    case connected(deviceType: iREdBluetoothDeviceType, device: iRedDevice)
    case disconnected(deviceType: iREdBluetoothDeviceType, device: iRedDevice)
}

public enum ThermometerCallback {
    case temperature(temperature: Double, mode: Int, modeString: String)
    case battery(type: Int, description: String)
    case error(error: Int, description: String)
}

public enum OximeterCallback {
    case battery(batteryPercentage: Int, pulseData: Data)
    case measurement(pulse: Int, spo2: Int, pi: Double)
}

public enum SphygmometerCallback {
    case instantData(pressure: Int, pulseStatus: Int)
    case finalData(systolic: Int, diastolic: Int, pulse: Int, irregularPulse: Int)
}

public enum ScaleCallback {
    case weight(weight: Double, isFinalResult: Bool)
}

public enum JumpRopeMode: String, CaseIterable  {
    case free = "Free Mode"
    case time = "Time Mode"
    case count = "Count Mode"
    case none = "None Mode"
}
public enum JumpRopeState {
    case notJumpingRope
    case jumpingRope
    case pauseRope
    case endOfJumpRope
}
public enum JumpRopeCallback {
    case result(mode: JumpRopeMode, status: JumpRopeState, setting: Int, count: Int, time: Int, screen: Int, battery: Int)
}
public enum HeartRateCallback {
    case heartrate(heartrate: Int)
    case battery(batteryLevel: Int)
}


public struct BodyInfo {
    public let height: Int
    public let age: Int
    public let gender: String
    public let targetWeight: Int
}

// MARK: Data
/*
public enum DeviceStatus: String, Equatable {
    case none = "None"
    case measuring = "Measuring"
    case measurementCompleted = "Measurement completed"
    case pauseMeasurement = "Pause measurement"
    case measurementError = "Measurement error"
}

public enum BluetoothStatus: String, Equatable {
    case unpaired = "Unpaired"
    case pairing = "Pairing"
    case paired = "Paired"
    case connecting = "Connecting"
    case connected = "Connected"
    case connectionFailure = "Connection Failure"
    case disconnected = "Disconnected"
}
 */

public struct DeviceStatusModel: Equatable {
    public var isPairing: Bool = false
    public var isPaired: Bool = false
    public var isConnecting: Bool = false
    public var isConnected: Bool = false
    public var isConnectionFailure: Bool = false
    public var isDisconnected: Bool = false
    
    public var isMeasuring: Bool = false
    public var isMeasurementCompleted: Bool = false
    public var isPauseMeasurement: Bool = false
    public var isMeasurementError: MeasurementError? = nil
}

public struct MeasurementError: Equatable {
    let errorCode: Int
    let errorDescription: String
}

public protocol HealthDeviceModel {
    var state: DeviceStatusModel { get set }
}

public struct HealthKitThermometerModel {
    public var battery: String? = nil
    public var temperature: Double? = nil
    public var modeCode: Int? = nil
    public var modeDescription: String? = nil
    
    @MainActor public static let empty = HealthKitThermometerModel()
}
public struct HealthKitThermometerData {
    public var state: DeviceStatusModel = DeviceStatusModel()
    public var data: HealthKitThermometerModel = HealthKitThermometerModel()
    
    @MainActor public static let empty = HealthKitThermometerData()
}


public struct HealthKitOximeterModel {
    public var battery: Int? = nil
    public var pulsData: Data? = nil
    
    public var pulse: Int? = nil
    public var spo2: Int? = nil
    public var pi: Double? = nil
    
    public var SpO2Array: [Int] = []
    public var PIArray: [Double] = []
    public var BPMArray: [Int] = []
    
    public var bpmCount: Int? = nil
    public var piCount: Double? = nil
    public var spo2Count: Int? = nil
    
    public var resultPI: String? = nil
    public var PlethysmographyArray: [Int] = []
    
    @MainActor public static let empty = HealthKitOximeterModel()
    
    public func averageSpo2() -> Int {
        // 非正常测量数据Error: 如果测量时，无手指，数据可能为，程序可能会Quit
        if SpO2Array.isEmpty {
            return 0
        }
        // 处理异常数据，比如：无手指测量数据
        let temp_SpO2Array = SpO2Array.map({ $0 == 127 ? 0 : $0 })
        return temp_SpO2Array.reduce(0, +) / temp_SpO2Array.count
    }
    
    public func averageBPM() -> Int {
        // 去除异常数据，比如0心跳数据、无心跳数据
        if BPMArray.isEmpty {
            return 0
        }
        let temp_BPMArray = BPMArray.filter({ $0 != 255 })
        print("BPMArray: ", BPMArray)
        print("temp_BPMArray: ", temp_BPMArray)
        if temp_BPMArray.isEmpty {
            return 0
        }
        return temp_BPMArray.reduce(0, +) / temp_BPMArray.count
    }
    
    public func averagePI() -> Double {
        PIArray.reduce(0, +) / Double(PIArray.count)
    }
}
public struct HealthKitOximeterData {
    public var state: DeviceStatusModel = DeviceStatusModel()
    public var data: HealthKitOximeterModel = HealthKitOximeterModel()
    
    @MainActor public static let empty = HealthKitOximeterData()
}

public struct HealthKitSphygmometerModel {
    public var pressure: Int? = nil
    public var pulseStatus: Int? = nil
    
    public var systolic: Int? = nil
    public var diastolic: Int? = nil
    public var pulse: Int? = nil
    public var irregularPulse: Int? = nil
    
    @MainActor public static let empty = HealthKitSphygmometerModel()
}
public struct HealthKitSphygmometerData {
    public var state: DeviceStatusModel = DeviceStatusModel()
    public var data: HealthKitSphygmometerModel = HealthKitSphygmometerModel()
    
    @MainActor public static let empty = HealthKitSphygmometerData()
}

public struct HealthKitScaleModel {
    public var peripheralName: String? = nil
    public var weight: Double? = nil
    public var isFinalResult: Bool? = nil
    
    // BMI = weight (kg) / (height (m)* height(m))
    func toBMI(height: Int, weight: Double) -> Double {
        if height == 0 {
            return 0
        }
        let heightInMeters = Double(height) / 100.0  // 先转换为 Double
        let bmi = weight / pow(heightInMeters, 2)
//        print("weight: \(weight) height: \(height) 计算BMI分母：\(pow(heightInMeters, 2))")
        return bmi
    }
    
    // (1.39 x BMI) + (0.16 x age) – (10.34 x gender) – 9 = Body Fat Percentage
    // (In this case, “gender” is equal to 1 for men and 0 for women.
    func toBodyFat(height: Int, age: Int,gender tempGender: String) -> Double {
        if height == 0 {
            return 0
        }
        let gender: Double = tempGender.lowercased() == "male" ? 1 : 0
        let age = age
        let bmi = toBMI(height: height, weight: weight ?? 0)
        let temp1 = 1.39 * bmi
        let temp2 = 0.16 * Double(age)
        let temp3 = 10.34 * gender
        let bodyfat = temp1 + temp2 - temp3 - 9
        if bodyfat < 0 {
            return 0
        }
        return bodyfat
    }
    
    func healthStatus(height: Int) -> String {
        switch toBMI(height: height, weight: weight ?? 0) {
        case 0..<18.5:
            "Underweight"
        case 18.5..<22.9:
            "Normal"
        case 22.9..<24.9:
            "Overweight"
        default:
            "Obese"
        }
    }
    
    @MainActor public static let empty = HealthKitScaleModel()
}
public struct HealthKitScalerData {
    public var state: DeviceStatusModel = DeviceStatusModel()
    public var data: HealthKitScaleModel = HealthKitScaleModel()
    
    @MainActor public static let empty = HealthKitScalerData()
}


/// 跳绳设备数据模型
public struct JumpRopeModel: Equatable {
    /// 蓝牙外设名称
    public var peripheralName: String? = nil
    
    /// 设备 MAC 地址
    public var macAddress: String? = nil
    
    /// 模式：0 = 自由跳, 1 = 计时跳, 2 = 计数跳
    public var mode: Int? = nil
    
    /// 当前状态（例如是否在跳跃中，可自定义）
    public var status: Int? = nil
    
    /// 用户设置的参数（如目标时间/计数等）
    public var setting: Int? = nil
    
    /// 当前已跳绳次数
    public var count: Int? = nil
    
    /// 当前已跳绳时间（单位：秒）
    public var time: Int? = nil
    
    /// 当前设备屏幕显示状态
    public var screen: Int? = nil
    
    /// 电池电量等级：
    /// - 4: 电量 > 80%
    /// - 3: 电量 > 50%
    /// - 2: 电量 > 25%
    /// - 1: 电量 > 10%
    /// - 0: 电量 <= 10%
    public var batteryLevel: Int? = nil
    
    /// 空模型，用于初始化或清空状态
    @MainActor public static let empty = JumpRopeModel()
    
    /// 返回模式对应的字符串（Free / Time / Count）
    public func modeString() -> String {
        return mode == 0 ? "Free" : mode == 1 ? "Time" : mode == 2 ? "Count" : "Free"
    }
    
    /// 电池电量描述字符串
    public var batteryLevelDescription: String {
        guard let level = batteryLevel else { return "Unknown" }
        switch level {
        case 4:
            return "电量充足（>80%）"
        case 3:
            return "电量良好（>50%）"
        case 2:
            return "电量一般（>25%）"
        case 1:
            return "电量较低（>10%）"
        case 0:
            return "电量极低（<=10%）"
        default:
            return "未知电量等级"
        }
    }
    /// 跳绳历史记录数组（每秒记录）
    public var countArray: [JumpRopeArrayModel] = []
    /// 跳绳单次记录时长（单位：秒）
    public var recordTime: Int {
        countArray.count
    }
}
/// 单条跳绳记录
public struct JumpRopeArrayModel: Identifiable, Equatable {
    public let id = UUID()
    public let date: Date
    public let count: Int
}

public struct JumpRopeData: Equatable {
    public var state: DeviceStatusModel = DeviceStatusModel()
    public var data: JumpRopeModel = JumpRopeModel()
    
    @MainActor public static let empty = JumpRopeData()
}

/// 心率带数据模型，用于记录当前心率、设备信息、电量及历史记录
public struct HeartRateBeltModel: Equatable {
    /// 蓝牙设备名称
    public var peripheralName: String? = nil
    /// 当前心率值（最新一次）
    public var heartrate: Int? = nil
    /// 当前电池电量（百分比）
    public var batteryPercentage: Int? = nil
    /// 心率变化历史记录（每秒记录一次）
    public var heartrateArray: [HeartRateBeltArrayModel] = []

    /// 获取记录期间所有心率值的总和
    /// - Returns: 心率值累加总和（用于计算平均心率等）
    public func totalHeartrate() -> Int {
        return heartrateArray.reduce(0) { $0 + $1.heartrate }
    }

    /// 获取记录期间的最高心率值
    /// - Returns: 最高心率，若无记录则返回 nil
    public func maxHeartRate() -> Int? {
        return heartrateArray.max { $0.heartrate < $1.heartrate }?.heartrate
    }

    /// 获取记录期间的最低心率值
    /// - Returns: 最低心率，若无记录则返回 nil
    public func minHeartRate() -> Int? {
        return heartrateArray.min { $0.heartrate < $1.heartrate }?.heartrate
    }

    /// 获取已记录的总秒数
    /// - Returns: 心率数组的长度，即代表已记录的秒数
    public func recordedSeconds() -> Int {
        return heartrateArray.count
    }
    
    /// 获取记录期间的平均心率
    /// - Returns: 平均心率，若无记录则返回 nil
    public func averageHeartRate() -> Double? {
        guard !heartrateArray.isEmpty else { return nil }
        let total = totalHeartrate()
        let avg = Double(total) / Double(heartrateArray.count)
        return (avg * 100).rounded() / 100
    }

    /// 空模型初始化（默认值）
    @MainActor static let empty = HeartRateBeltModel()
}
public struct HeartRateBeltArrayModel: Equatable {
    var date: Date = Date()
    var heartrate: Int
}
public struct HeartRateBeltData: Equatable {
    public var state: DeviceStatusModel = DeviceStatusModel()
    public var data: HeartRateBeltModel = HeartRateBeltModel()
    
    @MainActor public static let empty = HeartRateBeltData()
}


public struct iRedDeviceData {
    public var thermometerData: HealthKitThermometerData = HealthKitThermometerData()
    public var oximeterData: HealthKitOximeterData = HealthKitOximeterData()
    public var sphygmometerData: HealthKitSphygmometerData = HealthKitSphygmometerData()
    
    public var jumpRopeData: JumpRopeData = JumpRopeData()
    public var heartRateData: HeartRateBeltData = HeartRateBeltData()
    
    public var scaleData: HealthKitScalerData = HealthKitScalerData()
}


// MARK: ---------- HTTPClient ----------

public enum RequestResult<T> {
    case success(code: Int, message: String, data: T?)
    case failure(code: Int, message: String)
}

public struct SphygmometerModel: Decodable {
    public let diastolic: Int
    public let systolic: Int
    public let pulse: Int
    public let datetime: String
    public let user: String
}
public struct ScaleModel: Decodable {
    public let weight: Double
    public let bodyfat: Double
    public let bmi: Double
    public let datetime: String
    public let user: String
}
public struct OximeterModel: Decodable {
    public let spo2: Int
    public let bpm: Int
    public let pi: Double
    public let datetime: String
    public let user: String
}

public struct ThermometerModel: Decodable {
    public let temperature: Double
    public let mode: String
    public let datetime: String
    public let user: String
    
    @MainActor static let error = ThermometerModel(temperature: -1, mode: "Error", datetime: "", user: "Error")
}

public struct RopeModel: Decodable {
    public let count: Int
    public let datetime: String
    public let completiontime: Int
    public let mode: String
    public let user: String
}

public struct HeartRateModel: Decodable {
    public let averagehr: Double
    public let minhr: Int
    public let maxhr: Int
    public let datetime: String
    public let user: String
}

public struct RequestModel<T: Decodable>: Decodable {
    public let code: Int
    public let message: String
    public let data: T
}

//public struct SportKitHomeDataModel: Decodable {
//    public let lastScaleData: LastEntryModel?
//    public let lastWeekHeartRateData: [LastWeekHeartRateDataModel]?
//    public let lastFiveHeartRateData: [LastFiveHeartRateDataModel]?
//    public let jumpRopeBestResult: [JumpRopeBestResultDataModel]?
//    public let allHeartRateData: [AllHeartRateDataModel]?
//    
//    
//    public struct LastEntryModel: Decodable {
//        public let user: String?
//        public let weight: Double?
//        public let bmi: Double?
//        public let bodyFat: Double?
//        public let datetime: String?
//    }
//    
//    public struct LastWeekHeartRateDataModel: Decodable {
//        public let datetime: String?
//        public let averageHR: Double?
//        public let maxHR: Int?
//        public let minHR: Int?
//        public let user: String?
//    }
//    
//    public struct LastFiveHeartRateDataModel: Decodable {
//        public let datetime: String?
//        public let averageHR: Double?
//        public let maxHR: Int?
//        public let minHR: Int?
//        public let user: String?
//    }
//    
//    public struct JumpRopeBestResultDataModel: Decodable {
//        public let mode: String?
//        public let datetime: String?
//        public let count: Int?
//        public let completionTime: Int?
//        public let efficiency: String?
//        public let user: String?
//    }
//    
//    public struct AllHeartRateDataModel: Decodable {
//        public let datetime: String?
//        public let averageHR: Double?
//        public let maxHR: Int?
//        public let minHR: Int?
//    }
//}



public extension Int {
    var timestampToDate: Date {
        return Date(timeIntervalSince1970: TimeInterval(self))
    }
}


public enum iREdBluetoothDeviceType: String, Codable {
    case thermometer = "Thermometer"
    case oximeter = "Oximeter"
    case sphygmometer = "Sphygmometer"
    
    case jumpRope = "JumpRope"
    case heartRateBelt = "HeartRate"
    
    case scale = "Scale"
    
    case none = "None"
    case all_ired_devices = "All iRED Devices"
}
