###############################################################################
#
# Reduce step method to find peak
#
###############################################################################
function find_peak(
            f::F,
            ms::ReduceStepMethod{FT},
            tol::ResidualTolerance{FT}
) where {F<:Function, FT<:AbstractFloat}
    # count iterations
    count = 0

    # define the initial step
    @unpack x_inis, x_maxs, x_mins, Δ_inis = ms;
    x_ini = x_inis[1];
    x_max = x_maxs[1];
    x_min = x_mins[1];
    Δ_ini = Δ_inis[1];

    # initialize the y
    tar_x = x_ini;
    tar_y = f(tar_x);
    new_x = x_min;
    new_y = f(new_x);
    new_y >= tar_y ? (tar_x=new_x; tar_y=new_y;) : nothing;
    new_x = x_max;
    new_y = f(new_x);
    new_y >  tar_y ? (tar_x=new_x; tar_y=new_y;) : nothing;

    # find the solution
    Δx::FT = Δ_ini;
    while true
        # 1. increase the x by Δx till tar_y is bigger
        count_inc = 0
        while true
            new_x = tar_x + Δx;
            new_x > x_max ? break : nothing;
            new_y = f(new_x);
            new_y >  tar_y ? (tar_x=new_x; tar_y=new_y;) : break;
            count_inc += 1;
        end

        # 2. decrease the x by Δx till tar_y is bigger
        count_dec = 0
        while count_inc == 0
            new_x = tar_x - Δx;
            new_x < x_min ? break : nothing;
            new_y = f(new_x);
            new_y >= tar_y ? (tar_x=new_x; tar_y=new_y;) : break;
            count_dec += 1;
        end

        # 3. if break
        Δx <= tol.tol[1] ? break : nothing;

        # 4. if no update, then 10% the Δx
        if count_inc + count_dec == 0
            Δx /= 10;
        end
    end

    return tar_x
end




function find_peak(
            f::F,
            ms::ReduceStepMethod{FT},
            tol::StepTolerance{FT}
) where {F<:Function, FT<:AbstractFloat}
    # define the initial step
    @unpack x_inis, x_maxs, x_mins, Δ_inis = ms;
    x_ini = x_inis[1];
    x_max = x_maxs[1];
    x_min = x_mins[1];
    Δ_ini = Δ_inis[1];

    # initialize the y
    tar_x = x_ini;
    tar_y = f(tar_x);
    new_x = x_min;
    new_y = f(new_x);
    new_y >= tar_y ? (tar_x=new_x; tar_y=new_y;) : nothing;
    new_x = x_max;
    new_y = f(new_x);
    new_y >  tar_y ? (tar_x=new_x; tar_y=new_y;) : nothing;

    # find the solution
    Δx::FT = Δ_ini;
    while Δx > tol.tol[1]
        # 1. increase the x by Δx till tar_y is bigger
        count_inc = 0
        while true
            new_x = tar_x + Δx;
            new_x > x_max ? break : nothing;
            new_y = f(new_x);
            new_y >  tar_y ? (tar_x=new_x; tar_y=new_y;) : break;
            count_inc += 1;
        end

        # 2. decrease the x by Δx till tar_y is bigger
        count_dec = 0
        while count_inc == 0
            new_x = tar_x - Δx;
            new_x < x_min ? break : nothing;
            new_y = f(new_x);
            new_y >= tar_y ? (tar_x=new_x; tar_y=new_y;) : break;
            count_dec += 1;
        end

        # 3. if no update, then 10% the Δx
        if count_inc + count_dec == 0
            Δx /= 10;
        end
    end

    return tar_x
end