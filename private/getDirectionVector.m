function v = getDirectionVector(direction)
            switch direction
                case "x"
                    v = [1,0,0];
                case "y"
                    v = [0,1,0];
                case "z"
                    v = [0,0,1];
                otherwise
                    error("Unsupported direction; must be one of x, y or z.")
            end
end