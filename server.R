#Server for Book_to_user

library(dplyr)
library(shiny)
library(data.table)
library(recommenderlab)
library(reshape2)

books<-fread("books_bagofwords.csv",header=TRUE)
ratings<-fread("ratings_9900.csv",header=TRUE)
users<-fread("users_new.csv",header=TRUE)

#Create ratings matrix. Rows = user_id, Columns = book_id
ratingmat <- dcast(ratings, user_id~book_id, value.var = "rating", na.rm=FALSE)
ratingmat <- as.matrix(ratingmat[,-1]) #remove userIds

# Method: UBCF

#Convert rating matrix into a recommenderlab sparse matrix
ratingmat <- as(ratingmat, "realRatingMatrix")


#Create UBCF Recommender Model
recommender_model <- Recommender(ratingmat, 
                                 method = "UBCF") 

#Writing a function which returns a user's recommendations
recommend_books<-function(input)
{
  recom <- predict(recommender_model, 
                   ratingmat[input], 
                   n=20) #Obtain top 20 recommendations for xth user in dataset
  
  recom_list <- as(recom, "list") #convert recommenderlab object to readable list
  
  #Obtain recommendations
  
  recom_books <- matrix(0,20)
  for (i in 1:20){
    recom_books[i] <- as.character(subset(books, 
                                          books$book_id == as.integer(recom_list[[1]][i]))$title)
  }
  
  return(recom_books)
}

mybooks<-function(input){
  id_user<-users$user_id[users$user_no==input]
  id_books<-ratings$book_id[ratings$user_id==id_user]
  list_books<-books$title[books$book_id%in%id_books]
  return(list_books)
  
}


shinyServer(function(input, output) {
  output$txt<-renderText(users$user_name[users$user_no==input$user_no])
  
  list_recom <- eventReactive(input$goButton, {
    recommend_books(input$user_no)
  })
  
  list_books <- eventReactive(input$readhistory, {
    mybooks(input$user_no)
  })
  
  output$recom <- renderTable({
    list_recom()
  })
  
  output$myhistory<-renderTable({
    list_books()
  })
})



