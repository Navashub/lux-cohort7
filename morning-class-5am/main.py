# Topic 1 - List and List Comprehension
# List - collection of items stored in single variable.
#		- they are ordered(items have fixed position)
#		- mutable (you can change them after creation)

# Creatng list - use Square brackets [] to create list
# Items inside the [] are separated by commas:

# empty list
shopping = []

# list of strings 
fruits = ["apple", "banana", "mango", "orange"]
# print(fruits)

# list of numbers
scores = [85,72,90,65,78]
# print(scores)

# a list can have mix different types
mixed = ["Alice", 25, True, 3.14]
# print(mixed)

#Accessing items - indexing
# Every item in a list has a number called an index
# In python, counting starts from 0, not 1.

fruits = ["apple", "banana", "mango", "orange"]
#		  index 0   index 1   index 2  index 3

#print(fruits[0])  # first item 
#print(fruits[1])	#second item
#print(fruits[2])	# third item

# negative indexing - count from the end
#print(fruits[-1])	#last item
#print(fruits[-2])	# second to last

# List methods - things you can do with a list
# Python gives lists built-in methods 
#		(functions you call on a list)

fruits = ["apple", "banana", "mango", "orange"]

# Add items (append)
# add "Cherry"

#fruits.append("cherry")
#print(fruits)

# adding in specific index (insert)
# insert(position/index, value)
# add "pear", index 1(second position)

#fruits.insert(1,"pear") # add at position 1 / index 1
#print(fruits)

# Remove items (remove)
fruits.remove("banana")
#print(fruits)

#fruits.pop()	#removes the LAST item 
#print(fruits)

fruits.pop(0)	#removes the item at index 0
#print(fruits)

# other useful methods
fruits.sort()	# sorts alphabetically
fruits.reverse()	# reverses the list

# find position of item 
# which index is mango
fruits.index("mango")

# Count how many times and item appears
fruits.count("apple")

#print(fruits)

# List slicing - get a portion of a list
nums = [10,20,30,40,50]

# Get from index 1 upto (not including) 3
#print(nums[1:3])
# get from start upto index 2
#print(nums[:2])
# get from index 2 to the end
#print(nums[2:])
# reversing using slicing
#print(nums[::-1])

""" List Comprehension
 	-concise way to create lists in python 
 	-compact and easier to read than the traditional loops
"""
# long way using loops 
# Create list of squares : [1, 4, 9, 16,25]
squares = []
for x in range(1,11):
	squares.append(x ** 2)
#print(squares)

"""
pattern:
	[expression for value in iterable if condition]
	[what to do]  [where to get items] [optional filter]

"""
#short way (List comprehension)
# 1, 2,3,4,5 = 2,4,6,8,10
squares = [x**2 for x in range(1,11)]
#print(squares)

# get positive numbers
numbers = [1,-2,3,-4,5,-6]

positive_numbers = [num for num in numbers if num > 0]
#print(positive_numbers)

# Only even numbers from 0-9
even= [x for x in range(10) if x % 2==0]
print(even)

even_numbers = [x for x in range(10) if x%2 == 0]
print(even_numbers)

# Uppercase all fruits
fruits = ["apple", "banana", "mango", "orange"]

upper_fruit = [f.upper() for f in fruits]
print(upper_fruit)


"""EXCERCISE
- You have this list: 
names = ["Brian", "Alice", "David", "Eve", "Carol"]
"""

"""Tasks
-Print the first and last name using indexing
- Add your own name to the end , then print
- Sort the list alphabetically
- Using list comprehension print all names in UPPERCASE
- create a new list with only names longer than 4 characters 
"""



































