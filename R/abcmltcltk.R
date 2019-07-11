abcml_tclk <- function(){
  require(tcltk2, quietly = TRUE)
  mydir <- getwd()
  
  e <- new.env()
  e$datFile <- tclVar()
  e$cmdLine <- tclVar()
  
  Okfun <- function(){
    cmdLine <-tclvalue(e$cmdLine)
    assign("cmdLine", cmdLine, envir = e)
    datFile <- tclvalue(e$datFile)
    assign("datFile", datFile, envir = e)
    
    call <- paste("cd", normalizePath(mydir), "&& (echo ", paste0(mydir,'/',datFile), " ) | Translator" )
    shell(call)
    
    #system2("wsl", "abcml toy.bdf home.cfg kill.cfg toy.cnt -a")
    system2("wsl", paste(paste("abcml bondef.bdf spc.cnt", collapse = " "), cmdLine))
  }
  
  #Begin GUI Setup
  window <- tktoplevel()
  tkwm.title(window, "ABCML")
  frame <- ttkframe(window, padding = c(3,3,12,12))
  tkpack(frame, expand = TRUE, fill = "both")
  
  #Layout
  label_frame <- ttklabelframe(frame, text = "Calibration", padding = 12)
  tkpack(label_frame, expand = TRUE, fill = "both", padx = 12, pady = 3)
  tkgrid.columnconfigure(label_frame, 0, weight = 1)
  tkgrid.columnconfigure(label_frame, 1, weight = 1)
  tkgrid.rowconfigure(label_frame, 0, weight = 1)
  tkgrid.rowconfigure(label_frame, 1, weight = 1)
  
  put_label <- function(parent, text, row, column) {
    label <- ttklabel(parent, text = text)
    tkgrid(label, row = row, column = column, sticky = "w")
  }
  
  #datFile Box
  put_label(label_frame, "Name of your Data (i.e. dat.csv): ",0,0)
  entry.datFile <- tkentry(label_frame, width = "50", textvariable = e$datFile)
  tkgrid(entry.datFile, row = 0, column = 1, sticky = "w", padx = 10)
  tkfocus(entry.datFile)
  
  #CMD line Box
  put_label(label_frame, "Input Command: ",1,0)
  entry.cmdLine <- tkentry(label_frame, width = "50", textvariable = e$cmdLine)
  tkgrid(entry.cmdLine, row = 1, column = 1, sticky = "w", padx = 10)
  tkfocus(entry.cmdLine)
  
  
  #Draw Cancel Button
  button_frame <- ttkframe(frame)
  cancel_button <- ttkbutton(button_frame, text = "Cancel")
  
  #Draw Ok Button
  ok_button <- ttkbutton(button_frame, text = "Begin ABCML",command = Okfun)
  tkpack(button_frame, fill = "x", padx = 5, pady = 5)
  tkpack(ttklabel(button_frame, text = " "), expand = TRUE,
         fill = "y", side = "left")               # add a spring
  sapply(list(cancel_button, ok_button), tkpack, 
         side = "left", padx = 6)
  
  #configure buttons
  tkconfigure(ok_button, command = Okfun)
  tkconfigure(cancel_button, 
              command = function() tkdestroy(window))
  tkbind("TButton", "<Return>", function(W) tcl(W, "invoke"))
}