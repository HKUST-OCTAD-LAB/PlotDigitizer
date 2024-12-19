import SwiftUI

struct ContentView: View {
    @State private var selectedImage: NSImage? = nil
    @State private var selectedImageBitmap: CGImage? = nil
    @State private var selectedCorners: [CGPoint] = []
    @State private var selectedColorbar: [CGPoint] = []
    @State private var selectedValues: [Double] = []
    @State private var userInput = ""
    @State private var isSelectingCorners = false
    @State private var isSelectingColorbar = false
    @State private var showInputDialog = false
    @State private var showOutputDialog = false

    var body: some View {
        HStack {
            Sidebar(
                selectedImage: $selectedImage,
                selectedImageBitmap: $selectedImageBitmap,
                isSelectingCorners: $isSelectingCorners,
                isSelectingColorbar: $isSelectingColorbar,
                selectedCorners: $selectedCorners,
                selectedColorbar: $selectedColorbar,
                selectedValues: $selectedValues,
                showOutputDialog: $showOutputDialog
            )
            
            Divider()

            // Main Window
            ImageDisplay(
                selectedImage: $selectedImage,
                selectedImageBitmap: $selectedImageBitmap,
                isSelectingCorners: $isSelectingCorners,
                isSelectingColorbar: $isSelectingColorbar,
                selectedCorners: $selectedCorners,
                selectedColorbar: $selectedColorbar,
                selectedValues: $selectedValues,
                showInputDialog: $showInputDialog
            )
        }
        .padding()
        .alert("Enter a Value", isPresented: $showInputDialog, actions: {
            TextField("Insert only one numerical value...", text: $userInput)
            Button("OK") {
                if let value = Double(userInput) {
                    selectedValues.append(value)
                } else {
                    selectedValues.removeAll()
                    selectedColorbar.removeAll()
                }
            }
            Button("Cancel", role: .cancel) {}
        }, message: {
            Text("Please provide your input below.")
        })
        .alert("Complete", isPresented: $showOutputDialog, actions: {
            Button("OK") {}
            Button("Cancel", role: .cancel) {}
        }, message: {
            Text("Output is saved to home folder.")
        })
    }
}

struct Sidebar: View {
    @Binding var selectedImage: NSImage?
    @Binding var selectedImageBitmap: CGImage?
    @Binding var isSelectingCorners: Bool
    @Binding var isSelectingColorbar: Bool
    @Binding var selectedCorners: [CGPoint]
    @Binding var selectedColorbar: [CGPoint]
    @Binding var selectedValues: [Double]
    @Binding var showOutputDialog: Bool

    var body: some View {
        VStack {
            // Load Image Button
            Button(action: {
                openFileSelector(selectedImage: $selectedImage, selectedImageBitmap: $selectedImageBitmap)
            }) {
                Text("Load Picture")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .cornerRadius(8)
            }
            
            // Align Axis Button
            Button(action: {
                isSelectingCorners = true
                selectedCorners.removeAll()
            }) {
                Text("Align Axis")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .cornerRadius(8)
            }
            .disabled(selectedImage == nil)
            
            // Select Colorbar Button
            Button(action: {
                isSelectingColorbar = true
                selectedValues.removeAll()
                selectedColorbar.removeAll()
            }) {
                Text("Select Colorbar")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .cornerRadius(8)
            }
            .disabled(selectedImage == nil || selectedCorners.count != 3)
            
            // Digitize Button
            Button(action: {
                digitizeImage(image: selectedImage, corners: selectedCorners, colorbar: selectedColorbar, values: selectedValues)
                showOutputDialog = true
                selectedCorners.removeAll()
                selectedColorbar.removeAll()
                selectedValues.removeAll()
            }) {
                Text("Digitize")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .cornerRadius(8)
            }
            .disabled(selectedImage == nil || selectedCorners.count != 3 || selectedValues.count != 2)

            // Image Dimensions and Selected Points Table
            PropertyTable(
                selectedImage: $selectedImage,
                selectedImageBitmap: $selectedImageBitmap,
                selectedCorners: $selectedCorners,
                selectedColorbar: $selectedColorbar
            )

            Spacer()
        }
        .frame(width: 200)
    }

    // Helper function to open the file selector
    private func openFileSelector(selectedImage: Binding<NSImage?>, selectedImageBitmap: Binding<CGImage?>) {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.allowedContentTypes = [.image]

        if panel.runModal() == .OK, let url = panel.url, let image = NSImage(contentsOf: url) {
            selectedImage.wrappedValue = image
            selectedImageBitmap.wrappedValue = image.cgImage(forProposedRect: nil, context: nil, hints: nil)
        }
    }
}

struct PropertyTable: View {
    @Binding var selectedImage: NSImage?
    @Binding var selectedImageBitmap: CGImage?
    @Binding var selectedCorners: [CGPoint]
    @Binding var selectedColorbar: [CGPoint]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Image Dimensions:")
                .font(.headline)
                .padding(.top, 10)
            
            if let image = selectedImageBitmap {
                List {
                    HStack {
                        Text("Width:")
                        Spacer()
                        Text("\(image.width, specifier: "%d") px")
                            .foregroundColor(.gray)
                    }
                    HStack {
                        Text("Height:")
                        Spacer()
                        Text("\(image.height, specifier: "%d") px")
                            .foregroundColor(.gray)
                    }
                }
                .frame(maxHeight: 120) // Limit height of the list to prevent stretching
            }

