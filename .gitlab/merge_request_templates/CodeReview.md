## Code review checklist

* Is the Apache licence displayed clearly at the top of the file with the correct attribution?
* Am I able to understand the code easily?
* Does the code pass [rubocop linting](README.md#Linting) rules?
* Do classes have a single responsibility?
* Are the unit tests enough to describe everything the code is doing?
* Do tests have a single responsibility?
* Is the coupling between classes heavy?
* There there concepts in here that are not extracted?
* Is there indirection present that's not paying it's way?
