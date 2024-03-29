numbers = [convert(Char, string(i)[1]) for i in 0:9]
push!(numbers, '-', 'e', '.')

function lex_string!(lines::Vector{Char})

    if lines[1] == JSON_QUOTE
        if length(lines) > 1
            popnfirst!(lines, 1)
        end
    else
        return nothing
    end # if


    jsonString = ""
    for c in lines
        if c == JSON_QUOTE
            if length(lines) > 1
                popnfirst!(lines, length(jsonString)+1)
            end
            return jsonString
        else
            jsonString *= c
        end # if
    end # for

    error("No end of string found")

end # lex_string

function lex_number!(lines::Vector{Char})
    jsonNum = ""

    for c in lines
        if c in numbers
            jsonNum *= c
        else
            break
        end # if
    end # for

    popnfirst!(lines, length(jsonNum))

    if length(jsonNum) == 0
        return nothing
    end # if

    if '.' in jsonNum
        return parse(Float64, jsonNum)
    end # if

    return parse(Int64, jsonNum)

end # lex_number

function lex_bool!(lines::Vector{Char})

    if length(lines) >= 4
        if lines[:4] == "true"
            popnfirst!(lines,4)
            return true
        elseif lines[:4] == "null"
            popnfirst!(lines,4)
            return nothing
        end
    elseif length(lines) >= 5 && lines[1:5] == "false"
        popnfirst!(lines,5)
        return false
    end # if

    return nothing
end # lex_bool

function lexer(filename::String)
    lines = Vector{Char}(Mmap.mmap(filename, Vector{UInt8}, filesize(filename)))

    tokens = Vector{Any}()

    while length(lines) > 0
        jsonString = lex_string!(lines)
        if jsonString !== nothing
            push!(tokens, jsonString)
            continue
        end # if

        jsonNum = lex_number!(lines)
        if jsonNum !== nothing
            push!(tokens, jsonNum)
            continue
        end # if

        jsonBool = lex_bool!(lines)
        if jsonBool !== nothing
            push!(tokens, jsonBool)
            continue
        end # if


        if lines[1] in JSON_WHITESPACE
            popfirst!(lines)
        elseif lines[1] in JSON_SYNTAX
            push!(tokens, popfirst!(lines))
        end # if
    end # while


    return tokens
end # lexer
