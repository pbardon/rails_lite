require 'webrick'

server = WEBrick::HTTPServer.new(Port: 8000)

server.mount_proc '/' do |req, res|
  res["content-type"] = "text/text"
  res.body = req.path
end

trap('INT') { server.shutdown }
server.start
