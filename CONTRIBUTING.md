# Contributing to this repository
Please read below before creating issues or pull requests.

## Issues
- Issues can be in any format you'd like as long as it's readable and in English.
- Avoid making duplicate issues. Check to make sure the issue you want to report hasn't been reported already.
- Verify that this addon is responsible for your issue before reporting.

## Pull Requests
- Try to keep your pull requests small and directed towards a single change. If you want to change or add multiple unrelated things, make separate pull requests for each of them.
- Complete rewrites of large parts and extremely small changes probably won't be accepted unless you can provide proof that the change greatly improves performance and/or functionality.
	### Styling
	- Styling won't be strictly enforced unless it looks unreadable compared to the rest of the code. If you choose not to follow one or two of the styling rules shown below you'll still be fine.
	- Use size 4 tabs instead of spaces. I know this is unconventional but I find it to be neater.
	- See this example for how your code should be styled:
		``` lua
			--Placing comments in your actual code is recommended but not required
			function Equals( text1, text2 ) --Put spaces in between the parenthesis and the arguments as well as after commas
				local blacklist = { --keep the bracket here for arrays, lists, dictionaries, etc
					"word",
					"example",
					"blacklist" --Make a new line for each value in an array unless they start to take up too much room, then put them all on a single line
				}

				--Leave whitespace in between control structures and variable declarations
				for k,v in pairs( blacklist ) do
					if v == text1 then --Don't use parenthesis with control structures
						print( "Word is blacklisted. Aborting." )
						return false
					end
				end

				if text1 == text2 then return true end --For small amounts of code inside control structures, put everything on a single line
				return false
			end
		```
