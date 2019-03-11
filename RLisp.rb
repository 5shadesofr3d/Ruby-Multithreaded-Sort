# This is a lisp interpreter that will evaluate any function that is passed through it
class RLisp
	def initialize()
		@variableDict = Hash.new #Need to double check this
		@lambdaContext = []
		@print = true
	end

	def eval(args)
		result = self.mainEval(args)
		if @print
			print_result(result)
		else
			@print = true
		end
	end

	def mainEval(args)
		# The args list contains all of the elements and the functions that are required
		# for the lisp interpreter to run
		# Check to see if the first element is a method. If not then return the args
		if args.is_a? Symbol
			# check the length of the array to determine to return the 
			return @variableDict[args]
		elsif args.is_a? Numeric or args.is_a? String
			return args
		elsif args.is_a? Array
			# if the first element of the array is a lambda function, then store the second element
			if args[0].is_a? Array
				#saving the context
				@lambdaContext.push(args[1..-1])
				return self.mainEval(args[0])
			end

			# check if the symbol is part of the hash
			if @variableDict.key?(args[0])
				return self.mainEval(args[1..-1].unshift(@variableDict[args[0]]))
			end

			# Execute the normal method
			methodName, *newArgs = *args
			return self.send(methodName, newArgs)
		else
			return "incorrect input!"
		end
	end

	def label(args)
		# This will label a value to a variable
		@variableDict[args[0]] = self.mainEval(args[1])
		@print = false
	end

	def quote(args)
		# This will return a list, regards if there is an expression in the
		# first element
		return args[0]
	end

	def car(args)
		# Get the first element of the array
		return self.mainEval(args[0])[0]
	end

	def cdr(args)
		# Get the rest of a list
		return self.mainEval(args[0])[1..-1]
	end

	def cons(args)
		# puts the first element in a list
		return self.mainEval(args[1]).unshift(self.mainEval(args[0]))
	end

	def eq(args)
		# checks if both of the values are equal
		return self.mainEval(args[0]) == self.mainEval(args[1])
	end

	def if(args)
		# checks the if statement and runs either the true or false statement
		if self.mainEval(args[0])
			return self.mainEval(args[1])
		else
			return self.mainEval(args[2])
		end
	end

	def atom(args)
		# checks if the value is an atom
		atom = true
		if args[0].is_a? Array
			if args[0].length > 0
				atom = false
			end
		end
		return atom
	end

	def lambda(args)
		# creates a lambda function that will be evaluated with an external variable
		currentContext = @lambdaContext.pop()
		variables = args[0]
		body = args[1]

		# substitute the lambda variables within the array
		variables.each_with_index do |var, index|
			body = substitute(body, var, currentContext[index])
		end

		# evaluate the function
		return self.mainEval(body)
	end

	def substitute(arr, find, replaceval)
		arr.each_with_index do |val, index|
			if val.is_a? Array
				arr[index] = substitute(val, find, replaceval)
			elsif val == find
				arr[index] = replaceval
			end
		end
		return arr
	end

	def print_result(result)
		puts "#=>#{result}"
	end
end