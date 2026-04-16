
using CSV,DataFrames,Images,GLMakie

function GetDataFromCSV(CSVFilePath::String)
    
    Data = CSV.read(CSVFilePath,DataFrame,delim=';') #read the CSV file

    nImages = size(Data,1) #get the number of images
    nPOI = Int((size(Data,2)-1)/11) #get the number of points of interest (POI)

    X = [Data[i,j] for i in 1:nImages, j in 2:11:11*nPOI+1]
    Y = [Data[i,j] for i in 1:nImages, j in 3:11:11*nPOI+1]
    U = [Data[i,j] for i in 1:nImages, j in 4:11:11*nPOI+1]
    V = [Data[i,j] for i in 1:nImages, j in 5:11:11*nPOI+1]
    ZNCC =  [Data[i,j] for i in 1:nImages, j in 6:11:11*nPOI+1]
    nIter = [Data[i,j] for i in 1:nImages, j in 7:11:11*nPOI+1]
    Exx = [Data[i,j] for i in 1:nImages, j in 8:11:11*nPOI+1]
    Eyy = [Data[i,j] for i in 1:nImages, j in 9:11:11*nPOI+1]
    Exy = [Data[i,j] for i in 1:nImages, j in 10:11:11*nPOI+1]
    E1 =  [Data[i,j] for i in 1:nImages, j in 11:11:11*nPOI+1]
    E2 =  [Data[i,j] for i in 1:nImages, j in 12:11:11*nPOI+1]

    return X,Y,U,V,ZNCC,nIter,Exx,Eyy,Exy,E1,E2,nImages,nPOI

end

X,Y,U,V,ZNCC,nIter,Exx,Eyy,Exy,E1,E2,nImages,nPOI = GetDataFromCSV("Data//Output//DICLab2D_AreaModule_24Feb26_18h28.CSV")





function PlotPOIs(x0,y0,XPOI,YPOI,Name,PlotCoords::Bool=false)
    
    Fig = Figure()

    Ax = GLMakie.Axis(Fig[1,1],aspect=DataAspect(),yreversed=true)

    scatter!(Ax,x0,y0,color=:green,markersize=10,marker=:cross)
    scatter!(Ax,XPOI,YPOI,color=:blue,markersize=2)

    if PlotCoords == true

        for i in eachindex(XPOI)
            text!(Ax,XPOI[i],YPOI[i],text=string("x=",round(XPOI[i],digits=2),", y=",round(YPOI[i],digits=2)),color=:black,fontsize=5)
            text!(Ax,XPOI[i],YPOI[i]-3,text=string("POI=",i),color=:black,fontsize=5)
        end
        
    end

    save("Data/Output/DICLab2D_RingPOIs_$Name.png",Fig)

end

function PlotArrowField(X,Y,U,V,ImgFilePath)
    
    i = 2

    Fig = Figure()
    Ax = GLMakie.Axis(Fig[1,1],aspect=DataAspect())

    Strength = [U[i]^2 + V[i]^2 for i in 1:nPOI]

    image!(Ax,(load(ImgFilePath))')
    arrows2d!(Ax,X,Y,U,V,lengthscale = 2,color=Strength,colormap=:balance,tailwidth=1,tipwidth=3)
    hidedecorations!(Ax)

    return Fig

end



# PlotArrowField(X,Y,U,V,"ArrowField_CP01_UnB_13k","Data//CT_UnB//CP01//1_EnsaioCT01_MAX13K.tiff",Strength)



function PlotScatterField(X0,Y0,QOI,Name::String,ImgFilePath::String)

    i=2

    Fig = Figure()
    Ax = GLMakie.Axis(Fig[1,1],aspect=DataAspect(),yreversed=true)

    image!(Ax,(load(ImgFilePath))')
    sc = scatter!(Ax,X0[i,:],Y0[i,:],color=QOI[i,:],colormap=:balance,marker=:rect,markersize=5)
    GLMakie.Colorbar(Fig[1,2],sc)
    hidedecorations!(Ax)

    save("Data/Output/DICLab2D_ScatterField_$Name.png",Fig,px_per_unit=5)

end

# PlotScatterField(X,Y,V,"V_CP01_UnB_13k","Data//CT_UnB//CP01//1_EnsaioCT01_MAX13K.tiff")







function PlotSurfaceField(
    
    X0,Y0,QOI,ImgFilePath,Name::String
    )

    nRows,nCols = size(load(ImgFilePath))

    Fig = Figure(size=(nCols,nRows))

    Ax = GLMakie.Axis3(Fig[1,1])

    surface!(Ax,X0,Y0,QOI,shading=true,colormap=:balance)

    save("Data/Output/DICLab2D_SurfaceField_$Name.png",Fig)

end

function PlotSurfaceFieldandPoints(
    
    X0,Y0,QOI,XPoints,YPoints,QOIPoints,ImgFilePath,Name::String
    )

    nRows,nCols = size(load(ImgFilePath))

    Fig = GLMakie.Figure(size=(nCols,nRows))

    Ax = GLMakie.Axis3(Fig[1,1])

    surface!(Ax,X0,Y0,QOI,shading=true,colormap=:balance)
    scatter!(Ax,XPoints,YPoints,QOIPoints)

    # save("Data/Output/DICLab2D_SurfaceField_$Name.png",Fig)

    display(GLMakie.Screen(),Fig)

end



# PlotArrowField(
#     "Data//Output//DICLab2D_AreaModule_02Jul25_09h49.CSV",
#     "Data//S460CT - CP02//CP02-0060_0.tif",
#     2
# )

function PlotRingsArrows()
    
    Xr,Yr,Ur,Vr = RingDisplacementsInterpolation(10,3,20,50,(pi/4),1080.0,1200.0,"Data//Output//DICLab2D_AreaModule_02Jul25_09h49.CSV")

    Fig = Figure()

    Ax = CairoMakie.Axis(Fig[1,1],aspect=DataAspect(),yreversed=true)

    # image!(Ax,(load(ImgFilePath))')

    arrows2d!(Ax,Xr,Yr,Ur,Vr)

    return Fig

end




