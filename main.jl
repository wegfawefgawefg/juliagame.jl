using SimpleDirectMediaLayer.LibSDL2

include("ezsdl.jl")
ez = EZ

WINDOW_DIMS = (800, 600)

mutable struct Bunny
    pos::Vector{Float64}
    vel::Vector{Float64}
end
function random_bunny()
    return Bunny(
        [rand() * WINDOW_DIMS[1], rand() * WINDOW_DIMS[2]],
        [rand() * 2 - 1, rand() * 2 - 1]
    )
end
function step_bunny(bunny)
    bunny.pos = bunny.pos + bunny.vel
    # bunny.pos = bunny.pos .% WINDOW_DIMS
    if bunny.pos[1] < 0 || bunny.pos[1] > WINDOW_DIMS[1]
        bunny.vel[1] = -bunny.vel[1]
    end
    if bunny.pos[2] < 0 || bunny.pos[2] > WINDOW_DIMS[2]
        bunny.vel[2] = -bunny.vel[2]
    end
end
function gravity_bunny(bunny)
    bunny.vel = bunny.vel + [0, 0.1]
end

function main()
    try
        ez.init()
        ez.font_init()
        font = ez.load_font("assets/FreeSans.ttf", 24)

        win = ez.create_window("Game", WINDOW_DIMS)
        renderer = ez.create_renderer(win)

        path = joinpath(@__DIR__, "assets", "wabbit_alpha.png")
        im = ez.load_image(path)
        print(im)

        num_bunnies = 10000
        bunnies = [random_bunny() for i=0:num_bunnies]

        slow_fps = 1000

        running = true
        while running
            while ez.some_events()
                event = ez.get_event()
                if event.type == SDL_QUIT
                    running = false
                    break
                end
            end
            ez.update_keys()
            if ez.is_pressed(SDL_SCANCODE_Q)
                running = false
                break
            end
            dtime = ez.dtime()
            fps = convert(UInt, floor(1000 / (dtime+1)))

            if ez.num_frames() % 10 == 0
                slow_fps = fps
            end
            
            ez.clear()
            mx, my = ez.get_mouse_pos()
            for bunny in bunnies
                step_bunny(bunny)
                gravity_bunny(bunny)
                x, y = bunny.pos
                ez.draw_image(im, x, y, im.width, im.height)
            end
            
            white = ez.Color(255, 255, 255, 0)
            x, y = ez.get_mouse_pos()
            ez.draw_text(font, string(slow_fps), 0, 0, white)
            ez.flip()
        end
    finally
        ez.cleanup()
    end
end
main()