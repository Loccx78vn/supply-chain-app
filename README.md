### **Introduction**

In recent years, Business Intelligence and Analytics tools (BIS tools) have gained increasing attention from businesses worldwide. These tools are highly valued for their ability to provide insights that can guide decision-making and improve operational efficiency. Personally, I’ve had the chance to experiment with these tools but often found them lacking in certain areas, such as limited customization options, complex modules, and fewer intuitive options for tailored user interfaces.

This project aims to address some of these issues by creating a dashboard using R, specifically utilizing the **Rhino package**. The benefit of using R is that it is free and open-source, which makes it accessible for businesses without the need for expensive software solutions. The project will focus on developing an interactive dashboard that can help businesses visualize data more effectively, make data-driven decisions, and uncover valuable insights. 

By developing a dashboard app that can be hosted, businesses will not only save resources but also gain access to more advanced dashboards, enabling faster, more accurate decision-making. The app will be user-friendly, highly customizable, and can be integrated with different data sources for better reporting. 

---

### **Project Overview**

The goal of this project is to build a fully functional and interactive dashboard app using R. The project will be divided into three main parts, each focusing on a different aspect of the app development process: building the app’s server using **Rhino** and **Shiny**, customizing the app's user interface (UI) with **HTML, CSS**, and **JavaScript**, and finally, deploying the app on the **ShinyApps.io** platform, which is hosted by the Posit community. 

About folder structure:
```
/supply-chain-app/
  |-- /app/
  |-- /data/
  |-- /docker/
  |-- /static/
      |-- index.html
      |-- styles.css
      |-- scripts.js
  |-- /tests/
  |-- /renv/
  |-- /rsconnect/
  |-- .dockerignore
  |-- .Rhistory
  |-- .Rprofile
  |-- app.R
  |-- config.yml
  |-- dependencies.R
  |-- Dockerfile
  |-- rhino.yml
  |-- supply-chain-app.Rproj
```

---

#### **1. Building the App Server Using Rhino and Shiny**

The first step of the project is to set up the app's server. For this, we will use the **Rhino package** along with **Shiny** in R. Rhino is a powerful framework that allows developers to build highly interactive web applications in R. Shiny, another R package, is specifically designed for building interactive web apps. The combination of Rhino and Shiny will allow for the creation of a dynamic and responsive dashboard.

To begin, we need to install the necessary packages in R:
```R
install.packages("rhino")
install.packages("shiny")
```

Once the packages are installed, we can set up a basic Shiny app structure. Here's a simple code structure for the Shiny app:

```R
library(shiny)
library(rhino)

# Define UI for the dashboard
ui <- fluidPage(
  titlePanel("Business Dashboard"),
  sidebarLayout(
    sidebarPanel(
      sliderInput("slider", "Select Value:", min = 1, max = 100, value = 50)
    ),
    mainPanel(
      textOutput("result"),
      plotOutput("plot")
    )
  )
)

# Define server logic for the dashboard
server <- function(input, output) {
  output$result <- renderText({
    paste("Selected value is", input$slider)
  })
  
  output$plot <- renderPlot({
    hist(rnorm(input$slider), main = "Random Data Distribution", xlab = "Value", col = "lightblue")
  })
}

# Run the app
shinyApp(ui = ui, server = server)
```

In this code:
- We create a basic UI with a slider input and a plot.
- The server function updates the text and plot based on the slider input, providing an interactive experience.

#### **2. Customizing the App’s UI with HTML, CSS, and JavaScript**

Once the app's basic functionality is built, the next step is to focus on customizing the user interface (UI) to make it more engaging and professional. While Shiny provides some built-in UI elements, we can enhance the visual appearance by incorporating **HTML**, **CSS**, and **JavaScript** for advanced styling and functionality.

**HTML** will be used to structure the content of the app. For example, we can use `<div>`, `<span>`, and `<input>` elements to create interactive sections.

**CSS** will be used for styling the app, adjusting fonts, colors, spacing, and layout. 

**JavaScript** can be used for advanced interactivity, such as animations, responsive features, and integrating external libraries.

##### **1. Connect the custom UI with server**

After we have our HTML, CSS, and JavaScript files, we can integrate the `htmlTemplate()` function in the R code to load the template.

Here’s how you can modify your Shiny server code to use the HTML template:

```R
library(shiny)

# Define UI using htmlTemplate
ui <- htmlTemplate("app/static/index.html")

# Define server logic for the app
server <- function(input, output, session) {
  # Reactive expression to display the slider value
  output$result <- renderText({
    paste("The selected value is:", input$slider)
  })

  # Reactive plot (example)
  output$plotContainer <- renderPlot({
    hist(rnorm(input$slider), main = "Random Data Distribution", xlab = "Value", col = "lightblue")
  })
}

# Run the application
shinyApp(ui = ui, server = server)
```

In this example, we customize the layout, style the page, and use classes for more advanced CSS styling.

##### **2. Deploying the App on ShinyApps.io**

The final step is to deploy the app on **ShinyApps.io**, which is a cloud platform provided by the Posit community (formerly RStudio). This platform allows us to host the app online so it can be accessed by users anywhere. Deploying the app is straightforward:

1. First, sign up for an account on [ShinyApps.io](https://www.shinyapps.io/).
2. Install the **rsconnect** package in R:
```R
install.packages("rsconnect")
```

3. Authenticate your account with the following code:
```R
library(rsconnect)
rsconnect::setAccountInfo(name = "your_account_name", 
                          token = "your_token", 
                          secret = "your_secret")
```

4. Deploy the app:
```R
rsconnect::deployApp("path_to_your_app_directory")
```

Once the app is deployed, it will be available for users to interact with, offering real-time insights and allowing businesses to visualize data and make informed decisions.

---
### **Conclusion**

This project is an exciting opportunity to create a flexible and customizable dashboard app that can address many of the limitations of traditional BIS tools. By using R, Rhino, and Shiny, the app will not only be cost-effective but also highly interactive, providing businesses with the tools they need to drive data-driven decisions. The combination of a powerful back-end framework and a customizable front-end UI ensures that this app will meet the diverse needs of businesses, ultimately helping them uncover insights faster and more efficiently.

![](background.jpg)

