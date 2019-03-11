# Chat protocol -- CP/0.0.0

### Status of this Memo
In production

### Purpose
This document specifies a chat protocol for the 13 group FAMCS BSU

### Terminology


### General overview
#### System description
The system API based on REST API.
The system is an immediate chat. It consists server and client.

#### Available commands 
##### Client
- Set username
- Send private message
- Send broadcast message

##### Server
- Send response message

#### Flow description
Firstly Client and Server establishing connection. Then Client sends Request chain with request data.
Server answers by sending message to client with response data.

              Request chain ------------------------>
       Client ----------------Connection------------- Server
              <----------------------- Response chain


#### Connection
Clients establish a TCP (see RFC 793) connection with a server and communicate with text messages.

##### Messages
Messages are consist of **status line**, **header** and **body**. 

Messages are different between Client and Server, but structure of message is immutable.

###### Server
####### Status line
Status line consists of *status code*, *reason phrase*.

`Status-line = Status-code SP Reason-phrase CRLF`

####### Header
Header contains **authentication token**.

**authentication token** used to store information about authentication.

`Header = Authentication-token CRLF`

####### Body
Body contains **response data**. 

`Body = Response-data CRLF`

###### Client
####### Status line
Status line is empty.

####### Header
Header contains **authentication token**. 

**authentication token** used to store information about authentication.

`Header = Authentication-token CRLF`

####### Body
Body contains request data. 

`Body = Request-data CRLF`

#### Status code and reason phrase
Status code and reason phrase reflect what the consequences request message was lead to.

Possible Status codes and reason phrases are below:

`Status-code; SP Reason-phrase`

- "200"; OK
- "304"; Not Modified
- "400"; Bad Request
- "401"; Unauthorized
- "403"; Forbidden
- "404"; Not Found
- "418"; 'I'm a tea pocket'
- "500"; Internal Server Error
- "501"; Not Implemented
- "502"; Bad Gateway