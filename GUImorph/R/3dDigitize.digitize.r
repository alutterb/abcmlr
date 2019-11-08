################# main data structure ##############################
#dgtDataList
#dgtDataList[imgId][[1]]: speciman dir
#dgtDataList[imgId][[2]]: font
#dgtDataList[imgId][[3]]: number of landmark
#dgtDataList[1][[4]]: curves
#dgtDataList[imgId][[5]]: template
#dgtDataList[imgId][[6]]: rotation
#dgtDataList[imgId][[7]]: zoom
#dgtDataList[imgId][[8]]: surface file

#initializes parameters for digital component
init.digitize <- function(e) {
	e$digData <- list()
	e$dragX <- as.integer(-1)
	e$dragY <- as.integer(-1)
	e$dragDot <- FALSE
	e$landmarkNum <- 5
	e$dColor <- c(1, 0, 0)
	set("dot", "labeled", 1)
}

#draw widgets for digitize tab
ui.digitize <- function(e, parent) {
	digCtlFrame <- ttkframe(parent)

	setScaleBtn <- ttkbutton(digCtlFrame, text = "Digitize scale", command = function() setScale(e))
    e$scaleLabel = tklabel(digCtlFrame, text='Scale Factor: not set')
	
	setLandmarkNumBtn <- ttkbutton(digCtlFrame, text = "Set number of landmarks", command = function() setLandmarkNum(e))
	loadLandmarkBtn <- ttkbutton(digCtlFrame, text = "Load landmarks", command = function() loadLandmark(e))
	
	#e$path <- tclVar("Path:")
	#e$imgPath = tkentry(digCtlFrame, textvariable=e$path, state="disabled")
	
    fitBtn <- ttkbutton(digCtlFrame, text = "Fit",command = function() onFit(e))

    e$labelLandmarkVar <-tclVar("1")
    labelLandmark <- ttkcheckbutton(digCtlFrame, text = "Label Landmark",variable=e$labelLandmarkVar, command= function()onLabelLandMark(e))

    lmSizeAdd <- ttkbutton(digCtlFrame, text = "Landmark Size +", command = function() onLmSizeAdd(e))
    lmSizeDec <- ttkbutton(digCtlFrame, text = "Landmark Size -",command = function() onLmSizeDec(e))
	
	lmColorFrame <- ttkframe(digCtlFrame)
	lmColorBtn <- ttkbutton(lmColorFrame, text = "Landmark Color", command = function() onLmColorChange(e))
	e$lmColorLabel <- tklabel(lmColorFrame, text='aa', foreground='#ff0000', background='#ff0000')
	sapply(list(lmColorBtn, e$lmColorLabel), tkpack, side = "left", padx = 3)

	e$specimenNumLabel <- ttklabel(digCtlFrame, text = "Number of Specimens: 0")
	e$landMarkNumLabel <- ttklabel(digCtlFrame, text = "Number of Landmarks: 0")

    e$missLandmarkVar <-tclVar("0")
    e$missLandmarkCheBtn <- ttkcheckbutton(digCtlFrame, text = "Missing Landmark",variable=e$missLandmarkVar)

	tkpack(ttklabel(digCtlFrame, text = " "), pady = 6)
    sapply(list(setLandmarkNumBtn, loadLandmarkBtn, fitBtn, lmSizeAdd, lmSizeDec, lmColorFrame, labelLandmark, e$specimenNumLabel, e$landMarkNumLabel), tkpack, pady=3)
	return (digCtlFrame)
}

#configures buttons for digitize component
bind.digitize <-function(e) {   
    tkbind(e$canvasFrame, "<MouseWheel>", function(D) {zoom(e, D)})
	
	tkbind(e$canvasFrame, "<ButtonPress-1>", function(x, y) {
		onLeftBtnPress(e, x, y)
	})
	
	tkbind(e$canvasFrame, "<ButtonRelease-1>", function(x, y) {
		onLeftBtnRelease(e, x, y)
	})
	
	tkbind(e$canvasFrame, "<ButtonPress-3>", function(x, y) {
		deleteDot(e, x, y)
	})
	
	tkbind(e$canvasFrame, "<Motion>", function(x, y) {motion(e, x, y)}) #motion - events are generated when pointer is moved
	tkbind(e$canvasFrame, "<Double-Button-1>", function(x, y) {
		addDot(e, x, y) #Here is where double clicking calls the addDot function on canvas to place a landmark
	})
}

