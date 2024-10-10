library(shiny)
library(plotly)
library(ggthemes)
library(wordcloud2)
library(shinyWidgets)
library(wordcloud)
library(gapminder)
library(tidyverse)
library(plotly)
library(DT)
library(colourpicker)
library(ggplot2)
library(tm)
library(shinycssloaders)
library(rsconnect)

# Define the text about Gapminder data
text_about <- "Gapminder data Description. Gapminder data on life expectancy, GDP per capita, and population by country.

Usage
gapminder
Format
The main data frame gapminder has 1704 rows and 6 variables:

country
factor with 142 levels

continent
factor with 5 levels

year
ranges from 1952 to 2007 in increments of 5 years

lifeExp
life expectancy at birth, in years

pop
population

gdpPercap
GDP per capita (US$, inflation-adjusted)"

# Define the CSS styles
my_css <- "
#download_data {
  background: orange;  /* Change the background color of the download button to orange. */
  font-size: 20px;     /* Change the text size to 20 pixels. */
}

#table {
  color: black;        /* Change the text color of the table to black. */
}
"

sample_text <- c(
  "Everybody gets high sometimes, you know.",
  "What else can we do when we're feeling low?", 
  "So take a deep breath and let it go.",
  "You shouldn't be drowning on your own.", 
  "And if you feel you're sinking, I will jump right over",
  "Into the cold water for you.",
  "And although time may take us into different places,",
  "I will still be patient with you.", 
  "And I hope you know I won't let go.",
  "I'll be alright, I'll be alright.", 
  "I won't let go.", 
  "I'll be alright, I'll be alright."
)

# Define the UI
ui <- fluidPage(
  h1("Gapminder"),
  titlePanel("Word Cloud"),
  h4("Author: Jithendra Sadu"),
  h4("Date: 2023-04-27"),
  sidebarLayout(
    sidebarPanel(
      actionButton('show_about', 'About'),
      sliderInput(inputId = "life", label = "Life expectancy",
                  min = 0, max = 120, value = c(51, 82)),
      numericInput("size", "Point size", value = 1, min = 1),
      checkboxInput("fit", "Add line of best fit", value = FALSE),
      colourInput("color", "Point color", value = "blue"),
      selectInput("continents", "Continents",
                  choices = levels(gapminder$continent),
                  multiple = TRUE, selected = "Europe"),
      sliderInput("years", "Years",
                  min(gapminder$year), max(gapminder$year),
                  value = c(1977, 2002), step = 5)
    ),
    
    mainPanel(
      tabsetPanel(
        tabPanel(title = "Plot", plotlyOutput("plot")),
        tabPanel(title = "Table", DT::dataTableOutput("table")),
        tabPanel(
          title = "Word Cloud",
          sidebarLayout(
            sidebarPanel(
              radioButtons(
                inputId = "source",
                label = "Word source",
                choices = c(
                  "Cold Water" = "cold_water",
                  "Use your own words" = "own",
                  "Upload a file" = "file"
                )
              ),
              conditionalPanel(
                condition = "input.source == 'own'",
                textAreaInput("text", "Enter text", rows = 7)
              ),
              conditionalPanel(
                condition = "input.source == 'file'",
                fileInput("file", "Select a file")
              ),
              numericInput("num", "Maximum number of words", value = 100, min = 1),
              colourInput("col", "Background color", value = "white"),
              actionButton(inputId = "draw", label = "Draw!")
            ),
            mainPanel(
              tags$head(
                tags$style(
                  HTML(".wordcloud2 { height: calc(100vh - 150px); width: 100vw; 
                  display: inline-block;  overflow: hidden; }")
                )
              ),
              wordcloud2Output("cloud")
            )
          )
        )
      ),
      downloadButton("download_data")
    )
  ),
  tags$style(my_css)
)

# Define the server
server <- function(input, output) {
  observeEvent(input$show_about, {
    showModal(modalDialog(text_about, title = 'About'))
  })
  
  # Reactive data filtering
  filtered_data <- reactive({
    data <- gapminder
    data <- subset(data, lifeExp >= input$life[1] & lifeExp <= input$life[2])
    
    if (length(input$continents) > 0) {
      data <- subset(data, continent %in% input$continents)
    }
    
    data <- subset(data, year >= input$years[1] & year <= input$years[2])
    
    print(head(data)) 
    data
  })
  
  # Render the data table
  output$table <- DT::renderDataTable({
    data <- filtered_data()
    data
  })
  
  # Download handler for the data
  output$download_data <- downloadHandler(
    filename = "gapminder_data.csv",
    content = function(file) {
      data <- filtered_data()
      write.csv(data, file, row.names = FALSE)
    }
  )
  
  # Render the plot
  output$plot <- renderPlotly({
    data <- filtered_data()
    
    p <- ggplot(data, aes(gdpPercap, lifeExp, text = country)) +
      geom_point(size = input$size, color = input$color) +
      scale_x_log10() +
      ggtitle(paste("GDP vs life expectancy (", input$life[1], "-", input$life[2], " years)"))
    
    if (input$fit) {
      p <- p + geom_smooth(method = "lm")
    }
    
    ggplotly(p, hoverinfo = "text")
  })
  
  # Create word cloud function
  create_wordcloud <- function(data, num_words = 100, background = "white") {
    if (is.character(data)) {
      corpus <- Corpus(VectorSource(data))
      corpus <- tm_map(corpus, content_transformer(tolower))
      corpus <- tm_map(corpus, removePunctuation)
      corpus <- tm_map(corpus, removeNumbers)
      corpus <- tm_map(corpus, removeWords, stopwords("english"))
      corpus <- tm_map(corpus, stripWhitespace)  
      tdm <- as.matrix(TermDocumentMatrix(corpus))
      data <- sort(rowSums(tdm), decreasing = TRUE)
      data <- data.frame(word = names(data), freq = as.numeric(data))
    }
    
    if (!is.numeric(num_words) || num_words < 1) {
      num_words <- 1
    }  
    
    # Grab the top n most common words
    data <- head(data, n = num_words)
    if (nrow(data) == 0) {
      return(NULL)
    }
    
    wordcloud2(data, backgroundColor = background)
  }
  
  # Reactive data source for the word cloud
  data_source <- reactive({
    if (input$source == "cold_water") {
      data <- sample_text
    } else if (input$source == "own") {
      data <- input$text
    } else if (input$source == "file") {
      data <- input_file()
    }
    print(data)
    return(data)
  })
  
  # Reactive file input
  input_file <- reactive({
    if (is.null(input$file)) {
      return("")
    }
    readLines(input$file$datapath)
  })
  
  # Render the word cloud
  output$cloud <- renderWordcloud2({
    input$draw
    isolate({
      data_to_plot <- data_source() 
      print(data_to_plot) 
      create_wordcloud(data_to_plot, num_words = input$num, background = input$col)
    })
  })
}

shinyApp(ui, server)




