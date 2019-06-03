all: server.o client.o
	g++ server.o -o server
	# g++ client.o -o client

server.o: server.c
	g++ -c server.c

client.o: client.c
	g++ -c client.c
