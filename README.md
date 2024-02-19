# Ultrasound Guided IV Request iOS App - Backend

**How to setup database:**
There are 4 environment variables that you need to change when running on your local DB or RDS.
DATABASE_HOST=
DATABASE_PASSWORD=
DATABASE_NAME=a
DATABASE_USERNAME=

**Different request parameters for the API:**

1. Register a new user:
    - URL: /users
    - Method: POST
    - Request Body: 
        {
            "userName": "username",
            "password": "password",
            "confirmPassword": "password"
        }
    - Response: 
        {
            "User object"
        }

2. Login:
    - URL: /users/login
    - Method: POST
    - Authorization: Basic Username and Password
    - Response: 
        {
            "User object"
        }

3. Get all users (not useful for front end but good for testing):
    - URL: /users
    - Method: GET
    - Response:
       {
            JSON array of all User Objects
       }

4. Get all requests (not useful for front end but good for testing):
    - URL: /requests
    - Method: GET
    - Response: 
        {
            JSON array of all Request Objects
        }

5. Create a request:
    - URL: /requests
    - Method: POST
    - Authorization: Basic Username and Password
    - Request Body: 
        {
            "hospital": "",
            "roomNumber": "",
            "callBackNumber": "",
            "notes": ""
        }
    - Response: 
        {
            "Request object"
        }

6. Get all available requests:
    - URL: /requests/available
    - Method: GET
    - Authorization: Basic Username and Password
    - Response: 
        {
            JSON array of Request objects
        }

7. Get all requests by the user posted:
    - URL: /requests/userPosted
    - Method: GET
    - Authorization: Basic Username and Password
    - Response: 
        {
            JSON array of Request objects
        }

8. Get all requests by the user accepted:
    - URL: /requests/userAccepted
    - Method: GET
    - Authorization: Basic Username and Password
    - Response: 
        {
            JSON array of Request objects
        }      
      
9. Accept a request:
    - URL: /requests/accept/:requestID (add ID of request)
    - Method: PUT
    - Authorization: Basic Username and Password
    - Updates: status -> 1, userAccepted -> user.id
    - Response: 
        {
            "Request object"
        }

10. Cancel a request:
    - URL: /requests/cancel/:requestID (add ID of request)
    - Method: PUT
    - Updates: status -> 2
    - Response: 
        {
            "Request object"
        }

11. Unaccept a request:
    - URL: /requests/unaccept/:requestID (add ID of request)
    - Method: PUT
    - Updates: status -> 0, userAccepted -> nil
    - Response: 
        {
            "Request object"
        }

12. Mark a request as completed:
    - URL: /requests/markCompleted/:requestID (add ID of request)
    - Method: PUT
    - Updates: Request object status -> 3
    - Response: 
        {
            "Request object"
        }
      
13. Delete a request:
    - URL: /requests/:requestID (add ID of request)
    - Method: DELETE
    - Deletes: Request Object

14. websocket chat:
    - URL: /requestID
    - Method: ws
    - Headers: userName：String

15. Get all messages for a request（return last 100 messages）:
    - URL: /chats/:requestID
    - Method: GET
    - Response: 
        {
            JSON array of Message objects
        }
