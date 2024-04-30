import SwiftUI

struct HomeView: View {
    
    @ObservedObject var dataService: DeviceDataService
    
    @State private var showAddView: Bool = false
    @State private var showWarning: Bool = false
    @State private var refreshStatus: Bool = false
    @State private var isCopied: Bool = false
    @State private var showDeleteCancelation: Bool = false
    
    var body: some View {
            ZStack {
                if dataService.allDevices.isEmpty {
                    NoDevicesView(isPresented: $showAddView)
                        .transition(AnyTransition.opacity.animation(.spring))
                } else {
                    VStack {
                        List {
                            //MARK: Sections
                            getSections()
                        }
                        // List settings
                        // refreshable list
                        .refreshable {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                refreshStatus.toggle()
                            }
                        }
                    }
                }
                if showDeleteCancelation {
                    VStack {
                        Spacer()
                        CancelDeleteView(showView: $showDeleteCancelation)
                            .padding(.horizontal)
                            .animation(.spring, value: showDeleteCancelation)
                            .transition(.slide)
                    }
                }
                
                // Add device view
                if showAddView {
                    ZStack {
                        AddDeviceView(isPresented: $showAddView)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .ignoresSafeArea(edges: .bottom)
                        
                    }
                    .zIndex(2.0)
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom),
                        removal: .move(edge: .bottom).combined(with: .opacity)))
                    
                }
                CopiedNotificationView()
                    .opacity(isCopied ? 1.0 : 0)
                    .animation(.spring, value: isCopied)
            }
            
            .ignoresSafeArea(.keyboard)
            
            //MARK: Navigation title
            .navigationTitle("Device List")
            .navigationBarTitleDisplayMode(.inline)
            
            
            //MARK: Animation
            .animation(.default, value: dataService.allDevices)
            
            
            //MARK: Toolbar items
            .toolbar {
                // Info button
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink {
                        AppInfoView()
                    } label: {
                        Image(systemName: "info.circle")
                    }
                }
                
                // Add button
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        withAnimation(.snappy) {
                            showAddView = true
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        
        //MARK: Network connection check
        .onAppear {
            // isConnected to network?
            showWarning = !Network.instance.isConnectedToNetwork()
            
        }
        // No Internet connection alert
        //        .alert("No internet connection 😭", isPresented: $showWarning) {
        //        }
    }
}

extension HomeView {
    
    // MARK: FUNCTIONS
    
    // Gives sections depends on pinned and not pinner devices
    private func getSections() -> AnyView {
        switch numberOfSections() {
        case 1: // only pinned devices
            return AnyView(pinnedSection)
        case 2: // only not pinned devices
            return AnyView(devicesSection)
        case 3: // pinned and not pinned devices
            return AnyView(
                Group {
                    pinnedSection
                    devicesSection
                }
            )
        default:
            return AnyView(EmptyView())
        }
    }
    
    // Gives number of sections
    private func numberOfSections() -> Int {
        var pinned: Int = 0 // pined sections
        var notPinned: Int = 0 // not pinned sections
        for device in dataService.allDevices {
            if device.isPinned {
                pinned = 1
            } else {
                notPinned = 2
            }
        }
        return pinned + notPinned // 1 / 2 / 3
    }
    
    // MARK: PROPERTIES
    
    // Pinned section
    private var pinnedSection: some View {
        Section {
            ForEach(dataService.allDevices) { device in
                if device.isPinned {
                    NavigationLink {
                        DeviceInfoView(device: device, showDeleteCancelation: $showDeleteCancelation)
                    } label: {
                        DeviceCellView(refreshStatus: $refreshStatus,
                                       isCopied: $isCopied,
                                       showDeleteCancelation: $showDeleteCancelation,
                                       device: device)
                    }
                }
            }
            .onMove { indices, newOffset in
                dataService.allDevices.move(fromOffsets: indices, toOffset: newOffset)
            }
        } header: {
            HStack(spacing: 4) {
                Text("Pinned")
                Image(systemName: "star.fill")
                    .foregroundStyle(Color.custom.starColor)
                    .padding(.bottom, 4)
            }
        }
    }
    
    // Device section
    private var devicesSection: some View {
        Section {
            ForEach(dataService.allDevices) { device in
                if !device.isPinned {
                    NavigationLink {
                        DeviceInfoView(device: device, showDeleteCancelation: $showDeleteCancelation)
                    } label: {
                        DeviceCellView(refreshStatus: $refreshStatus, 
                                       isCopied: $isCopied,
                                       showDeleteCancelation: $showDeleteCancelation,
                                       device: device)
                    }
                }
            }
            .onMove { indices, newOffset in
                dataService.allDevices.move(fromOffsets: indices, toOffset: newOffset)
            }
        } header: {
            HStack(spacing: 4) {
                Text("All Devices")
                Image(systemName: "macbook.and.ipad")
                    .foregroundStyle(.secondary)
            }
        }
    }
}
//
//#Preview {
//    let dataService = DeviceDataService()
//    return HomeView(dataService: dataService)
//}
