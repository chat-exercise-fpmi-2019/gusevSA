all: server.o client.o
	g++ server.o -o ./bin/server
	# g++ client.o -o ./bin/client

server.o: server.c
	g++ -c server.c

client.o: client.c
	g++ -c client.c
