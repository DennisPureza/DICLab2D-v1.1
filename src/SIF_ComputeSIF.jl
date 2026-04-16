
function ComputeSIF(nWilliamsTerms,E,Poisson,kCondition,Radii,Angles,U,V,nPOI)

    if kCondition == "PlaneStress"      #Kolosov constant

        k = (3-Poisson)/(1+Poisson) 

    elseif kCondition == "PlaneStrain"

        k = 3-4*Poisson    
                    
    end

    G = E/(2*(1+Poisson))       #shear modulus

    f0 = (k+1)/(2*G)            #n=0 term coefficients
    g0 = (k+1)/(2*G)

    C = Matrix{Float64}(undef,2*nPOI,2*nWilliamsTerms+2)  #initialize the coefficients matrix

    for i in 1:nPOI

        R = Radii[i]                #polar coordinates of the current POI
        Theta = Angles[i]

        for n in 1:nWilliamsTerms

            fI =  ((R^(n/2))/(2*G))*((( k+(n/2)+(-1)^n)*(cos((n/2)*Theta)))-((n/2)*(cos(((n/2)-2)*Theta))))
            fII = ((R^(n/2))/(2*G))*(((-k-(n/2)+(-1)^n)*(sin((n/2)*Theta)))+((n/2)*(sin(((n/2)-2)*Theta))))
            gI =  ((R^(n/2))/(2*G))*((( k-(n/2)-(-1)^n)*(sin((n/2)*Theta)))+((n/2)*(sin(((n/2)-2)*Theta))))
            gII = ((R^(n/2))/(2*G))*((( k-(n/2)+(-1)^n)*(cos((n/2)*Theta)))+((n/2)*(cos(((n/2)-2)*Theta))))

            C[i,n] = fI
            C[i+nPOI,n] = gI

            if n == 1

                C[i,nWilliamsTerms+n] = fII
                C[i+nPOI,nWilliamsTerms+n] = gII

            elseif n == 2

                C[i,2*nWilliamsTerms+2] = fII
                C[i+nPOI,2*nWilliamsTerms+2] = gII

            else

                C[i,nWilliamsTerms+(n-1)] = fII
                C[i+nPOI,nWilliamsTerms+(n-1)] = gII

            end
            
        end

        C[i,2*nWilliamsTerms] = f0
        C[i,2*nWilliamsTerms+1] = 0.0

        C[i+nPOI,2*nWilliamsTerms] = 0.0
        C[i+nPOI,2*nWilliamsTerms+1] = g0

    end

    h = vcat(U,V)       #displacement vector

    AB = C\h            #direct solution for Williams coefficients

    A1 = AB[1]
    B1 = AB[nWilliamsTerms+1]
    
    dKI = sqrt(2*pi)*A1
    dKII = -sqrt(2*pi)*B1

    return dKI,dKII

end