using Pkg
Pkg.activate(".")

using HTTP
using JSON

const OLLAMA_URL = "http://localhost:11434/api/chat"
const MODEL_NAME = "dolphin3:latest"

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

seed = "you roleplay santa claus"
conversation = [
    Dict("role" => "system", "content" => seed)
]

while true
    print("You: ")
    user_input = readline()

    push!(conversation, Dict("role" => "user", "content" => user_input))

    response = chat_with_ollama(conversation)
    println("Ollama: $response")

    push!(conversation, Dict("role" => "assistant", "content" => response))
end

