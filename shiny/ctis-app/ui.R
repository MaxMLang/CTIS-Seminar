library(shiny)
library(shinythemes)
library(shinycssloaders)
library(tmap)
library(tmaptools)
library(plotly)

data_CTIS_map <- readRDS("app-data/data_CTIS_map.RDS")
data_CTIS_policy <- readRDS("app-data/data_CTIS_policy.RDS")
named_variable_vec <- c("Anxious last 7 days (anxious_7d)" = "anxious_7d",
                         "Depressed last 7 days (depressed_7d)" = "depressed_7d",
                         "Worried about finance (finance)" = "finance",
                         "Worried about food security (food_security)" = "food_security",
                         "Worried to become ill (worried_become_ill)" = "worried_become_ill")
button_color_css <- "
#DivCompClear, #FinderClear, #EnterTimes{
/* Change the background color of the update button
to blue. */
background: DodgerBlue;
/* Change the text size to 15 pixels. */
font-size: 15px;
}"

shinyUI(fluidPage(
    navbarPage(id = "navbar", title = div(img(src='icon.png', style="background-color: transparent; margin-top: -10px;", height = 35), tags$a(href= "https://github.com/christian-hobelsberger/CTIS-Seminar", "CTIS Mental Health")),
               theme = shinytheme("lumen"),
        navbarMenu("Global", icon = icon("globe"),
                   tabPanel("Maps", fluid = TRUE, icon = icon("map"),
                            tags$style(button_color_css),
                            tags$style(HTML(".datepicker {z-index:99999 !important;}")),
                            sidebarLayout(
                                sidebarPanel(
                                    titlePanel("Map characteristics"),
                                    selectInput(inputId = "variable",
                                                label = "Select variable",
                                                choices = named_variable_vec,
                                                selected = "anxious_7d"
                                    ),
                                    dateInput(inputId = "date",
                                              label = "Select date",
                                              value = "2021-08-21",
                                              min = min(data_CTIS_map$data.survey_date, na.rm = T),
                                              max = max(data_CTIS_map$data.survey_date, na.rm = T)),
                                ),
                                mainPanel(
                                    titlePanel("Global map"),
                                    tmapOutput("global_map")
                                )
                            )
                   ),
        tabPanel("Analysis", icon = icon("chart-simple"),
                 sidebarLayout(
                     sidebarPanel(
                         titlePanel("Plot characteristics"),
                         selectInput("global_ana_variable",
                                     label = "Select co-variable",
                                     choices = c("Age group (E4)"= "E4", 
                                                 "Education level (E8)" = "E8", 
                                                 "Gender (E3)"= "E3", 
                                                 "Worked last 4 weeks (D7a)"= "D7a"),
                                     selected = "E4",
                                     width = "220px"),
                         checkboxInput("global_ana_checkbox",
                                     label = "Show over time",
                                     value = FALSE,
                                     width = "200px")
                     ),
                     mainPanel(
                         plotlyOutput("global_micro_ana_bar")
                     )
                     )
                 )),
        navbarMenu("Continental", icon = icon("earth-europe"),
                   tabPanel("Maps", fluid = TRUE, icon = icon("map"),
                            tags$style(button_color_css),
                            sidebarLayout(
                                sidebarPanel(
                                    titlePanel("Map characteristics"),
                                    selectInput(inputId = "continent",
                                                label = "Select continent",
                                                choices = na.omit(unique(data_CTIS_map$continent)),
                                                selected = "Europe"),
                                    selectInput(inputId = "cont_variable",
                                                label = "Select variable",
                                                choices = named_variable_vec,
                                                selected = "anxious_7d"
                                    ),
                                    dateInput(inputId = "cont_date",
                                              label = "Select date",
                                              value = "2021-08-21",
                                              min = min(data_CTIS_map$data.survey_date, na.rm = T),
                                              max = max(data_CTIS_map$data.survey_date, na.rm = T)),
                                ),
                                mainPanel(
                                    titlePanel("Continental map"),
                                    tmapOutput("cont_map")
                                )
                            )
                   ),
       tabPanel("Analysis", icon = icon("chart-simple"),
                 sidebarLayout(
                   sidebarPanel(
                     titlePanel("Plot characteristics"),
                     selectInput("cont_ana_variable",
                                 label = "Select variable",
                                 choices = named_variable_vec,
                                 selected = "anxious_7d"),
                     selectInput("cont_ana_continent",
                                 label = "Select continent",
                                 choices = unique(data_CTIS_policy$continent),
                                 selected = "Europe",
                                 multiple = TRUE)
                   ),
                   mainPanel(
                     plotlyOutput("cont_ana_line")
                   )
                 )
                )),
       navbarMenu("Country", icon = icon("flag"),
        tabPanel("Analysis", icon = icon("chart-simple"),
          sidebarLayout(
            sidebarPanel(
              titlePanel("Plot characteristics"),
              selectInput("country_ana_variable",
                          label = "Select variable",
                          choices = named_variable_vec,
                          selected = "anxious_7d"),
              selectizeInput("country_ana_country",
                          label = "Select country",
                          choices = unique(data_CTIS_policy$data.country),
                          selected = "Germany",
                          multiple = FALSE,
                          )
            ),
            mainPanel(
              plotlyOutput("country_ana_line")
            )
          )
    )),
    navbarMenu("More", icon = icon("info"),
               tabPanel("About", icon = icon("circle-question"),
                        fluidRow(
                          h1("About"),
                          p("Facebook and academic institutions have partnered to conduct the Global COVID-19 Trends and Impact Survey through the University of Maryland Social Data Science Center. The survey is offered in 56 different languages. Daily reports on themes like symptoms, social withdrawal, vaccine acceptance, mental health problems, and financial restrictions are requested from a representative sample of Facebook users. Facebook offers weights to lessen coverage bias and nonresponse. Daily country- and region-level statistics are made available to the general public via public APIs and dashboards, while microdata is made accessible to researchers via data usage agreements. Every day, more than 500,000 responses are gathered.")
                        )
                        ),
               tabPanel("Data dictionary", icon = icon("book"),
                        fluidRow(
                          h1("Data dictionary"),
                          tags$div(
                            "This short guide should help users of the application to understand the variables better. A complete data dictionary of the whole survey can be found ",
                            tags$a(href= "https://gisumd.github.io/COVID-19-API-Documentation/", "here"),
                            " on the website of the UMD.")
                          ),
                        br(),
                        p(code("anxious_7d"),  br(),"Respondents who reported feeling nervous for most or all of the time over the the past 7 days."),
                        p(code("depressed_7d"),  br(),"Respondents who reported feeling depressed most or all of the time over the past 7 days."),
                        p(code("worried_become_ill"),  br(),"Respondents who reported feeling very or somewhat worried that they or someone in their immediate family might become seriously ill from COVID-19."),
                        p(code("finance"),  br(),"Respondents who are very worried or somewhat worried about themselves and their household’s finances."),
                        p(code("food_security"),  br(),"Respondents who are very worried or somewhat worried about having enough to eat in the next week.")
                        ))
    )
    
)
    
)
