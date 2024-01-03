require "http"

server = HTTP::Server.new do |context|
  name = nil
  file = nil
  HTTP::FormData.parse(context.request) do |part|
    case part.name
    when "name"
      name = part.body.gets_to_end
    when "file"
      file = File.tempfile("upload") do |file|
        IO.copy(part.body, file)
      end
    end
  end

  unless name && file
    context.response.respond_with_status(:bad_request)
    next
  end

  context.response << file.path
end

server.bind_tcp 8080
server.listen