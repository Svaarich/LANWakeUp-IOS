import Foundation

public class DeviceDataService: ObservableObject {
    
    @Published var allDevices: [Device] = [] {
        didSet {
            saveUserDefaults()
        }
    }
    
    init() {
        fetchUserDefaults()
    }
    
    // Get list of saved devices from UserDefaults
    func fetchUserDefaults() {
        if let data = UserDefaults.standard.data(forKey: "devices") {
            do {
                let decoder = JSONDecoder()
                let savedDevices = try decoder.decode([Device].self, from: data)
                allDevices = savedDevices
            } catch {
                print("Unable to Decode devices (\(error))")
            }
        }
    }
    
    // Save list with devices into UserDefaults
    func saveUserDefaults() {
        let data = allDevices
        do {
            let encoder = JSONEncoder()
            let defaults = UserDefaults.standard
            let savedDevices = try encoder.encode(data)
            defaults.set(savedDevices, forKey: "devices")
        } catch {
            print("Unable to Encode Array of devices (\(error))")
        }
    }
    
    // Delete device from the array
    func delete(device: Device) {
        if let index = allDevices.firstIndex(where: { $0 == device }) {
            allDevices.remove(at: index)
            
        }
    }
    
    // Add device to the array
    func add(newDevice: Device) {
        allDevices.append(newDevice)
    }
    
    // toggles pin state of device
    func pinToggle(device: Device) {
        if let index = allDevices.firstIndex(where: { $0 == device } ) {
            allDevices[index] = device.pinToggle()
        }
    }
    
    // update edited device
    func updateDevice(oldDevice: Device, newDevice: Device) {
        if let index = allDevices.firstIndex(where: { $0 == oldDevice } ) {
            allDevices[index] = newDevice
        }
    }
}
