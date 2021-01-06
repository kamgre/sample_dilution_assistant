sample_dilution_assistant <- function(
  a, 
  b, 
  minc = NA, # lower curve boundary, as concentration 
  maxc = NA, # upper curve boundary, as concentration
  minresp = NA, # lower curve boundary, as response
  maxresp = NA, # upper curve boundary, as response
  analyte_unit = 'mg', # default unit for the curve and sample analyte concentration
  sample_unit = 'mL', # sample size unit
  dil_unit = 'mL', # target (dilution) size unit
  dil_size = 5, # target (dilution) size; unit as above
  sample_aliquots = NA, # preferred aliquots - specify them if you like them; 
  # be aware that sample_aliquots OVERRIDES the dilution_count!!!
  response = ' ', # detector response unit; negligible
  curve_title = '',
  curve_subtitle = '',
  maxc_limit = 200, # maximal concentration covered by the plot
  dilution_count = 5 # how many different dilutions you want to see
  )
{
  
  dil <- 1 # internal factor, do not change!
  
  calibration_curve <- function(x){(a * x + b) / dil} # (a*x+b)
  calibration_curve_inv <- function(x){(x - b) / a * dil} # ((x-b)/a)
  
  # generate concentration boundaries if response boundaries were given instead
  if (!is.na(minc) && is.na(minresp)) minresp <- calibration_curve_inv(minc)
  if (!is.na(maxc) && is.na(maxresp)) maxresp <- calibration_curve_inv(maxc)
  
  # generate curve subtitle from given curve equation
  if (!is.na(curve_subtitle)){
    
    curve_subtitle <- paste('original curve equation: c  = ', a, ' * x ',
                            (if(b>0){'+'}), b, '  ///  ', minc, ' : ', maxc, ' [',
                            analyte_unit, '/', dil_unit, ']', sep = '')
  }
  
  #some text manipulations
  if (response != ' ') response <- paste('[', response, ']', sep = '')
  
  #plot limits calculation
  plot_ylim <- c(0.01, signif(calibration_curve_inv(maxc)*1.1, 2)) ## MAXRESP!?
  plot_xlim <- c(0.01, maxc_limit)
  
  toppoint <- maxresp + (maxresp - minresp) * 0.05
  
  # initial plot
  plot( # NEW
    calibration_curve_inv,
    from = plot_ylim[1], #0.01,
    to = calibration_curve(toppoint),
    col = 'black',
    xlim = plot_xlim,
    ylim = plot_ylim,
    xlab = paste('Raw sample concentration [', analyte_unit, '/', sample_unit, ']', sep = ''), ###
    ylab = paste('Response', response, sep = ' '),
    main = paste(curve_title, '\n', curve_subtitle),
    cex.main = 1
  )
  
  
  # initial plot labeling
  text(x = calibration_curve(toppoint),
       y = toppoint,
       label = '[raw]')
  text(
    x = plot_xlim[2] / 2,
    y = plot_ylim[2],
    label = paste(
      'dilution as [', sample_unit , '] of raw sample per ', dil_size, ' [', dil_unit, 
      '] of final sample size', sep = '')
  )
  
  # units magnitude handler
  if((sample_unit %in% c('mg', 'uL', 'ul', 'µL', 'µl')) && (dil_unit %in% c('g', 'mL', 'ml'))) {
    unitfactor <- 1000
  } else {
    unitfactor <- 1
  }
  
  # specified sample_aliquots vs dilution_count handling,
  # evenly-distributed aliquots calculation
  if (is.na(sample_aliquots)[1] & !is.na(dilution_count)){
    xrange <- plot_xlim[2] - maxc
    yrange <- plot_ylim[2] - calibration_curve_inv(minc)

    horizontal_steps <- ceiling(dilution_count/2)
    vertical_steps <- dilution_count - horizontal_steps
    
    calculated_dilutions <- numeric(0L)
    sample_aliquots <- numeric(0L)
    
    for (i in 1:horizontal_steps) {
      dilution <- (calibration_curve_inv(maxc) / calibration_curve_inv(maxc + i / (horizontal_steps + 1) * xrange))
      calculated_dilutions <- c(calculated_dilutions, dilution)
    }
    
    for (i in 1:vertical_steps){
      dilution <- ((plot_ylim[2] - i / (vertical_steps + 1) * yrange) / calibration_curve_inv(plot_xlim[2]))
      calculated_dilutions <- c(calculated_dilutions, dilution)
    }
    
    for (i in 1:length(calculated_dilutions)){
      
      calculated_aliquot <- calculated_dilutions[i] * dil_size * unitfactor
      calculated_aliquot <- signif(calculated_aliquot, 2)
      sample_aliquots <- c(sample_aliquots, calculated_aliquot)
    }
    
  }
  
  # 'diluted' curves drawing and labeling,
  # according to specified or calculated aliquots
  for (i in 1:length(sample_aliquots)) {
    
    dil <- sample_aliquots[i] / dil_size / unitfactor # !!!!!!!
    
    plot(
      calibration_curve_inv,
      from = plot_ylim[1],
      to = calibration_curve(toppoint),
      col = 'grey',
      add = TRUE
    )
    
    if (calibration_curve(toppoint) < plot_xlim[2]) { ## WYJASNIC PLOT_XLIM
      text(
        x = calibration_curve(toppoint),
        y = toppoint,
        labels = paste(sample_aliquots[i])
      )
    }
    else {
      text(
        x = plot_xlim[2],
        y = calibration_curve_inv(plot_xlim[2]),
        labels = paste(sample_aliquots[i])
      )
    }
  }
  
  # finishing touch - curve response boundaries
  abline(h = minresp, col = 'blue', lty = 'dashed')
  abline(h = maxresp, col = 'red', lty = 'dashed')
  
}

