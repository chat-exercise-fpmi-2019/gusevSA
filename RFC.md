# Chat protocol -- CP/0.0.0

# Status of this Memo
In development

# Purpose
This document specifies a chat protocol for the 13 group FAMCS BSU

# General overview
## System description
The system API based on REST API.
The system is an immediate chat. It consists server and client.

## Semantic convention

Describing messages we will apply following semantic conventeions:

- Special symbols like SP and CRLF are represented with appropriate symbols.
- Interpolation of strings is represented with __#{__ string-to-interpolate __}__ symbols.

## Available commands 
### Client
- Set username
- Send private message
- Send broadcast message
- Poll from incoming messages

### Server
- Send _response_ message
- Send _error_ message
- Send _info_ message

## Flow description
Firstly Client and Server establishing connection. Then Client sends Request chain with request data.
Server answers by sending message to client with response data.

              Request chain ------------------------>
       Client ----------------Connection------------- Server
              <----------------------- Response chain


## Connection
Clients establish a TCP (see RFC 793) connection with a server and communicate with text messages.

### Messages
Messages are consist of **status line**, **header** and **body**.

All text MUST be encoded as UTF-8 (RFC 3629) for network transmission.

Messages mismatching with this RFC structure and semantic will cause unpredictable behavior.

Messages are different between Client and Server, but structure of message is immutable and common for both of them.

General message structure:

- A status line.
- Optional header fields followed by CRLF. Header fields start from _header rule_, then follows comma _:_, and then _rule value_: `#{Header rule}: #{Header value} CRLF`. Example:

```http
Auth: SGVsbG8sIEknbSBhdXRoZW50aWNhdGlvbiB0b2tlbiE=

```

- An empty line (i.e., a line with nothing preceding the CRLF) indicating the end of the header fields.
- Optional message body

#### Server
##### Status line

Status line consists of *status code*, *reason phrase*.

`Status-line = #{Status-code} SP #{Reason-phrase} CRLF`

Example:

```http
200 OK

```

##### Header

Header contains **authentication token**.

**authentication token** used to store information about authentication.

`Header = Auth: #{Authentication-token} CRLF`

Example:
Authenticational token represented by string `Hello, I'm authentication token!` encoded by B64.

```http
Auth: SGVsbG8sIEknbSBhdXRoZW50aWNhdGlvbiB0b2tlbiE=

```

##### Body
Body contains **response data**.

`Body = #{Response-data} CRLF`

#### Client
##### Status line
Status line is empty.

##### Header 
Header contains **authentication token**.

Authentication token string is the same with corresponding string on the server.

##### Body
Body contains request data.

`Body = #{Request-data} CRLF`

## Status code and reason phrase
Status code and reason phrase reflect what the consequences request message was lead to.

Possible Status codes and reason phrases are below:

`Status-code; SP Reason-phrase`

- "200"; OK
- "304"; Not Modified
- "400"; Bad Request
- "404"; Not Found
- "418"; 'I'm a tea polcket'
- "500"; Internal Server Error
- "501"; Not Implemented
- "502"; Bad Gateway
