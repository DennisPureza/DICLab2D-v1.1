
function RingProbe(Input,FPath,GPath,X,Y,nPOI)

    UpdateStrategy = Input.UpdateStrategy
    ShapeFunctionOrder = Input.ShapeFunctionOrder
    SubsetShape = Input.SubsetShape
    SubsetSize = Input.SubsetSize
    GaussSTD = Input.GaussSTD
    GaussWindow = Input.GaussWindow
    MinimumZNCC = Input.MinZNCC

    #local relative coordinates for pixels in the subset

    d = div(SubsetSize,2)

    dX = [i for j in 1:SubsetSize, i in -d:d]
    dY = [i for i in -d:d, j in 1:SubsetSize]

    #run dX and dY by the SubsetMaker function to be shaped

    dX = ShapeSubset(dX,SubsetSize,SubsetShape,d+1,d+1,d)
    dY = ShapeSubset(dY,SubsetSize,SubsetShape,d+1,d+1,d)

    F = load(FPath)                                                               #load reference image
    F = Gray.(F)                                                                        #convert reference image to grayscale
    F = convert(Array{Float64},F)                                                       #convert reference image to a float array
    F = imfilter(F,Kernel.gaussian((GaussSTD,GaussSTD),(GaussWindow,GaussWindow)))      #apply gaussian filter on F

    #compute the partial derivatives of F using convolution

    DiffKernel = [1/12 -8/12 0 8/12 -1/12]          #convolution mask for partial derivatives

    dFdx = imfilter(F,DiffKernel,"replicate")       #convolve along rows
    dFdy = imfilter(F,DiffKernel',"replicate")      #convolve along columns

    G = load(GPath)                                                             #load deformed image G
    G = Gray.(G)                                                                        #convert deformed image to grayscale
    G = convert(Array{Float64},G)                                                       #convert deformed image to a float array
    G = imfilter(G,Kernel.gaussian((GaussSTD,GaussSTD),(GaussWindow,GaussWindow)))      #apply gaussian filter on G

    #define warp and parameter update functions
    
    WarpUpdateFunctions = DefineWarpUpdateFunctions(ShapeFunctionOrder,UpdateStrategy)

    InterpolationTable = ComputeCoefficientsTable(G)               #compute the interpolation coefficients table for G

    U = Vector{Float64}(undef,nPOI)     #initialize U array
    V = Vector{Float64}(undef,nPOI)     #initialize V array
    ValidPOIZNCC = []

    for POI in 1:nPOI

        x = X[POI]
        y = Y[POI]

        xround = round(Int,x)
        yround = round(Int,y)

        InitialGuess = PCMGuess(F,G,xround,yround,SubsetSize,d)     #compute initial guess

        f = ShapeSubset(F,SubsetSize,SubsetShape,xround,yround,d)           #gray-level values in current subset
        dfdx = ShapeSubset(dFdx,SubsetSize,SubsetShape,xround,yround,d)     #gradients in current subset in the x direction
        dfdy = ShapeSubset(dFdy,SubsetSize,SubsetShape,xround,yround,d)     #gradients in current subset in the y direction

        #correlate POI

        P,ZNCC,nIter,BadPOI = CorrelateSubset(f,x,y,dX,dY,dfdx,dfdy,InterpolationTable,InitialGuess,WarpUpdateFunctions,Input)

        if ZNCC >= MinimumZNCC

            U[POI] = P.u  
            V[POI] = P.v
            push!(ValidPOIZNCC,ZNCC)

        else

            U[POI] = NaN
            V[POI] = NaN

        end

    end

    MeanZNCC = mean(ValidPOIZNCC)
        
    return U,V,MeanZNCC

end