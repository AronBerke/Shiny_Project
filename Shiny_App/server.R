
function(input, output, session) {
  
  sev_cats <- reactive({
    filter(vrs_all, severity %in% c(input$severity)) %>%  
      group_by(., year, severity) %>% 
      summarize(count = n()) 
  })
  
  symp_vers <- reactive({
    gather(vrs_all, key = 'symptom_num', value = "symptom", symptom1:symptom5)
  })
  
  output$count = renderPlot(
    sev_cats() %>% 
      ggplot(., aes(x=year, y=count)) +
      geom_area(aes(fill = severity, group=severity)) +
      ylab('Number of Adverse Events') +
      xlab('Year')+
      labs(fill = "Severity Category") +
      theme(axis.title.y=element_text(size = 12), axis.title.x = element_text(size=12), legend.title = element_text(size=12))
  )
  
  output$index = renderPlot(
    sev_cats() %>% 
      group_by(.,severity) %>% 
      mutate(.,ind = (count/first(count))*100) %>% 
      ggplot(., aes(x=year, y=ind)) +
      geom_line(aes(color=severity)) +
      theme(panel.grid.major.x = element_blank(), panel.grid.minor.x = element_blank())+
      ylab('Index (2014 = 100)') +
      xlab('Year') +
      labs(color = "Severity Category")+
      theme(axis.title.y=element_text(size = 12), axis.title.x = element_text(size=12), legend.title = element_text(size=12))
  )
  
  output$symptom = renderPlot(
   symp_vers() %>% 
     filter(., year == input$year, severity == input$severity2, is.na(symptom) == F, 
            !symptom %in% c("Blood test", 'Electroencephalogram normal', 
                            'Electroencephalogram', 'Enema administration', 'Blood culture negative',
                            'Full blood count','Incorrect storage of drug', 'Full blood count normal', 'Nuclear magnetic resonance imaging')) %>% 
      group_by(., symptom) %>% 
      summarize(count=n()) %>% 
      top_n(., n=input$symp_num, wt=count) %>% 
      ggplot(., aes(x=symptom, y = count)) +
      geom_col(aes(fill=symptom))+
      ylab('Reported Symptom Count')+
      xlab('Symptom') +
     theme(axis.text.x = element_text(angle = 45, hjust = 1),
           axis.title.y=element_text(size = 12), axis.title.x = element_text(size=12), legend.title = element_text(size=12))
  )
  
  output$symptom2 = renderPlot(
    symp_vers() %>% 
      filter(., symptom == input$search) %>% 
      group_by(., year) %>% 
      summarize(count=n()) %>% 
      ggplot(., aes(x=year, y = count)) +
      geom_col(fill = 'Blue') +
      ylab('Reported Symptom Count') +
      xlab('Year') +
      theme(axis.title.y=element_text(size = 12), axis.title.x = element_text(size=12))
  )
  
  output$table_ae <- DT::renderDataTable({
    datatable(sev_cats(), rownames=FALSE) 
  })
  
  output$table_ind <- DT::renderDataTable({
    datatable(sev_cats() %>% 
                group_by(.,severity) %>% 
                mutate(.,index = (count/first(count))*100), 
              rownames=FALSE) 
  })
  
  output$table_symp <- DT::renderDataTable({
    symp_vers() %>% 
      filter(., year == input$year, severity == input$severity2, is.na(symptom) == F, 
             !symptom %in% c("Blood test", 'Electroencephalogram normal', 
                             'Electroencephalogram', 'Enema administration', 'Blood culture negative',
                             'Full blood count','Incorrect storage of drug', 'Full blood count normal', 'Nuclear magnetic resonance imaging')) %>% 
      group_by(., symptom) %>% 
      summarize(count=n()) %>% 
      top_n(., n=input$symp_num, wt=count)
  })
  
  output$table_symp2 <- DT::renderDataTable({
    symp_vers() %>% 
      filter(., symptom == input$search) %>% 
      group_by(., year) %>% 
      summarize(count=n())
  })
  
}