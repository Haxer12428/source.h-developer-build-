FW.array = {

    ["=>"] = {

        pack = function (...) 
            local arrays, array = {...}, {}; 
            
            for _, list in pairs (arrays) do 
                for __, element in pairs(list) do 

                    array[#array+1] = element;

                end; end 

            return array; 
        end; 

    }

}