function SetCodePaths(environmentMode)

    if environmentMode == 1             % 1 - Robert's PC

        addpath('H:\_Tools_\DERopt\0CFcode')
        addpath('H:\_Tools_\DERopt\Classes')

    elseif environmentMode == 2         % 2 - Roman's Laptop
            
        addpath('C:\MotusVentures\\DERopt\0CFcode')
        addpath('C:\MotusVentures\\DERopt\Classes')

    else                                % 3 - Roman's Desktop

        addpath('E:\MotusVentures\\DERopt\0CFcode')
        addpath('E:\MotusVentures\\DERopt\Classes')

    end

end

