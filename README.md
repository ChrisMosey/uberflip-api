# README

## Api Docs

[https://documenter.getpostman.com/view/1099492/Uyr5myEe](https://documenter.getpostman.com/view/1099492/Uyr5myEe)


## Changed files

* `app/controllers/users_controller.rb`
* `app/controllers/timesheets_controller.rb`
* `app/models/user.rb`
* `app/models/timesheet.rb`
* `db/migrate/*`
* `lib/exceptions.rb`
* `spec/factories/users.rb`
* `spec/factories/timesheets.rb`
* `spec/requests/users_controller_spec.rb`
* `spec/requests/timesheet_controller_spec.rb`

## Set up
run `docker-compose build` followed by `docker-compose up`. Server will be running on `localhost:3000`.

tests: `docker exec -it api-web-1 'rspec'`
## DB Schema
see ./db_diagram.pdf
## Developers Notes
### Date time fields
I relized before the end that the date time fields should have been using a unix time stamp. This would have made saving, and searching much easier. Converting to a unix time stamp on the front end would not have been hard, and as it currently stands, the application does not take time zones into account. Searching between dates would have also been easier.

### SIN Number
I originally set the sin number as a number type thinking it would be easer to do equasions on the number, but I discovered that it will error if the number starts with 0. Because of this, I changed the sin number to be sent as a string

### Updating a user
I didn't include all of the tests for this endpoint. Since this isn't going to be launched, and they would be checking the exact same thing as create, I decided to make a not of it here instead.

### Get all timesheets
There were a few different ways to go about this. I decided to go a simpler way, and just list all time sheet data with user data in the same row. But a better way to have done this would be to loop through the user data, and group all the timesheet data with the users themselves.