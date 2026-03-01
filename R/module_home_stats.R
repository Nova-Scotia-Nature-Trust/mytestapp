#' home_stats UI
#'
#' @param id Unique id for module instance.
#'
#' @keywords internal
home_statsUI <- function(id) {
	ns <- NS(id)

	tagList(
		h2("Home Stats"),

		actionButton(
			ns("refresh"),
			"Generate New Data"
		),

		br(),
		br(),

		tableOutput(ns("stats_table"))
	)
}


#' home_stats Server
#'
#' @param id Unique id for module instance.
#'
#' @keywords internal
#' @import dplyr
home_stats_server <- function(id) {
	moduleServer(
		id,
		function(input, output, session) {
			ns <- session$ns
			# send_message <- make_send_message(session)

			stats_data <- reactiveVal()

			# Function to generate raw data
			generate_data <- function() {
				data.frame(
					property_id = 1:50,
					status = sample(
						c("Secured", "In Progress", "High Priority"),
						50,
						replace = TRUE
					)
				)
			}

			# Initial load
			observe({
				raw <- generate_data()

				summary_tbl <- raw |>
					group_by(status) |>
					summarise(
						count = n(),
						.groups = "drop"
					)

				stats_data(summary_tbl)
			})

			# Regenerate on click
			observeEvent(input$refresh, {
				raw <- generate_data()

				summary_tbl <- raw |>
					group_by(status) |>
					summarise(
						count = n(),
						.groups = "drop"
					)

				stats_data(summary_tbl)
			})

			output$stats_table <- renderTable({
				stats_data()
			})
		}
	)
}
