# kong-plugin-auth-redis
A Kong plugin, provide authentication for requests by checking token in Redis and send JWT token to corresponding endpoint <br/> <br/>

  
Simple auth flow of this plugin <br/>
![image](https://user-images.githubusercontent.com/10768153/140670463-7d1fdeb9-8de9-49db-9d38-558e7cf01db3.png). <br/>

1. Client sends a request with a bearer opaque token.
2. Kong forwards the request to the plugin.
3. The plugin then checks if the token exists in the redis. If exists, it gets the value (JWT token issued by other auth server earlier when authenticating) and set authorization header of the request.
4. The request is back to Kong.
5. The request forwards to the Resource server.
6. Kong receives the response.
7. The client receives the response.
