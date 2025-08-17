using Pkg
Pkg.activate(".")

using HTTP
using JSON

const OLLAMA_URL = "http://localhost:11434/api/chat"
const MODEL_NAME = "dolphin3:latest"

function read_questions_from_file(filename::String)
    questions = String[]
    if isfile(filename)
        content = read(filename, String)
        # Split by ### to get individual question groups
        groups = split(content, "###")
        for group in groups
            # Split each group by newlines and filter out empty lines
            lines = filter(!isempty, split(strip(group), "\n"))
            for line in lines
                # Remove bullet points and clean up
                clean_line = replace(strip(line), r"^•\s*" => "")
                if !isempty(clean_line)
                    push!(questions, clean_line)
                end
            end
        end
    end
    return questions
end

function get_random_question(questions::Vector{String})
    return rand(questions)
end

function chat_with_ollama(messages::Vector{Dict{String, String}})
    body = JSON.json(Dict(
        "model" => MODEL_NAME,
        "messages" => messages,
        "stream" => false
    ))

    headers = ["Content-Type" => "application/json"]
    response = HTTP.post(OLLAMA_URL, headers, body)
    data = JSON.parse(String(response.body))
    return data["message"]["content"]
end



seed = "RULES: I a question will be followed by answer in the next paragraph You provide score of how good the answer is in percents, if its not perfect you will provide a feedback and example of perfect answer. No bullshit, no being nice for no reason, no unnecessary long talking got it?"

conversation = [
    Dict("role" => "system", "content" => seed)
]

while true

    # Read questions and select a random one
    questions = read_questions_from_file("questions")
    random_question = get_random_question(questions)

    println("\n\n\nSelected question: $random_question")
    println()

    print("You: ")
    user_input = readline()

    push!(conversation, Dict("role" => "system", "content" => random_question))
    push!(conversation, Dict("role" => "user", "content" => user_input))

    response = chat_with_ollama(conversation)
    println("Ollama: $response")

    push!(conversation, Dict("role" => "assistant", "content" => response))
end

