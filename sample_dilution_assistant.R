sample_dilution_helper <- function(a, b, minc = NA, maxc = NA, minresp = NA, maxresp = NA,
                                   sample_unit = 'mg',
                                   dil_unit = 'mL',
                                   dil_size = 5,
                                   sample_aliquots = c(500, 300, 250, 200, 150, 100, 75, 50, 25, 15, 10, 5),
                                   dilutions_count = NA,
                                   response = '',
                                   curve_title = '',
                                   curve_subtitle = ''){
  
  dil <- 1 # dilution factor
  
  calibration_curve <- function(x){(a * x + b) / dil} # (a*x+b)
  calibration_curve_inv <- function(x){(x - b) / a * dil} # ((x-b)/a)
  
  if (!is.na(minc) && is.na(minresp)) minresp <- calibration_curve_inv(minc)
  if (!is.na(maxc) && is.na(maxresp)) maxresp <- calibration_curve_inv(maxc)
  
  
  if (!is.na(curve_subtitle)){
    curve_subtitle <- paste('original curve equation: c =', a, '* x',
                            (if(b>0){'+'}), b, '{', minc, ':', maxc, '}', sep = ' ')
  }
  
  plot_ylim <- c(0.01, signif(calibration_curve_inv(maxc)*1.1, 2)) ## MAXRESP!?
  plot_xlim <- c(0.01, 250)
  
  toppoint <- maxresp + (maxresp - minresp) * 0.05
  #toppoint <-  maxc + (maxc - minc) * 0.05
  
  
  plot( # NEW
    calibration_curve_inv,
    from = plot_ylim[1], #0.01,
    to = calibration_curve(toppoint),
    col = 'black',
    xlim = plot_xlim,
    ylim = plot_ylim,
    xlab = paste('Raw sample concentration [mg/', sample_unit, ']', sep = ''),
    ylab = paste('Response [', response, ']', sep = ''),
    main = paste(curve_title, '\n', curve_subtitle),
    cex.main = 1
  )
  
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
  
  
  if((sample_unit %in% c('mg', 'uL', 'ul', 'µL', 'µl')) && (dil_unit %in% c('g', 'mL', 'ml'))) {
    unitfactor <- 1000
  } else {
    unitfactor <- 1
  }
  
  
  
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
  
  abline(h = minresp, col = 'blue', lty = 'dashed')
  abline(h = maxresp, col = 'red', lty = 'dashed')
  
}
