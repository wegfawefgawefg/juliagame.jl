using SimpleDirectMediaLayer.LibSDL2

include("images.jl")

SDL_GL_SetAttribute(SDL_GL_MULTISAMPLEBUFFERS, 16)
SDL_GL_SetAttribute(SDL_GL_MULTISAMPLESAMPLES, 16)

@assert SDL_Init(SDL_INIT_EVERYTHING) == 0 "error initializing SDL: $(unsafe_string(SDL_GetError()))"

WINDOW_DIMS = (800, 600)
win = SDL_CreateWindow("Game", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, WINDOW_DIMS[1], WINDOW_DIMS[2], SDL_WINDOW_SHOWN)
println(typeof(win))
SDL_SetWindowResizable(win, SDL_TRUE)

print(typeof(win))

renderer = SDL_CreateRenderer(win, -1, SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC | SDL_RENDERER_TARGETTEXTURE)

path = joinpath(@__DIR__, "assets", "cat.png")
im = Images.load_image(path, renderer)
print(im)

function get_mouse_pos()
    x, y = Ref{Cint}(0), Ref{Cint}(0)
    SDL_GetMouseState(x, y)
    return (x[], y[])
end

function get_keys()
    return SDL_GetKeyboardState(C_NULL)
end

function is_pressed(keys, key)
    return unsafe_load(keys, key+1) == 1
end

function main()
    try
        SDL_SetRenderDrawColor(renderer, 0, 0, 0, SDL_ALPHA_OPAQUE);
        SDL_RenderClear(renderer)

        pos = [WINDOW_DIMS[1] ÷ 2, WINDOW_DIMS[2] ÷ 2]
        vel = [0, 0]
        speed = 2.0

        dest_ref = Ref(SDL_Rect(pos[1], pos[2], im.width, im.height))

        close = false
        while !close
            event_ref = Ref{SDL_Event}()
            while Bool(SDL_PollEvent(event_ref))
                evt = event_ref[]
                evt_ty = evt.type
                if evt_ty == SDL_QUIT
                    close = true
                    break

                elseif evt_ty == SDL_KEYDOWN
                    scan_code = evt.key.keysym.scancode
                    if scan_code == SDL_SCANCODE_Q
                        close = true
                        break
                    end
                end
            end

            keys = get_keys()
            if is_pressed(keys, SDL_SCANCODE_W) || is_pressed(keys, SDL_SCANCODE_UP)
                pos[2] += -speed
            end
            if is_pressed(keys, SDL_SCANCODE_S) || is_pressed(keys, SDL_SCANCODE_DOWN)
                pos[2] += speed
            end
            if is_pressed(keys, SDL_SCANCODE_A) || is_pressed(keys, SDL_SCANCODE_LEFT)
                pos[1] += -speed
            end
            if is_pressed(keys, SDL_SCANCODE_D) || is_pressed(keys, SDL_SCANCODE_RIGHT)
                pos[1] += speed
            end

            mx, my = get_mouse_pos()
            SDL_SetRenderDrawColor(renderer, 255, 255, 255, SDL_ALPHA_OPAQUE);
            SDL_RenderDrawPoint(renderer, mx, my)

            dest_ref[] = SDL_Rect(pos[1], pos[2], im.width, im.height)
            SDL_RenderCopy(renderer, im.texture, C_NULL, dest_ref)
            # Images.draw(renderer, img, pos, shape)
            SDL_RenderPresent(renderer)
            # SDL_Delay(1000 ÷ 60)
        end
    finally
        SDL_DestroyTexture(im.texture)
        SDL_DestroyRenderer(renderer)
        SDL_DestroyWindow(win)
        SDL_Quit()
    end
end

main()