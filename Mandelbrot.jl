using Printf, Luxor, Colors, Images

#=
    --- Mandelbrot.jl ---
    Generate beautiful mandelbrot sets in Julia. Uses threading to accelerate generation (may hog your CPU).
=#


# CONSTANTS

const w = 3840  # width of the result image
const h = 2160  # height of the result image

const max_iter = 200  # maximum iterations (the higher, the more accurate)

const zoom = 5  # zoom; controls the width of the plane; must be > 0

const offset_re = 0.5  # offset in the real plane
const offset_im = 0.1  # offset in the imaginary plane


# CODE

# jank, cant be bothered to fix
offset_x = offset_im
offset_y = offset_re

max_both_axes = (max(w, h) - 2.47)*zoom

# to reduce number of logs
const log_2 = log(2)

# canvas, draw pixel by pixel
A = zeros(ARGB32, h, w)
Drawing(A)

# color palette, adjust to your liking; length must be 16
palette = [
    (66, 30, 15),
    (25, 7, 26),
    (9, 1, 47),
    (4, 4, 73),
    (0, 7, 100),
    (12, 44, 138),
    (24, 82, 177),
    (57, 125, 209),
    (134, 181, 229),
    (211, 236, 248),
    (241, 233, 191),
    (248, 201, 95),
    (255, 170, 0),
    (204, 128, 0),
    (153, 87, 0),
    (106, 52, 3)
]

Threads.@threads for x in range(1, w)
    for y in range(1, h)
        # calculate c = a + bi
        a = x / max_both_axes + offset_x
        b = y / max_both_axes + offset_y
        c = a + b*im
        z = 0
        i = 0

        while abs(z) <= 5 && i < max_iter
            z = z^2 + c
            i += 1
        end

        n = max_iter - i

        if i < max_iter
            # interpolation code
            log_zn = log(real(z)^2 + imag(z) ^ 2) / 2
            nu = log(log_zn / log_2) / log_2
            k = i + 1 - nu
            rc1 = palette[floor(Int, k) % 16 + 1] ./ 255
            rc2 = palette[floor(Int, k + 1) % 16 + 1] ./ 255
            c1 = RGB(rc1[1], rc1[2], rc1[3])
            c2 = RGB(rc2[1], rc2[2], rc2[3])

            color = range(c1, stop=c2, length=100)[floor(Int, (k % 1) * 100) + 1]
            A[y, x] = color
        else
            # values within the Mandelbrot set
            A[y, x] = RGB(0, 0, 0)
        end
    end
end

# Store as PNG
@png begin
    origin()
    placeimage(A, O - (w/2, h/2))
end w h "Mandelbrot-" * string(max_iter) * "-" * string(zoom) * "z" * string(offset_x) * "," * string(offset_y) * "-" * string(w) * "x" * string(h) * ".png"
#=
    PNG file name format:
    Mandelbrot-[max iterations]-[zoom]z[offset_im],[offset_re]-[w]x[h].png
=#

# preview image
A
