# manual initialisation of explicit arguments
a <- 0.00000049555
b <- - 0.024
minc <- 0.1256
maxc <- 4.0068

# absolutely basic example (everything in mg/mL, a volume is drawn and by volume is diluted)
sample_dilution_assistant(a, b, minc, maxc)

# same, but with narrowed raw sample concentration range
sample_dilution_assistant(a, b, minc, maxc, maxc_limit = 10)

# same as the first one, but with analyte measured in micrograms
# + detector response unit is added
sample_dilution_assistant(a, b, minc, maxc, analyte_unit = 'µg', response = 'mAu')

# same as above, but diluted to 1 mL
sample_dilution_assistant(a, b, minc, maxc, analyte_unit = 'µg', response = 'mAu', dil_size = 1)

# different approach: sample is WEIGHED, then diluted to a given volume
sample_dilution_assistant(a, b, minc, maxc, sample_unit = 'mg')

# a title is added
curtitle <- '### WEIGH the sample, then dilute to 5 mL ###'
sample_dilution_assistant(a, b, minc, maxc, sample_unit = 'mg', curve_title = curtitle)

# 12 different aliquots instead of default 5
sample_dilution_assistant(a, b, minc, maxc, dilution_count = 12)

# user-specified aliquots
user_aliquots <- c(0.8, 0.5, 0.375, 0.25, 0.18, 0.125, 0.05, 0.03)
sample_dilution_assistant(a, b, minc, maxc, sample_aliquots = user_aliquots)