            Text("Selected Corners:")
                .font(.headline)
                .padding(.top, 10)

            // List of selected points
            List {
                ForEach(selectedCorners, id: \.self) { point in
                    HStack {
                        Text("(\(point.x, specifier: "%.0f"), \(point.y, specifier: "%.0f"))")
                            .foregroundColor(.gray)
                    }
                }
            }
            .frame(maxHeight: 150) // Limit the height of this list as well
            
            Text("Selected Colorbar Points:")
                .font(.headline)
                .padding(.top, 10)

            // List of selected points
            List {
                ForEach(selectedColorbar, id: \.self) { point in
                    HStack {
                        Text("(\(point.x, specifier: "%.0f"), \(point.y, specifier: "%.0f"))")
                            .foregroundColor(.gray)
                    }
                }
            }
            .frame(maxHeight: 150) // Limit the height of this list as well
        }
    }
}

// Image Display Area and Point Selection Logic
struct ImageDisplay: View {
    @Binding var selectedImage: NSImage?
    @Binding var selectedImageBitmap: CGImage?
    @Binding var isSelectingCorners: Bool
    @Binding var isSelectingColorbar: Bool
    @Binding var selectedCorners: [CGPoint]
    @Binding var selectedColorbar: [CGPoint]
    @Binding var selectedValues: [Double]
//    @Binding var showAlert: Bool
    @Binding var showInputDialog: Bool

    var body: some View {
        ZStack {
            if let image = selectedImage,
               let bitmap = selectedImageBitmap {
                Image(nsImage: image)
                    .resizable()
                    .scaledToFit()
                    .overlay(
                        GeometryReader { geometry in
                            Color.clear.contentShape(Rectangle())
                                .onTapGesture(coordinateSpace: .local) { location in
                                    handlePointSelection(location: location, geometry: geometry)
                                    handleColorbarSelection(location: location, geometry: geometry)
                                }
                            ZStack {
                                ForEach(selectedCorners, id: \.self) { point in
                                    Circle()
                                        .fill(Color.red)
                                        .frame(width: 10, height: 10)
                                        .position(convertToViewCoordinates(point, geometry: geometry, image: bitmap))
                                }
                                ForEach(selectedColorbar, id: \.self) { point in
                                    Circle()
                                        .fill(Color.blue)
                                        .frame(width: 10, height: 10)
                                        .position(convertToViewCoordinates(point, geometry: geometry, image: bitmap))
                                }
                            }
                        }
                    )
            } else {
                Text("No Image Loaded")
                    .foregroundColor(.gray)
                    .italic()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.gray.opacity(0.2))
    }
    
    private func correctImage(image: NSImage?) -> NSImage? {
        guard let tiffData = image?.tiffRepresentation,
            let bitmap = NSBitmapImageRep(data: tiffData) else {
            return nil
        }
        let image = NSImage(size: NSSize(width: bitmap.pixelsWide, height: bitmap.pixelsHigh))
        image.addRepresentation(bitmap)
        return image
    }

    // Handle point selection and calculate absolute positions
    private func handlePointSelection(location: CGPoint, geometry: GeometryProxy) {
        guard isSelectingCorners, selectedCorners.count < 3 else { return }
        
        let pixelX = location.x / geometry.size.width  * Double(selectedImageBitmap?.width ?? 0)
        let pixelY = location.y / geometry.size.height * Double(selectedImageBitmap?.height ?? 0)
        let selectedPtCoord = CGPoint(x: Int(pixelX), y: Int(pixelY))
//        print("Geometry size: \(geometry.size.width), \(geometry.size.height)")
        
        selectedCorners.append(selectedPtCoord)
        
        if selectedCorners.count == 3 {
            isSelectingCorners = false
//            showAlert = true
        }
    }
    
    private func handleColorbarSelection(location: CGPoint, geometry: GeometryProxy) {
        guard isSelectingColorbar, selectedCorners.count == 3 else { return }
        
        let pixelX = location.x / geometry.size.width  * Double(selectedImageBitmap?.width ?? 0)
        let pixelY = location.y / geometry.size.height * Double(selectedImageBitmap?.height ?? 0)
        let selectedPtCoord = CGPoint(x: Int(pixelX), y: Int(pixelY))

        selectedColorbar.append(selectedPtCoord)
        showInputDialog = true
        
        if selectedColorbar.count == 2 {
            isSelectingColorbar = false
        }
    }
    
    private func convertToViewCoordinates(_ point: CGPoint, geometry: GeometryProxy, image: CGImage) -> CGPoint {
        let imwidth: Double = Double(image.width)
        let imheight: Double = Double(image.height)
        let geowidth: Double = Double(geometry.size.width)
        let geoheight: Double = Double(geometry.size.height)
        let scaleFactor = min(
            geowidth / imwidth,
            geoheight / imheight
        )

        let x = point.x * scaleFactor
        let y = point.y * scaleFactor
//        print("x = \(x), y = \(y)")
        
        return CGPoint(x: x, y: y)
    }
}

