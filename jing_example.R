########
# "NATIONAL" total amount control: CtryList - list of country names, natTotals - total amount new urban land development per country (km^2), estDF - dataframe of spatial model estimated t2 urban land fraction (newR), t1-t2 change in that faction (newD), t1-t2 amount of new development (amtD = grid land area * newD), available amount of land for new development (availLnd = grid land area * (usable land mask fraction - t1 urban land fraction)), and t1 urban land faction (rT1)

alloDF <- data.frame()
for (CTRY in CtryList) {
  ctryEstDF <- subset(estDF, grepl(paste("^", CTRY, "$", sep=""),  estDF$ISO))
  
  sumAvailLnd <- sum(ctryEstDF$availLnd)
  ctryBUChg <- subset(natTotals, grepl(paste("^", CTRY, "$", sep=""), natTotals$ISO))
  ctryBUChg <- as.numeric(ctryBUChg[paste0("diff00_", timeHorizon)])
  sumAmtD <- sum(ctryEstDF$amtD)
  
  if (sumAvailLnd <= ctryBUChg) {
    currAlloDF <- as.data.frame(ctryEstDF$originFID)
    currAlloDF$newR <- ctryEstDF$FinalMask
    currAlloDF$newD <- currAlloDF$newR - ctryEstDF$urbFrac00
    currAlloDF$newD <- ifelse(currAlloDF$newD < 0, 0, currAlloDF$newD) # in case of rounding error
    alloDF <- rbind(alloDF, currAlloDF)
    print(paste(CTRY, ": mode 1 (total overflows avail land)", sep=""))
    
  } else { # sumAvailLnd > ctryBUChg
    if (sumAmtD == 0) {
      sumRT1 <- sum(ctryEstDF$urbFrac00)
      if (sumRT1 == 0) {
        scaler <- ctryBUChg / sumAvailLnd
        ctryEstDF$amtD <- ctryEstDF$availLnd * scaler
        
        ctryEstDF$overflow <- ctryEstDF$amtD - ctryEstDF$availLnd
        sumOverflow <- sum(ctryEstDF[ctryEstDF$overflow > 0, ]$overflow)
        ctryEstDF$amtD <- ifelse(ctryEstDF$overflow < 0, ctryEstDF$amtD, ctryEstDF$availLnd)
        
        while (sumOverflow > 0) {
          sumAvailLnd <- sum(ctryEstDF[ctryEstDF$overflow < 0, ]$availLnd)
          scaler <- sumOverflow / sumAvailLnd
          ctryEstDF$amtD <- ifelse(ctryEstDF$overflow < 0, (ctryEstDF$availLnd * scaler + ctryEstDF$amtD), ctryEstDF$amtD)
          ctryEstDF$overflow <- ctryEstDF$amtD - ctryEstDF$availLnd
          sumOverflow <- sum(ctryEstDF[ctryEstDF$overflow > 0, ]$overflow)
          ctryEstDF$amtD <- ifelse(ctryEstDF$overflow < 0, ctryEstDF$amtD, ctryEstDF$availLnd)
        }
        print(paste(CTRY, ": mode 2.1 (potential = 0, iteratively fill according to availLnd)", sep=""))
        
      } else {
        scaler <- ctryBUChg / sumRT1
        ctryEstDF$amtD <- ctryEstDF$urbFrac00 * scaler
        
        ctryEstDF$overflow <- ctryEstDF$amtD - ctryEstDF$availLnd
        sumOverflow <- sum(ctryEstDF[ctryEstDF$overflow > 0, ]$overflow)
        ctryEstDF$amtD <- ifelse(ctryEstDF$overflow < 0, ctryEstDF$amtD, ctryEstDF$availLnd)
        
        while (sumOverflow > 0) {
          sumRT1 <- sum(ctryEstDF[ctryEstDF$overflow < 0, ]$urbFrac00)
          if (sumRT1 == 0) {
            sumAvailLnd <- sum(ctryEstDF[ctryEstDF$overflow < 0, ]$availLnd)
            scaler <- sumOverflow / sumAvailLnd
            ctryEstDF$amtD <- ifelse(ctryEstDF$overflow < 0, (ctryEstDF$availLnd * scaler + ctryEstDF$amtD), ctryEstDF$amtD)
          } else {
            scaler <- sumOverflow / sumRT1
            ctryEstDF$amtD <- ifelse(ctryEstDF$overflow < 0, (ctryEstDF$urbFrac00 * scaler + ctryEstDF$amtD), ctryEstDF$amtD)
          }
          ctryEstDF$overflow <- ctryEstDF$amtD - ctryEstDF$availLnd
          sumOverflow <- sum(ctryEstDF[ctryEstDF$overflow > 0, ]$overflow)
          ctryEstDF$amtD <- ifelse(ctryEstDF$overflow < 0, ctryEstDF$amtD, ctryEstDF$availLnd)
        }
        print(paste(CTRY, ": mode 2.2 (potential = 0, iteratively fill according to rT1)", sep=""))
      }
      
      rm(scaler, sumOverflow)
      ctryEstDF$newD <- ctryEstDF$amtD / ctryEstDF$GrumpLndAr
      ctryEstDF$newR <- ctryEstDF$urbFrac00 + ctryEstDF$newD
      ctryEstDF$newR <- pmax(ctryEstDF$newR, ctryEstDF$urbFrac00, na.rm = TRUE)
      ctryEstDF$newR <- pmin(ctryEstDF$newR, ctryEstDF$FinalMask, na.rm = TRUE)
      ctryEstDF$newD <- ctryEstDF$newR - ctryEstDF$urbFrac00
      ctryEstDF$newD <- ifelse(ctryEstDF$newD < 0, 0, ctryEstDF$newD) # in case of rounding error
      
      currAlloDF <- as.data.frame(ctryEstDF$originFID)
      currAlloDF$newR <- ctryEstDF$newR
      currAlloDF$newD <- ctryEstDF$newD
      alloDF <- rbind(alloDF, currAlloDF)
      
    } else if (sumAmtD >= ctryBUChg) {
      scaler <- ctryBUChg / sumAmtD
      ctryEstDF$newD <- ctryEstDF$newD * scaler
      rm(scaler)
      currAlloDF <- as.data.frame(ctryEstDF$originFID)
      currAlloDF$newR <- ctryEstDF$urbFrac00 + ctryEstDF$newD
      currAlloDF$newR <- pmin(currAlloDF$newR, ctryEstDF$FinalMask, na.rm = TRUE) # in case of rounding error
      currAlloDF$newD <- ctryEstDF$newD
      alloDF <- rbind(alloDF, currAlloDF)
      print(paste(CTRY, ": mode 3 (potential >= total, proportionally scale down)", sep=""))
      
    } else { # sumAmtD < ctryBUChg
      scaler <- ctryBUChg / sumAmtD
      ctryEstDF$amtD <- ctryEstDF$amtD * scaler
      
      ctryEstDF$overflow <- ctryEstDF$amtD - ctryEstDF$availLnd
      sumOverflow <- sum(ctryEstDF[ctryEstDF$overflow > 0, ]$overflow)
      ctryEstDF$amtD <- ifelse(ctryEstDF$overflow < 0, ctryEstDF$amtD, ctryEstDF$availLnd)
      
      while (sumOverflow > 0) {
        sumAmtD <- sum(ctryEstDF[ctryEstDF$overflow < 0, ]$amtD)
        if (sumAmtD > 0) {
          scaler <- sumOverflow / sumAmtD
          ctryEstDF$amtD <- ifelse(ctryEstDF$overflow < 0, (ctryEstDF$amtD * scaler + ctryEstDF$amtD), ctryEstDF$amtD)
        } else {
          sumRT1 <- sum(ctryEstDF[ctryEstDF$overflow < 0, ]$urbFrac00)
          if (sumRT1 == 0) {
            sumAvailLnd <- sum(ctryEstDF[ctryEstDF$overflow < 0, ]$availLnd)
            scaler <- sumOverflow / sumAvailLnd
            ctryEstDF$amtD <- ifelse(ctryEstDF$overflow < 0, (ctryEstDF$availLnd * scaler + ctryEstDF$amtD), ctryEstDF$amtD)
          } else {
            scaler <- sumOverflow / sumRT1
            ctryEstDF$amtD <- ifelse(ctryEstDF$overflow < 0, (ctryEstDF$urbFrac00 * scaler + ctryEstDF$amtD), ctryEstDF$amtD)
          }
        }
        ctryEstDF$overflow <- ctryEstDF$amtD - ctryEstDF$availLnd
        sumOverflow <- sum(ctryEstDF[ctryEstDF$overflow > 0, ]$overflow)
        ctryEstDF$amtD <- ifelse(ctryEstDF$overflow < 0, ctryEstDF$amtD, ctryEstDF$availLnd)
      }
      
      rm(scaler, sumOverflow)
      ctryEstDF$newD <- ctryEstDF$amtD / ctryEstDF$GrumpLndAr
      ctryEstDF$newR <- ctryEstDF$urbFrac00 + ctryEstDF$newD
      ctryEstDF$newR <- pmax(ctryEstDF$newR, ctryEstDF$urbFrac00, na.rm = TRUE)
      ctryEstDF$newR <- pmin(ctryEstDF$newR, ctryEstDF$FinalMask, na.rm = TRUE)
      ctryEstDF$newD <- ctryEstDF$newR - ctryEstDF$urbFrac00
      ctryEstDF$newD <- ifelse(ctryEstDF$newD < 0, 0, ctryEstDF$newD) # in case of rounding error
      
      currAlloDF <- as.data.frame(ctryEstDF$originFID)
      currAlloDF$newR <- ctryEstDF$newR
      currAlloDF$newD <- ctryEstDF$newD
      alloDF <- rbind(alloDF, currAlloDF)
      print(paste(CTRY, ": mode 4 (potential < total, iteratively fill)", sep=""))
    }
  }
}

