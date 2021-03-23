#UI for book_to_user

library(shiny)

shinyUI(fluidPage(
  titlePanel("Collaborative Book recommendation system"),
  sidebarLayout(
    sidebarPanel(
      numericInput("user_no", "Enter user number (Between 1-9892)",value = 1, min=1, max=9892),
      actionButton("readhistory", "Show reading history"),
      actionButton("goButton", "Show recommendations"),
      tableOutput("myhistory")
      
    ),
    mainPanel(
      helpText("User Name:"),
      textOutput("txt"),
      h3("Users like you enjoyed the following books!"),
      tableOutput("recom")
    )
  )
))