#changes color of landmark
onLmColorChange <- function(e) {
	color <- tcl('tk_chooseColor')
	tkconfigure(e$lmColorLabel, text ='aa', foreground=tclvalue(color), background=tclvalue(color))
	color <- as.integer(gsub("#", "0x", tclvalue(color)))

	r <- as.integer(color / 0x10000)
	g <- as.integer((color %% 0x10000) / 0x100)
	b <- as.integer(color %% 0x100)
	e$dColor <- c(r/255, g/255, b/255)
	set("dot", "dcolor", r/255, g/255, b/255)
}

#Sets action for dot color selection
onLeftBtnPress <- function(e, x, y) {
	if(length(e$activeDataList) > 0) {
		if (set("dot", "selected", x, y)) {
			e$dragDot <- TRUE	
			set("dot", "color", as.double(1/255), as.double(164/255), as.double(191/255))		
		}
		else {
			e$dragDot <- FALSE
		}
		e$dragX <- as.integer(x)
		e$dragY <- as.integer(y)
	}
}

#assigns chosen color value to selected dot
onLeftBtnRelease <- function(e, x, y) {
	if(length(e$activeDataList) > 0) {
		e$dragX <- as.integer(-1)
		e$dragY <- as.integer(-1)
		
		if(e$dragDot) {
			e$dragDot <- FALSE
			color <- e$dColor
			set("dot", "color", color[1], color[2], color[3])	
		}	
	}	
}

#Increase landmark size
onLmSizeAdd <- function(e) {
	if(length(e$activeDataList) == 0) { return() }
	font <- e$activeDataList[[e$currImgId]][[2]]
	set("dot", "radius", font + 0.001)
	e$activeDataList[[e$currImgId]][[2]] <- font + 0.001
}

#Decrease landmark size
onLmSizeDec <- function(e) {
	if(length(e$activeDataList) == 0) { return() }
	font <- e$activeDataList[[e$currImgId]][[2]]
	set("dot", "radius", font - 0.001)
	shows("all")
	e$activeDataList[[e$currImgId]][[2]] <- font - 0.001
}

#draw label for landmark
onLabelLandMark <- function(e) {
#print("onLabelLandMark")
	if(length(e$activeDataList) == 0) { return() }
    if (tclvalue(e$labelLandmarkVar) == "1") {
		set("dot", "labeled", 1)
    } else {
		set("dot", "labeled", 0)	
	}	
}

#Grabs user input and turns to first picture
onlandmarkNumOk <- function(e, win) {
	#get user input value
    e$landmarkNum <- tclvalue(tkget(e$landmarkEntry))
	
	tkdestroy(win)
	
	# turn to the first picture
	if(length(e$activeDataList) > 0) { 
		e$currImgId <- 1
		showPicture(e)
	}
}

#Pop up window for setting number of landmarks
setLandmarkNum <- function(e) {
	win <- tktoplevel()
	tkwm.title(win, "Set Landmark Number")

	entryFrame <- ttkframe(win)
	tkpack(entryFrame, expand = TRUE, fill = "both", padx = 5, pady = 5)
	label = tklabel(entryFrame, text='Set landmark Number: ')

    e$landmarkEntry = tkentry(entryFrame, textvariable=tclVar(e$landmarkNum))
	sapply(list(label, e$landmarkEntry), tkpack, side = "left", padx = 6)

	btnFrame <- ttkframe(win)
	tkpack(btnFrame, fill = "x", padx = 5, pady = 5)
	cancelBtn <- ttkbutton(btnFrame, text = "cancel", command = function() tkdestroy(win))
	okBtn <- ttkbutton(btnFrame, text = "ok",command = function() onlandmarkNumOk(e, win))

	tkpack(ttklabel(btnFrame, text = " "), expand = TRUE, fill = "y", side = "left")
	sapply(list(cancelBtn, okBtn), tkpack, side = "left", padx = 6)

	tkfocus(win)
}

#loads landmark file
loadLandmark <- function(e) {
    fileStr <- tclvalue(tkgetOpenFile(filetypes = "{{landmark file} {.pts}} {{csv file} {.csv}}", 
                                      multiple=FALSE, title="Select landmark file"))
    add("landmark", e$currImgId - 1, e$landmarkNum, fileStr)
    e$activeDataList[[e$currImgId]][[3]] <- e$landmarkNum
    tkconfigure(e$landMarkNumLabel, text = paste("Number of Landmarks: ", e$landmarkNum))
}

