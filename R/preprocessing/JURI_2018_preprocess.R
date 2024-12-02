# The JuriGlobe index of states and constitutional systems is published as
# a PDF table, text is vertically aligned to the middle of cells making
# automated processing difficult.
#
# Pre-processing workflow: convert the PDF to text, then edit
# manually to a tidy fixed-width format: one line per country, data columns
# start in the same line column position on each line.

# PDF input
juri_pdf <- "data_raw/JURI_2018/EN_index.pdf"

# get text from the PDF
juri_text <- pdftools::pdf_text(juri_pdf)

# store a raw dump of the text for reference purposes
writeLines(
  juri_text,
  "data_raw/JURI_2018/EN_index_raw.txt"
)

# store the version to edit and manually process
writeLines(
  juri_text,
  "data_raw/JURI_2018/EN_index_edited.txt"
)