
using Images, ImageFiltering
using Statistics, LinearAlgebra, FFTW

include("DICLab2D_Structs.jl")
include("DICLab2D_CorrelateSubset.jl")
include("DICLab2D_InitialGuess.jl")
include("DICLab2D_ShapeFunctions.jl")
include("DICLab2D_Interpolations.jl")
include("DICLab2D_PointsOfInterest.jl")

include("SIF_PointsOfInterest.jl")
include("SIF_DICProbe.jl")
include("SIF_ComputeSIF.jl")

function RunSIFProgram()
    
    #DIC parameters

        OutputFolderPath = "Data//Output"
        UpdateStrategy = "BSGN"
        Incremental = false
        SubsetShape = "square"
        SubsetSize = 81
        ShapeFunctionOrder = 4
        StopCritValue = 1e-4
        MaxIterations = 10
        GaussSTD = 0.4
        GaussWindow = 5
        MinimumZNCC = 0.95

    #SIF parameters

        Poisson = 0.3
        E = 1.95e5                      #N/mm²
        kCondition = "PlaneStress"
        nWilliamsTerms = 10
        W = 50                          #mm

        #Square AOI (mm)

            AOISize = 4                 #mm
            StepSize = 5                #pixels

        #

        pixel2mm = 0.01172
        mm2pixel = 1/pixel2mm

        PminPath = ""
        PmaxPath = ""
        CrackTipPosition = [0;0]        #[x,y] in pixels in DIC CS
        CrackAngle = 0                  #in degrees in DIC CS

    #

    Input = InputParameters(
        "nothing",
        OutputFolderPath,
        nothing,
        nothing,
        UpdateStrategy,
        Incremental,
        SubsetShape,
        SubsetSize,
        nothing,
        ShapeFunctionOrder,
        StopCritValue,
        MaxIterations,
        GaussSTD,
        GaussWindow,
        nothing,
        nothing,
        nothing,
        nothing,
        MinimumZNCC
    )

    #Points of interest

        X,Y,Radii,Angles,nPOI = DefineSquareAOI(x0,y0,AOISize,mm2pixel,StepSize,CrackAngle)

        #X and Y are in DIC CS
        #Radii are in mm in Crack CS
        #Angles are in rad in Crack CS

    #Displacements

        U,V,MeanZNCC = RingProbe(Input,PminPath,PmaxPath,X,Y,nPOI)

    #Filter out low quality POIs

        Radii = [Radii[i] for i in 1:nPOI if !isnan(U[i])]
        Angles = [Angles[i] for i in 1:nPOI if !isnan(U[i])]
        U = [U[i] for i in 1:nPOI if !isnan(U[i])]
        V = [V[i] for i in 1:nPOI if !isnan(V[i])]

        nValidPOI = length(U)

    #Convert displacements

        U = U*pixel2mm     #convert displacements from pixels to millimeters
        V = V*pixel2mm     #convert displacements from pixels to millimeters

        #convert displacements from DIC CS to Crack CS

        UCrack = cosd(CrackAngle).*U - sind(CrackAngle).*V
        VCrack = -sind(CrackAngle).*U - cosd(CrackAngle).*V

    #SIFs

        dKI,dKII = ComputeSIF(nWilliamsTerms,E,Poisson,kCondition,Radii,Angles,UCrack,VCrack,nValidPOI)

        #dKI and dKII are in N/mm²√mm

        dKI = dKI/31.62     #convert to MPa√m
        dKII = dKII/31.62   #convert to MPa√m

    #

    return dKI,dKII

end