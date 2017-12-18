
# AST 2017 - Express codebase

A simple user/data project.

## Installation instructions
Just clone it from github & run `npm install`

## Run
Use `nodemon src/app.coffee` or `npm start` or `bin/start`

## Working with pre-made data

### Inserting the pre-made data
To insert pre-made data containing a set of users with their own metrics, two ways are available:
1. Run `bin/populate`
2. Through the URL `http://localhost:8888/populate`

### User logins
1. Username:`user1` | Password:`password1`
2. Username:`user2` | Password:`password2`
3. Username:`user3` | Password:`password3`

## Data insertion

### Metrics
Send JSON data to `localhost:8888/metrics.json/[ID]`  
The data sent should be arranged this way:
```
[{
  "timestamp" : "x1",
  "value" : "y2"
},
{
  ...
},
{
	"timestamp" : "xn",
	"value" : "yn"
}]
```

### User
You can create a new user via the webpage by clicking on the "Create an account button" or through the URL `http://localhost:8888/signup`  
You can also send data to `localhost:8888/user.json`  
The data sent should be arranged this way:
```
{
	"username" : "x",
	"password" : "y",
	"name" : "z",
	"email" : "email@site.type"
}
```

### Linking metrics to users
To link a metric to an user, send data to `localhost:8888/usermetrics.json/`  
The data sent should be arranged this way:
```
{
	"username" : "x",
	"id": "y"
}
```

## Data deletion

### Metrics
Send a DELETE request to `localhost:8888/metrics.json/[ID]`

### User
Send a DELETE request to `localhost:8888/user.json/[USERNAME]`

### User/metrics links
Send a DELETE request to `localhost:8888/usermetrics.json`  
The data sent should be arranged this way:
```
{
	"username" : "x",
	"id" : "y"
}
```

## Tests
Use `npm test` or `./bin/test`

## Contributors

David Deray  
Mégane Pau

## License

Apache2
