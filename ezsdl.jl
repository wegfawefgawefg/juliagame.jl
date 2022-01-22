module EZ
    using SimpleDirectMediaLayer.LibSDL2

    struct Image
        texture::Ptr{SDL_Texture}
        width::Int
        height::Int
    end
    Base.show(io::IO, z::Image) = print("Image: $(z.width):$(z.height)")

    mutable struct EZSingleton
        images::Vector{Image}
        textures::Vector{SDL_Texture}
        window::Ptr{SDL_Window}
        renderer::Ptr{SDL_Renderer}
        running::Bool
        keys::Ptr{UInt8}
    end

    ezs = EZSingleton(
        Image[],
        SDL_Texture[],
        Ptr{SDL_Window}(),
        Ptr{SDL_Renderer}(),
        true,
        # convert(Ptr{UInt8}, 1)
        SDL_GetKeyboardState(C_NULL)
    )
        
    function init()
        SDL_GL_SetAttribute(SDL_GL_MULTISAMPLEBUFFERS, 16)
        SDL_GL_SetAttribute(SDL_GL_MULTISAMPLESAMPLES, 16)
        @assert SDL_Init(SDL_INIT_EVERYTHING) == 0 "error initializing SDL: $(unsafe_string(SDL_GetError()))"
    end
    function font_init()
        TTF_Init()
    end
    function load_font(path, size)
        return TTF_OpenFont(path, size)
    end

    function cleanup()
        for image in ezs.images
            SDL_DestroyTexture(image.texture)
        end
        SDL_DestroyWindow(ezs.window)
        SDL_DestroyRenderer(ezs.renderer)
        SDL_Quit()
    end

    function clear()
        clear(0, 0, 0)
    end
    function clear(r, g, b)
        clear(r, g, b, 255)
    end
    function clear(r, g, b, a)
        SDL_SetRenderDrawColor(ezs.renderer, r, g, b, a)
        SDL_RenderClear(ezs.renderer)
    end

    function draw_text(font, text, x, y, color)
        surface = TTF_RenderText_Solid(font, text, color)
        texture = SDL_CreateTextureFromSurface(ezs.renderer, surface)
        
        w_ref, h_ref = Ref{Cint}(0), Ref{Cint}(0)
        SDL_QueryTexture(texture, C_NULL, C_NULL, w_ref, h_ref)
        text_rect = Ref(SDL_Rect(x, y, w_ref[], h_ref[]))
        # ez.Rect(x, y, 0, 0)
        
        SDL_RenderCopy(ezs.renderer, texture, C_NULL, text_rect)
        SDL_DestroyTexture(texture)
        SDL_FreeSurface(surface)
    end

    function draw_image(im, x, y, width, height)
        if typeof(x) != Int
           x = convert(Int, floor(x))
        end
        if typeof(y) != Int
           y = convert(Int, floor(y))
        end
        if typeof(width) != Int
           width = convert(Int, floor(width))
        end
        if typeof(height) != Int
           height = convert(Int, floor(height))
        end
        rect = Ref(SDL_Rect(x, y, im.width, im.height))
        SDL_RenderCopy(ezs.renderer, im.texture, C_NULL, rect)
    end

    function millis()
        return SDL_GetTicks()[]
    end
    ez_last_time = millis()
    function dtime()
        new_dtime = millis() - ez_last_time
        global ez_last_time = millis()
        return new_dtime
    end

    function Color(r, g, b, a)
        return SDL_Color(r, g, b, a)
    end

    function create_window(name::String, shape)
        window = SDL_CreateWindow(name, SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, shape[1], shape[2], SDL_WINDOW_SHOWN)
        SDL_SetWindowResizable(window, SDL_TRUE)
        ezs.window = window
        return window
    end

    ez_num_frames = 0
    function num_frames()
        return ez_num_frames
    end
    function flip()
        SDL_RenderPresent(ezs.renderer)
        global ez_num_frames += 1
    end

    function create_renderer(window)
        renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC | SDL_RENDERER_TARGETTEXTURE)
        ezs.renderer = renderer
        return renderer
    end

    ez_event_ref = Ref{SDL_Event}()
    function some_events()
        return Bool(SDL_PollEvent(ez_event_ref))
    end
    function get_event()
        return ez_event_ref[]
    end

    function get_mouse_pos()
        x, y = Ref{Cint}(0), Ref{Cint}(0)
        SDL_GetMouseState(x, y)
        return (x[], y[])
    end

    function update_keys()
        #=This only works if youve called some_events() first.
            NOTE: look into the SDL source code for why
        =#
        ezs.keys = SDL_GetKeyboardState(C_NULL)
    end

    function is_pressed(key)
        return unsafe_load(ezs.keys, key+1) == 1
    end

    function load_image(path)
        #=You have to make sure there is a top level renderer before you call this.=#
        surface = IMG_Load(path)
        tex = SDL_CreateTextureFromSurface(ezs.renderer, surface)
        w_ref, h_ref = Ref{Cint}(0), Ref{Cint}(0)
        SDL_QueryTexture(tex, C_NULL, C_NULL, w_ref, h_ref)
        SDL_FreeSurface(surface)
        im = Image(tex, w_ref[], h_ref[])
        push!(ezs.images, im)
        return im
    end
    # function draw(image, renderer, pos, )

    # dest_ref[] = SDL_Rect(x, y, w, h)
    # SDL_RenderClear(renderer)
    # SDL_RenderCopy(renderer, img.texture, C_NULL, dest_ref)

end