#pop up window to remove selected landmark
deleteDot <- function(e, x, y) {
	#print("delete Dot")
		# turn to the first picture
	if(length(e$activeDataList) == 0) { return() }
	if (set("dot", "selected", x, y)) { 
		set("dot", "color", as.double(1/255), as.double(164/255), as.double(191/255))
		popUpRemoveWindow(e, x, y, 'Do you want to delete this landmark?', "digdot")
	}	
}

#starts to delete landmark
digRemoveDotOk <-function(e, x, y) {
	msg <- del("dot")
	tkdestroy(e$removeWin)
	updateDotNum(e, -1)
}

#cancel to delete landmark
digRemoveDotCancel <-function(e, x, y) {
	#print("digRemoveDotCancel")
	set("dot", "color", 1, 0, 0)
	tkdestroy(e$removeWin)
}

#adds one landmark
addDot <- function(e, x, y) {
	#print(paste("addDot:", x, y))
	if(length(e$activeDataList) > 0) {
		dotNum <- e$activeDataList[[e$currImgId]][[3]]
		if(dotNum < as.integer(e$landmarkNum)) {
			#if (set("dot", "selected", x, y)) { return ()}
			coord <- convertCoor(e, x, y)			
			if(add("dot", coord[1], coord[2], coord[3])) {
				#print(coord)
				updateDotNum(e, 1)
			} else {
				print("not inside the specimen")
			}
		}	
	}else {
		print("no specimen opened")
	}
}

#updates real number of landmarks in database after deletion or insertion of landmark
updateDotNum <- function(e, delt) {
    nDots <- e$activeDataList[[e$currImgId]][[3]]
	nDots <- nDots + delt

	tkconfigure(e$landMarkNumLabel, text = paste("Number of Landmarks: ", nDots))
	
	e$activeDataList[[e$currImgId]][[3]] <- nDots
}

#updates real values for widgets
updateWidgets.digitize <- function(e) {
	#print("updateWidgets.digitize ")	
	dotNum <- e$activeDataList[[e$currImgId]][[3]]
	tkconfigure(e$landMarkNumLabel, text = paste("Number of Landmarks: ", dotNum))
	tkconfigure(e$imgPath, text = paste("Specimen Id: ", e$activeDataList[[e$currImgId]][[1]]))
}

#reads .dgt files
read.digitize <- function(content) {
    ignore.case = TRUE
    lmdata <- grep("LM3=", content, ignore.case)
    nlands <- as.numeric(sub("LM3=", "", content[lmdata], ignore.case))
    k <- 3

    if (max(nlands) - min(nlands) != 0) {
      stop("Number of landmarks not the same for all specimens.")
    }
    
    nSpecimen <- length(lmdata)
    nland <- nlands[1]
    startLines <- lmdata + 1
    endLines <- as.numeric(lmdata) + as.numeric(nlands)
    coords <- array(0, c(nland, 3, nSpecimen))
    for(i in 1:nSpecimen) {
        tmp <- content[startLines[i]:endLines[i]]
        coords[, , i] <- matrix(as.numeric(unlist(strsplit(tmp, " "))), ncol=3, byrow=TRUE)
    }

    ID <- sub("ID=", "", content[grep("ID=", content, ignore.case)], ignore.case)
	print(ID)
    if (length(ID) != 0) {
      dimnames(coords)[[3]] <- as.list(ID)
    }
	
	return(coords)
}

#writes data to .dgt file
write.digitize <- function(fileName, Id, landmarks) {
	lmline <- paste("LM3=", nrow(landmarks), sep="")
	write(lmline,fileName,append = TRUE)
	write.table(landmarks, fileName, col.names = FALSE, row.names = FALSE, append=TRUE)
	idline<-paste("ID=", Id, sep="")
    write(idline,fileName,append = TRUE) 
}

#displays specimen and landmark in canvas
draw.digitize <- function(id, specimen, landmarks) {
	print(paste("Add specimen", id))
	add("specimen", specimen, id-1) #load model in
	set("specimen", "id", id-1)
	
	print(paste("Add landmark for  specimen", id, "... ..."))
	for(j in 1:nrow(landmarks)) {
		res <- add("rawdot", landmarks[j,1], landmarks[j,2], landmarks[j,3])
		if(!res) {
			print(paste("add dot fail", landmarks[j,1], landmarks[j,2], landmarks[j,3]))
		}                    
	}
}

