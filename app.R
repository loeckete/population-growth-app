# <!-- Google tag (gtag.js) -->
#   <script async src="https://www.googletagmanager.com/gtag/js?id=G-RWVG6BYSDE"></script>
#     <script>
#     window.dataLayer = window.dataLayer || [];
#     function gtag(){dataLayer.push(arguments);}
#     gtag('js', new Date());
#     
#     gtag('config', 'G-RWVG6BYSDE');
#     </script>
      
library(shiny)
library(ggplot2)

# ENSCI 3120: Exponential vs. carrying-capacity-limited growth
# Rename this file to app.R before placing it in a Shinylive repository.

ui <- fluidPage(
    
    tags$head(
      tags$script(
        async = NA,
        src = "https://www.googletagmanager.com/gtag/js?id=G-ABC1234567"
      ),
      tags$script(
        HTML("
        window.dataLayer = window.dataLayer || [];
        function gtag(){dataLayer.push(arguments);}
        gtag('js', new Date());
        gtag('config', 'G-RWVG6BYSDE');
      ")
      )
    ),
    
    # The remainder of the existing interface follows here
  tags$head(
    tags$style(HTML("
      .well { background-color: #f5f8f4; }
      .model-box { padding: 12px; margin-bottom: 12px; border-radius: 6px;
                   background: #eef5ea; border-left: 5px solid #4b7f52; }
      .question-box { padding: 12px; border-radius: 6px;
                      background: #fff7df; border-left: 5px solid #d89b28; }
    "))
  ),

  titlePanel("Population Growth: Unlimited vs. Limited"),

  sidebarLayout(
    sidebarPanel(
      p("Change the population parameters to compare exponential growth with logistic growth."),

      sliderInput(
        "n0", "Initial population size (N₀):",
        min = 1, max = 100, value = 10, step = 1
      ),
      sliderInput(
        "r", "Per-capita growth rate (r):",
        min = 0.01, max = 1, value = 0.20, step = 0.01
      ),
      sliderInput(
        "k", "Carrying capacity (K):",
        min = 100, max = 10000, value = 1000, step = 100
      ),
      sliderInput(
        "duration", "Simulation duration:",
        min = 5, max = 50, value = 30, step = 1
      ),
      checkboxInput("log_scale", "Use a logarithmic population axis", FALSE),
      helpText("Time units may represent days, months, or years, as long as r uses the same unit."),
      actionButton("earth_example", "Load illustrative example")
    ),

    mainPanel(
      tabsetPanel(
        tabPanel(
          "Growth curves",
          br(),
          plotOutput("growth_plot", height = "500px"),
          div(
            class = "question-box",
            strong("Think about it: "),
            textOutput("prompt", inline = TRUE)
          )
        ),

        tabPanel(
          "Logistic growth explorer",
          br(),
          plotOutput("logistic_plot", height = "500px"),
          div(
            class = "model-box",
            strong("What to notice: "),
            textOutput("logistic_summary", inline = TRUE)
          ),
          div(
            class = "question-box",
            strong("Explore: "),
            "Change r while holding K constant. Then change K while holding r constant. Which parameter changes the speed of approach, and which changes the population's upper limit?"
          )
        ),

        tabPanel(
          "Density dependence",
          br(),
          p(
            "Use density-dependent birth and death rates to make carrying capacity emerge from demographic processes. Rates are measured per individual per unit time."
          ),
          fluidRow(
            column(
              width = 4,
              wellPanel(
                sliderInput(
                  "birth_zero", "Birth rate at very low density (b₀):",
                  min = 0.40, max = 1.20, value = 0.80, step = 0.05
                ),
                sliderInput(
                  "death_zero", "Death rate at very low density (d₀):",
                  min = 0.05, max = 0.35, value = 0.20, step = 0.05
                ),
                sliderInput(
                  "birth_dd", "Birth-rate decline per 1,000 individuals:",
                  min = 0.05, max = 0.80, value = 0.30, step = 0.05
                ),
                sliderInput(
                  "death_dd", "Death-rate increase per 1,000 individuals:",
                  min = 0.05, max = 0.80, value = 0.30, step = 0.05
                ),
                helpText(
                  "Examples include competition reducing reproduction and crowding increasing disease or mortality."
                )
              ),
              div(
                class = "model-box",
                h4("Emergent carrying capacity"),
                textOutput("emergent_k"),
                withMathJax("$$K = 1000\\frac{b_0-d_0}{a+c}$$")
              )
            ),
            column(
              width = 8,
              plotOutput("vital_rates_plot", height = "390px")
            )
          ),
          fluidRow(
            column(
              width = 8,
              plotOutput("density_growth_plot", height = "390px")
            ),
            column(
              width = 4,
              div(
                class = "question-box",
                h4("Interpret the graphs"),
                tags$ol(
                  tags$li("Where do birth and death rates balance?"),
                  tags$li("Why is total growth greatest near K/2 rather than at very low density?"),
                  tags$li("What happens when population size exceeds K?"),
                  tags$li("Which ecological mechanisms could change these lines?")
                )
              ),
              br(),
              div(
                class = "model-box",
                strong("Key distinction: "),
                "Per-capita growth is greatest at low density, while total population growth is greatest at K/2."
              )
            )
          )
        ),

        tabPanel(
          "Compare values",
          br(),
          h4("Population sizes at selected times"),
          tableOutput("comparison_table"),
          h4("End of the simulation"),
          verbatimTextOutput("ending_summary")
        ),

        tabPanel(
          "How the models differ",
          br(),
          div(
            class = "model-box",
            h4("Discrete exponential growth"),
            withMathJax("$$N_{t+1} = \\lambda N_t$$"),
            p(
              "The finite rate of increase, λ, remains constant from one census interval to the next. Resources never become limiting, so population size is multiplied by the same factor during every interval."
            )
          ),
          div(
            class = "model-box",
            h4("Standard discrete logistic model"),
            withMathJax("$$N_{t+1} = r_d N_t \\left(1-\\frac{N_t}{K}\\right)$$"),
            p(
              "The multiplier now depends on current population size. As Nₜ increases relative to K, the density-dependent term becomes smaller, reducing growth during the next census interval. Depending on r_d, the model can approach an equilibrium smoothly, oscillate, or display complex dynamics."
            )
          ),
          tags$ul(
            tags$li(strong("Nₜ"), " = population size at the current census"),
            tags$li(strong("Nₜ₊₁"), " = population size at the next census"),
            tags$li(strong("λ"), " = density-independent finite rate of increase"),
            tags$li(strong("r_d"), " = discrete logistic growth parameter"),
            tags$li(strong("K"), " = carrying-capacity or density-scaling parameter")
          ),
          p(
            strong("Discrete versus continuous time: "),
            "These equations update the population in separate census intervals. The growth-curve tabs use a smooth continuous-time logistic curve, while this comparison follows the discrete logistic-map formulation shown above."
          ),
          p(
            strong("Important: "),
            "Carrying capacity is not necessarily fixed in nature. It can change when resources, climate, habitat, competitors, or predators change."
          )
        )
      )
    )
  )
)

server <- function(input, output, session) {

  observeEvent(input$earth_example, {
    updateSliderInput(session, "n0", value = 10)
    updateSliderInput(session, "r", value = 0.25)
    updateSliderInput(session, "k", value = 1500)
    updateSliderInput(session, "duration", value = 35)
  })

  population_data <- reactive({
    time <- seq(0, input$duration, length.out = 500)

    exponential <- input$n0 * exp(input$r * time)
    logistic <- input$k / (
      1 + ((input$k - input$n0) / input$n0) * exp(-input$r * time)
    )

    rbind(
      data.frame(Time = time, Population = exponential,
                 Model = "Exponential (unlimited)"),
      data.frame(Time = time, Population = logistic,
                 Model = "Logistic (limited by K)")
    )
  })

  output$growth_plot <- renderPlot({
    p <- ggplot(
      population_data(),
      aes(x = Time, y = Population, color = Model, linetype = Model)
    ) +
      geom_line(linewidth = 1.25) +
      geom_hline(
        yintercept = input$k,
        color = "#4b7f52", linetype = "dotted", linewidth = 0.9
      ) +
      annotate(
        "text", x = input$duration * 0.98, y = input$k,
        label = paste("K =", format(input$k, big.mark = ",")),
        hjust = 1.05, vjust = -0.5, color = "#35603b"
      ) +
      scale_color_manual(values = c(
        "Exponential (unlimited)" = "#d95f02",
        "Logistic (limited by K)" = "#1b7837"
      )) +
      labs(
        title = "Two models beginning with the same population",
        subtitle = paste0(
          "N₀ = ", input$n0, ", r = ", input$r,
          ", K = ", format(input$k, big.mark = ",")
        ),
        x = "Time", y = "Population size", color = NULL, linetype = NULL
      ) +
      theme_minimal(base_size = 13) +
      theme(
        legend.position = "bottom",
        plot.title = element_text(face = "bold")
      )

    if (isTRUE(input$log_scale)) {
      p <- p + scale_y_log10(labels = scales::label_number())
    } else {
      p <- p + scale_y_continuous(labels = scales::label_number(big.mark = ","))
    }

    p
  })

  output$logistic_plot <- renderPlot({
    logistic_only <- population_data()[
      population_data()$Model == "Logistic (limited by K)",
    ]

    half_k <- input$k / 2
    closest_to_half <- which.min(abs(logistic_only$Population - half_k))
    if (input$n0 <= half_k && max(logistic_only$Population) >= half_k) {
      half_point <- logistic_only[closest_to_half, ]
    } else {
      half_point <- logistic_only[0, ]
    }

    ggplot(logistic_only, aes(x = Time, y = Population)) +
      annotate(
        "rect", xmin = -Inf, xmax = Inf, ymin = 0, ymax = input$k,
        fill = "#e7f2e5", alpha = 0.55
      ) +
      geom_hline(
        yintercept = input$k,
        color = "#35603b", linetype = "dotted", linewidth = 1
      ) +
      geom_hline(
        yintercept = half_k,
        color = "#6b8e6b", linetype = "dashed", linewidth = 0.8
      ) +
      geom_line(color = "#1b7837", linewidth = 1.4) +
      geom_point(
        data = half_point,
        aes(x = Time, y = Population),
        color = "#d95f02", size = 3
      ) +
      annotate(
        "text", x = input$duration * 0.98, y = input$k,
        label = paste("Carrying capacity, K =", format(input$k, big.mark = ",")),
        hjust = 1, vjust = -0.55, color = "#35603b"
      ) +
      annotate(
        "text", x = input$duration * 0.98, y = half_k,
        label = "K/2: maximum population growth rate",
        hjust = 1, vjust = -0.55, color = "#536f53"
      ) +
      scale_y_continuous(
        limits = c(0, input$k * 1.12),
        labels = scales::label_number(big.mark = ",")
      ) +
      labs(
        title = "Logistic population growth",
        subtitle = paste0(
          "N₀ = ", input$n0, ", r = ", input$r,
          ", K = ", format(input$k, big.mark = ",")
        ),
        x = "Time", y = "Population size"
      ) +
      theme_minimal(base_size = 13) +
      theme(plot.title = element_text(face = "bold"))
  })

  output$logistic_summary <- renderText({
    if (input$n0 < input$k / 2) {
      time_to_half <- log((input$k - input$n0) / input$n0) / input$r
      if (time_to_half <= input$duration) {
        paste0(
          "The curve is steepest near K/2 (N = ",
          format(round(input$k / 2), big.mark = ","),
          "), reached at approximately time ", round(time_to_half, 1),
          ". Growth then slows as N approaches K."
        )
      } else {
        paste0(
          "The population would reach K/2 at approximately time ",
          round(time_to_half, 1),
          ", beyond the displayed simulation. Increase the duration to see the inflection point."
        )
      }
    } else if (input$n0 == input$k / 2) {
      "The population begins at K/2, where total population growth is at its maximum."
    } else {
      "The population begins above K/2. It is already past its maximum total growth rate and slows as it approaches K."
    }
  })

  density_dependence_data <- reactive({
    # a and c describe the change in vital rates per 1,000 individuals.
    k_emergent <- 1000 *
      (input$birth_zero - input$death_zero) /
      (input$birth_dd + input$death_dd)

    max_population <- max(100, 1.35 * k_emergent)
    population <- seq(0, max_population, length.out = 500)

    birth_rate <- pmax(
      0,
      input$birth_zero - input$birth_dd * population / 1000
    )
    death_rate <- input$death_zero + input$death_dd * population / 1000
    per_capita_growth <- birth_rate - death_rate
    total_growth <- population * per_capita_growth

    list(
      k = k_emergent,
      rates = rbind(
        data.frame(
          Population = population,
          Rate = birth_rate,
          VitalRate = "Birth rate"
        ),
        data.frame(
          Population = population,
          Rate = death_rate,
          VitalRate = "Death rate"
        )
      ),
      growth = data.frame(
        Population = population,
        PerCapitaGrowth = per_capita_growth,
        TotalGrowth = total_growth
      )
    )
  })

  output$emergent_k <- renderText({
    values <- density_dependence_data()
    paste0(
      "Births equal deaths at N = ",
      format(round(values$k), big.mark = ","),
      ". At this density, net population growth is zero."
    )
  })

  output$vital_rates_plot <- renderPlot({
    values <- density_dependence_data()

    ggplot(
      values$rates,
      aes(x = Population, y = Rate, color = VitalRate)
    ) +
      geom_hline(yintercept = 0, color = "grey75") +
      geom_vline(
        xintercept = values$k,
        color = "#35603b", linetype = "dotted", linewidth = 1
      ) +
      geom_line(linewidth = 1.3) +
      annotate(
        "point", x = values$k,
        y = input$death_zero + input$death_dd * values$k / 1000,
        color = "black", size = 3
      ) +
      annotate(
        "text", x = values$k,
        y = input$death_zero + input$death_dd * values$k / 1000,
        label = "Births = deaths\nNet growth = 0",
        hjust = -0.08, vjust = 1.25, size = 3.6
      ) +
      scale_color_manual(values = c(
        "Birth rate" = "#2166ac",
        "Death rate" = "#b2182b"
      )) +
      scale_x_continuous(labels = scales::label_number(big.mark = ",")) +
      labs(
        title = "Density-dependent vital rates",
        subtitle = "Their intersection determines carrying capacity",
        x = "Population size (N)",
        y = "Per-capita vital rate",
        color = NULL
      ) +
      coord_cartesian(clip = "off") +
      theme_minimal(base_size = 13) +
      theme(
        legend.position = "bottom",
        plot.title = element_text(face = "bold")
      )
  })

  output$density_growth_plot <- renderPlot({
    values <- density_dependence_data()
    growth <- values$growth
    half_k <- values$k / 2
    max_growth <- max(growth$TotalGrowth)

    ggplot(growth, aes(x = Population, y = TotalGrowth)) +
      geom_hline(yintercept = 0, color = "grey55") +
      geom_vline(
        xintercept = half_k,
        color = "#d95f02", linetype = "dashed", linewidth = 0.9
      ) +
      geom_vline(
        xintercept = values$k,
        color = "#35603b", linetype = "dotted", linewidth = 1
      ) +
      geom_line(color = "#1b7837", linewidth = 1.3) +
      annotate(
        "point", x = half_k, y = max_growth,
        color = "#d95f02", size = 3
      ) +
      annotate(
        "text", x = half_k, y = max_growth,
        label = "Maximum total growth at K/2",
        hjust = -0.08, vjust = -0.7, color = "#a34700", size = 3.6
      ) +
      annotate(
        "text", x = values$k, y = 0,
        label = "K: net growth = 0",
        hjust = -0.08, vjust = 1.4, color = "#35603b", size = 3.6
      ) +
      scale_x_continuous(labels = scales::label_number(big.mark = ",")) +
      scale_y_continuous(labels = scales::label_number(big.mark = ",")) +
      labs(
        title = "Total population growth is density dependent",
        subtitle = "Above K, deaths exceed births and population growth becomes negative",
        x = "Population size (N)",
        y = "Total change in population (dN/dt)"
      ) +
      coord_cartesian(clip = "off") +
      theme_minimal(base_size = 13) +
      theme(plot.title = element_text(face = "bold"))
  })

  output$comparison_table <- renderTable({
    selected_times <- unique(round(seq(0, input$duration, length.out = 6), 1))
    exp_n <- input$n0 * exp(input$r * selected_times)
    log_n <- input$k / (
      1 + ((input$k - input$n0) / input$n0) * exp(-input$r * selected_times)
    )

    data.frame(
      Time = selected_times,
      `Exponential population` = format(round(exp_n), big.mark = ",", scientific = FALSE),
      `Logistic population` = format(round(log_n), big.mark = ",", scientific = FALSE),
      check.names = FALSE
    )
  }, striped = TRUE, bordered = TRUE, spacing = "s")

  output$ending_summary <- renderText({
    t <- input$duration
    exp_end <- input$n0 * exp(input$r * t)
    log_end <- input$k / (
      1 + ((input$k - input$n0) / input$n0) * exp(-input$r * t)
    )
    ratio <- exp_end / log_end

    paste0(
      "Exponential population: ", format(exp_end, digits = 5, scientific = exp_end >= 1e7), "\n",
      "Logistic population:    ", format(log_end, digits = 5, scientific = FALSE, big.mark = ","), "\n",
      "Exponential/logistic ratio: ", format(ratio, digits = 4, scientific = ratio >= 1e6), " times"
    )
  })

  output$prompt <- renderText({
    if (input$n0 < input$k / 2) {
      "At approximately what population size does logistic growth proceed most rapidly?"
    } else {
      "Why does logistic growth slow when the population begins near carrying capacity?"
    }
  })
}

shinyApp(ui = ui, server = server)
