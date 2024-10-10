# Word-cloud-generator

### Description
This R Shiny project visualizes the relationship between GDP and life expectancy using a scatterplot and allows users to explore data by continents. It also includes a word cloud generator with custom file uploads, text input capabilities, and **interactive tooltips** that display word frequencies when hovering over the words.

The app is designed with three main sections:

1. **GDP vs. Life Expectancy Scatterplot**  
   - This tab presents an interactive scatterplot of GDP and life expectancy data. Users can select the continent of interest to filter the data and examine the correlation between GDP and life expectancy for specific regions.
   
2. **Data Table View**  
   - In this tab, the application displays a table view of the dataset used for the scatterplot. Users can sort, filter, and search through the data to explore details at a granular level.
   
3. **Word Cloud Generator**  
   - This tab allows users to generate word clouds from either uploaded text files or by manually inputting text. It visualizes the most frequently occurring words, with customizable features such as choosing the number of words to display and the color palette for the word cloud.

## App Features

1. **Scatterplot Customization**:  
   - Users can select different continents to filter the scatterplot data.
   - Dynamic tooltips show additional information when hovering over the data points.

2. **Interactive Data Table**:  
   - Easily searchable and filterable table for detailed data examination.

3. **Word Cloud Generator**:  
   - Users can upload a `.txt` file or enter their own text to create a word cloud.
   - The word cloud is generated dynamically, and hovering over the words displays their frequency in the input text.

### Technologies Used
- R Shiny
- ggplot2
- dplyr
- shinyapps.io for deployment

**View the Shiny App** [Word Cloud Generator](https://jithendrasadu.shinyapps.io/Word_Cloud/)
