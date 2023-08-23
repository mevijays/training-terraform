# Conditionals
Sometimes, you might run into a scenario where you’d want the argument value to be different, depending on another value. The conditional syntax is as such:
```yaml
condition ? true_val : false_val
```
The condition part is constructed using previously described operators. In this example, the bucket_name value is based on the “test” variable—if it’s set to true, the bucket will be named “dev” and if it’s false, the bucket will be named “prod”:

```yaml
bucket_name = var.test == true ? "dev" : "prod"
```
## Splat Expressions
Splat expressions are used to extract certain values from complicated collections – like grabbing a list of attributes from a list of objects containing those attributes. Usually you would need an “for” expression to do this, but humans are lazy creatures who like to make complicated things simpler.

For example, if you had a list of objects such as these:
```yaml
test_variable = [
 {
   name  = "Arthur",
   test  = "true"
 },
 {
   name  = "Martha"
   test  = "true"
 }
]
```
Instead of using the entire “for” expression:
```
[for o in var.test_variable : o.name]
```
you could go for the splat expression form:
```
var.test_variable[*].name
```
And in both cases, get the same result:
```
["Arthur", "Martha"]
```