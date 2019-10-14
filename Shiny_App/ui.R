
shinyUI(dashboardPage(
  dashboardHeader(title = 'Vaccine AE Trends'),
  dashboardSidebar(
    sidebarUserPanel("Aron Berke", image = "./Aron_old_headshot.jpeg"),
    sidebarMenu(
      menuItem("Introduction", tabName = 'intro', icon = icon("info-circle")),
      menuItem("Adverse Events", tabName = "adverse_events", icon = icon("hospital")),
      menuItem("Symptoms", tabName = "symptoms", icon = icon("heartbeat")),
      menuItem("Data", tabName = "data", icon = icon("database"))
    )
  ),
  dashboardBody(tabItems(
    tabItem(tabName = 'intro',
            fluidRow(
              box(HTML('The Vaccine Adverse Event Reporting System (VAERS) was created by the Food and Drug Administration (FDA) and Centers for Disease Control and Prevention (CDC) to receive reports about adverse events that may be associated with vaccines. 
              Providers, patients, and caregivers can file reports, and reports are not medically confirmed.<br><br> 
              This Shiny App allows users to explore VAERS data from the past 5 years and uncover trends in the reporting of adverse events related to routine pediatric vaccinations. 
              Specifically, this app was designed with the intent to allow users to generate hypotheses on how the resurgence of the anti-vaccination movement in the run-up to the 2016 presidential election (1) in the US may have impacted reporting trends.<br><br>
              The data presented in this app was filtered to include only reports of adverse events related to routine scheduled vaccinations for children aged 18 and under. 
              Reports related to improper administration or storage of vaccines were also removed.<br><br>
              <font color=\'red\'>Caution should be applied when drawing insights from these data. 
              In addition to being unverified, a single report may be tied to the simultaneous administration of multiple vaccines, making causality difficult to establish. 
              Vaccination rates and reporting bias are unknown, and incidence rates cannot therefore be calculated(2).</font>'), title = 'Trends in Children\'s Vaccine Adverse Event Reporting Introduction', solidHeader = TRUE,
                  status = 'primary', width = 12, footer = '(1)https://www.washingtonexaminer.com/news/vaccination-controversy-puts-politicians-on-the-spot<br>
                  (2)https://vaers.hhs.gov/docs/VAERSDataUseGuide_October2017.pdf')
            )
            ),
    tabItem(tabName = 'adverse_events',
            fluidRow(
              column(3,
                checkboxGroupInput('severity', 
                                   'Please Select Adverse Event Severity', 
                                   choices = unique(vrs_all$severity))
              ),
              column(9, box(plotOutput("count"), title = 'Frequency of Reported Adverse Events by Severity and Year*', 
                            status ='primary', solidHeader = TRUE, width = 12, footer = "*An single adverse event report in the VAERS system 
                            may correspond to multiple severity categories (e.g., a patient may have visited the emergency room, and then become hospitalized). 
                            In the above graph, each event was encoded as belonging to the single most severe category reported. Order of severity is died>>
                            disabled>>life_threatening>>hospitalized>>er_visit>>non-serious."
                            )
            )
            ),
            fluidRow(
              column(12, br())
            ),
            fluidRow(
              column(9, offset = 3, box(plotOutput("index"), title = "Relative Growth in Reported Adverse Events by Severity",
                                        status = 'primary', solidHeader = TRUE, width=12, 
                                        footer = "This graph represents the percentage growth in the number of adverse events in each severity category
                                        relative to the year 2014.")
                     )
            )
          ),
    tabItem(tabName = 'symptoms',
            fluidRow(
              column(5,
                     selectizeInput('severity2', 'Please Select Adverse Event Severity',
                                    choices = unique(vrs_all$severity)),
                     fluidRow(
                       column(12,
                              sliderInput('symp_num', 'Please Select Number of Distinct Symptoms to Display',
                                          min=0, max=5, value=1)
                       )
                     ),
                     fluidRow(
                       column(12,
                              selectizeInput('year', 'Please Select Year',
                                             choices = unique(vrs_all$year))
                       )
                     )
              ),
              column(7, box(plotOutput("symptom"),title = 'Most Commonly Reported Symptoms by Severity and Year',
                     status = 'primary', solidHeader = TRUE, width = 12, footer = "This graph displays the top n most frequently reported symptoms
                     for events in each severity category. In the VAERS system, an unlimited number of distinct symptoms may be reported for each event.
                     This analysis collected on the first 5 symptoms listed for each report."
                     )
              )
            ),
            fluidRow(
              column(12, br())
            ),
            fluidRow(
              column(5, 
                     searchInput('search', 'Please Type in Symptom (and press enter)')),
              column(7, box(plotOutput("symptom2"), title = 'Total Symptom Count by Symptom and Year', status = 'primary',
                            solidHeader = TRUE, width = 12, footer = 'This graph displays the total number of times a symptom was reported across all
                            severity categories each year.'
                            )
                     )
              )
            ),
    tabItem(tabName = 'data',
            fluidRow(
              column(6,box(
                DT::dataTableOutput('table_ae'), width = 12, title = 'Frequency of Reported Adverse Events by Severity and Year Data Table'  
              )
            ),
            column(6, box(
              DT::dataTableOutput('table_ind'), width =12, title = 'Relative Growth in Reported Adverse Events by Severity Data Table'
            ))
            ),
            fluidRow(
              column(6,box(
              DT::dataTableOutput('table_symp'), width = 12, title = 'Most Commonly Reported Symptoms by Severity and Year Data Table'
            )),
              column(6, box(
                DT::dataTableOutput('table_symp2'), width = 12, title = 'Total Symptom Count by Symptom and Year Data Table'
              ))
            )
            )
  ))
))                        

