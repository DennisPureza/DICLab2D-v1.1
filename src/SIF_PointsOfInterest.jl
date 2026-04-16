
function DefineSquareAOI(x0,y0,AOISize,mm2pixel,StepSize,CrackAngle)

    AOISize = round(AOISize*mm2pixel,digits=0)

    if iseven(AOISize)
        AOISize = AOISize-1
    end

    d = div(AOISize,2)

    dX = [i for j in 1:StepSize:AOISize, i in -d:StepSize:d][:]
    dY = [i for i in -d:StepSize:d, j in 1:StepSize:AOISize][:]

    xc = x0 + cosd(CrackAngle)*(AOISize/4)
    yc = y0 - sind(CrackAngle)*(AOISize/4)

    X = xc.+dX
    Y = yc.+dY

    Xr = similar(X)
    Yr = similar(Y)

    @. Xr = xc + ((X-xc)*cosd(CrackAngle)+(Y-yc)*sind(CrackAngle))

    @. Yr = yc + (-(Y-yc)*sind(CrackAngle)+(Y-yc)*cosd(CrackAngle))

    Radii,Angles = CartesianToPolar(Xr,Yr,x0,y0,CrackAngle)
    Radii = Radii/mm2pixel

    nPOI = length(X)

    return Xr,Yr,Radii,Angles,nPOI

end

function CartesianToPolar(X,Y,x0,y0,CrackAngle)
       
    XLocal = X.-x0
    YLocal = -(Y.-y0)     

    XAligned = similar(X)
    YAligned = similar(Y)
        
    @. XAligned = XLocal*cosd(CrackAngle) + YLocal*sind(CrackAngle)

    @. YAligned = -XLocal*sind(CrackAngle) + YLocal*cosd(CrackAngle)

    Radii = similar(X)
    Angles = similar(X)

    @. Radii = sqrt(XAligned^2+YAligned^2)
    @. Angles = atan(YAligned,XAligned)

    return Radii,Angles

end