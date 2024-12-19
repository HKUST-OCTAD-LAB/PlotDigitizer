# Heatmap Digitizer

**Heatmap Digitizer** is a Swift-based macOS app designed to digitize heatmaps/density maps efficiently using KDTree for spatial queries. 
The app allows users to extract data points from an image of a heatmap and save the results as a CSV file for further analysis.

---

## **Purpose**

This app is designed to:
- Digitize heatmaps with high efficiency.
- Provide an intuitive interface for aligning axes and colorbars.
- Export digitized data in a structured format.

---

## **Features**

1. Load an image of a heatmap for processing.
2. Align the axes and colorbar to map image coordinates to real-world data values.
3. Efficiently digitize the heatmap using KDTree for nearest-neighbor queries.
4. Export the digitized data as a CSV file.

---

## **Usage**

### 1. **Load an Image**
- Open the app and load the heatmap image you want to digitize.

### 2. **Align Axes**
- Select the lower-left corner of the heatmap and click. A **red dot** will appear at the selected point.
- Select the lower-right corner of the heatmap and click. Another **red dot** will appear.
- Select the upper-left corner of the heatmap and click. A third **red dot** will appear.
- Make sure to select the points **in this order**: lower-left, lower-right, upper-left.

### 3. **Align Colorbar**
- Select the lower limit of the colorbar and input its **lower bound value**. A **blue dot** will appear at the selected point.
- Select the upper limit of the colorbar and input its **upper bound value**. Another **blue dot** will appear.
- Ensure you select the points **in this order**: lower limit, upper limit.

### 4. **Digitize the Heatmap**
- Once the axes and colorbar are aligned, proceed with digitizing the heatmap.
- The digitized result will be saved automatically as a **CSV file** in your home folder.

---

## **Output**

The output CSV file will contain the **Value Matrix**: The corresponding data matrix for each point.

---

## **Requirements**

- **macOS**: 11.0 or later
- **Swift**: Built using Swift and KDTree for efficient digitization.

---

## **Future Enhancements**

- Support for additional heatmap formats.
- Option to select points without following this order.
- Export data in multiple file formats (e.g., JSON, Excel).

---

## **Support**

For issues, suggestions, or feedback, please contact shihuamingzhi'at'gmail.com. 
You can create a pull request if you would like to implement new features.
