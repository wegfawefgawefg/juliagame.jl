using SimpleDirectMediaLayer.LibSDL2

include("ezsdl.jl")
import .EZSDL
import .EZSDL.Root
# import .EZSDL.Images

WINDOW_DIMS = (800, 600)

ez = EZSDL.init()
win = create_window(ez, "Game", WINDOW_DIMS)
renderer = create_renderer(ez, win)

path = joinpath(@__DIR__, "assets", "cat.png")
im = load_image(ez, path, renderer)
print(im)

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