using HTTP
using JSON3

# Define the request payload
data = Dict(
    "model" => "dolphin3:latest",  # or "mistral", "codellama", etc.
    "prompt" => "Hello from Julia!"
)

# Make the POST request to Ollama
response = HTTP.post(
    "http://localhost:11434/api/generate",
    ["Content-Type" => "application/json"],
    JSON3.write(data)
)

# Parse and print
parsed = JSON3.read(String(response.body))
println(parsed.response)
